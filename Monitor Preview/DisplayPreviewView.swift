//
//  DisplayPreviewView.swift
//  Monitor Preview
//
//  Created by Zhang Maiyun on 2022-04-15.
//

import ScreenCaptureKit
import SwiftUI


struct DisplayPreviewView: View {
    private var display: SCDisplay
    @State private var streamer: ScreenStreamer?
    @State var currentFrame: NSImage?

    var body: some View {
        VStack{
            VStack {
                Spacer()
                Text(LocalizedStringKey("Previewing Display \(display.displayID)")).font(.title2)
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
                Button {
                    Task {
                        await streamer?.close()
                        try? await setupStream()
                    }
                } label: {
                    Text(LocalizedStringKey("Restart"))
                }
                Spacer()
            }
            .frame(height: 35)
        }
        .frame(minWidth: 400, minHeight: 400)
        .task {
            try? await setupStream()
        }
        .onDisappear {
            Task {
                await streamer?.close()
            }
        }
    }

    /** Set up display streaming */
    func setupStream() async throws {
        streamer = try ScreenStreamer(display: display, onFrame: updateFrame)
    }

    private func updateFrame(ciImage: CIImage) {
        let context = CIContext()
        let cgImage = context.createCGImage(ciImage, from: ciImage.extent)
        if cgImage != nil {
            currentFrame = NSImage(cgImage: cgImage!, size: .zero)
        }
    }

    init(display: SCDisplay) {
        self.display = display
    }
}

nonisolated
private class ScreenStreamer: NSObject, SCStreamOutput, SCStreamDelegate {
    var scStream: SCStream?
    var onFrame: ((CIImage) -> Void)
    private let videoQueue = DispatchQueue(label: "VideoQueue")

    /** Stop streaming if any exists but do nothing if not */
    func close() async {
        do {
            try await scStream?.stopCapture()
        } catch {}
        scStream = nil
    }

    func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
        guard sampleBuffer.isValid else { return }
        switch type {
        case .screen:
            guard let pixelBuffer = sampleBuffer.imageBuffer else { return }
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            onFrame(ciImage)
        default:
            return
        }
    }

    init(display: SCDisplay, onFrame: @escaping (CIImage) -> Void) throws {
        self.onFrame = onFrame
        super.init()
        let filter: SCContentFilter = SCContentFilter(display: display, excludingApplications: [], exceptingWindows: [])
        let configuration = SCStreamConfiguration()
        configuration.minimumFrameInterval = CMTime(value: 1, timescale: 60) // TODO
        configuration.queueDepth = 5
        scStream = SCStream(filter: filter, configuration: configuration, delegate: self)
        try scStream!.addStreamOutput(self, type: .screen, sampleHandlerQueue: videoQueue)
        scStream!.startCapture()
    }
}
