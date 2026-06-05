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
        VStack {
            VStack {
                Spacer()
                Text("Previewing Display \(display.displayID)").font(.title2)
            }
            .frame(height: 35)
            Spacer()
            if let frame = currentFrame {
                Image(nsImage: frame)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Text("Display or streaming not active")
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
                    Text("Restart")
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
    private func setupStream() async throws {
        // Work around the bug: https://stackoverflow.com/q/77513220/9347959
        // TODO: Figure out exact versions. 12.7.6 is known bad; 26.0 is known good
        if #available(macOS 13.0, *) {
            streamer = try ScreenStreamer(display: display, onFrame: updateFrame)
        } else {
            streamer = try ScreenStreamer(display: display, apps: await getApplications(), onFrame: updateFrame)
        }
    }

    private func updateFrame(imageBuffer: CVImageBuffer) {
        if let image = cvImageBufferToNSImage(imageBuffer: imageBuffer) {
            currentFrame = image
        }
    }

    init(display: SCDisplay) {
        self.display = display
    }
}

struct DisplayPreviewView_Previews: PreviewProvider {
    struct PreviewLoader: View {
        @State private var display: SCDisplay?

        var body: some View {
            Group {
                if let display {
                    DisplayPreviewView(display: display)
                } else {
                    Text("Loading preview...")
                }
            }
            .frame(minWidth: 400, minHeight: 300)
            .task {
                let current = try? await SCShareableContent.current
                display = current?.displays.first
            }
        }
    }

    static var previews: some View {
        PreviewLoader()
    }
}
