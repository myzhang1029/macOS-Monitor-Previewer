//
//  ScreenStreamer.swift
//  Monitor Preview
//
//  Created by Maiyun Zhang on 2026-06-05.
//

import CoreMedia
import CoreVideo
import ScreenCaptureKit

class ScreenStreamer: NSObject, SCStreamOutput, SCStreamDelegate {
    var scStream: SCStream?
    var onFrame: (CVImageBuffer) -> Void

    /** init with `excludingApplications:[]` (has issues on macOS 12.x; see `DisplayPreviewView.setupStream`)  */
    convenience init(display: SCDisplay, onFrame: @escaping (CVImageBuffer) -> Void) throws {
        let filter = SCContentFilter(display: display, excludingApplications: [], exceptingWindows: [])
        try self.init(filter: filter, onFrame: onFrame)
    }

    /** init with the given array of applications to capture */
    convenience init(
        display: SCDisplay, apps: [SCRunningApplication], onFrame: @escaping (CVImageBuffer) -> Void
    ) throws {
        let filter = SCContentFilter(display: display, including: apps, exceptingWindows: [])
        try self.init(filter: filter, onFrame: onFrame)
    }

    init(filter: SCContentFilter, onFrame: @escaping (CVImageBuffer) -> Void) throws {
        self.onFrame = onFrame
        super.init()
        let configuration = SCStreamConfiguration()
        configuration.minimumFrameInterval = .zero  // Native rate
        configuration.queueDepth = 4
        scStream = SCStream(filter: filter, configuration: configuration, delegate: self)
        let videoQueue = DispatchQueue(label: "VideoQueue")
        try scStream!.addStreamOutput(self, type: .screen, sampleHandlerQueue: videoQueue)
        scStream!.startCapture()
    }

    /** Stop streaming if any exists but do nothing if not */
    func close() async {
        do {
            try await scStream?.stopCapture()
        } catch {}
        scStream = nil
    }

    func stream(_: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
        guard sampleBuffer.isValid, type == .screen else {
            print("Invalid sampleBuffer or unexpected type \(type)")
            return
        }
        guard let pixelBuffer = sampleBuffer.imageBuffer else { return }
        onFrame(pixelBuffer)
    }
}
