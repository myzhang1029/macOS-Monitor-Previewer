//
//  DisplayPreviewView.swift
//  Monitor Preview
//
//  Created by 张迈允 on 2022-04-15.
//

import SwiftUI
import CoreGraphics


struct DisplayPreviewView: View {
    @State var displayId: CGDirectDisplayID
    @State var displayStream: CGDisplayStream?
    @State var currentFrame: NSImage?
    var dispatchQueue = DispatchQueue(label: "renderer.display", qos: .background, target: nil)
    
    var body: some View {
        VStack{
            VStack {
                Spacer()
                Text(LocalizedStringKey("Previewing Display \(displayId)")).font(.title2)
            }
            .frame(height: 35)
            Spacer()
            if currentFrame != nil {
                Image(nsImage: currentFrame!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Text(LocalizedStringKey("Display or streaming not active"))
            }
            Spacer()
            VStack {
                Divider()
                Button(action: setupStream, label: {
                    Text(LocalizedStringKey("Restart"))
                })
                Spacer()
            }
            .frame(height: 35)
        }
        .frame(minWidth: 400, minHeight: 400)
        .onAppear(perform: setupStream)
        .onDisappear {
            displayStream?.stop()
        }
    }
    
    /** Update the state with a new frame */
    func updateFrame(status: CGDisplayStreamFrameStatus, _displayTime: UInt64, frameSurface: IOSurfaceRef?, _updateRef: CGDisplayStreamUpdate?) {
        switch status {
        case .frameIdle:
            /* Do nothing */
            break
        case .frameBlank: fallthrough
        case .stopped:
            /* Clear display */
            if currentFrame != nil {
                currentFrame = nil
            }
            break
        case .frameComplete:
            if frameSurface == nil {
                break
            }
            /* Nice, update the frame */
            let ciImage = CIImage(ioSurface: frameSurface!)
            let context = CIContext()
            let cgImage = context.createCGImage(ciImage, from: ciImage.extent)
            if cgImage != nil {
                currentFrame = NSImage(cgImage: cgImage!, size: .zero)
            }
            break
        @unknown default:
            print("Got an unexpected switch case.")
            fatalError()
        }
    }
    
    /** Set up display streaming */
    func setupStream() {
        /* Stop existing one if any */
        displayStream?.stop()
        displayStream = streamDisplay(displayId: displayId, dispatchQueue: dispatchQueue, handler: updateFrame)
        displayStream?.start()
    }
    
    init(displayId: CGDirectDisplayID) {
        self.displayId = displayId
    }
}

struct DisplayPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        DisplayPreviewView(displayId: 1)
    }
}
