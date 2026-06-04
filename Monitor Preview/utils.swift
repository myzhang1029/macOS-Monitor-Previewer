//
//  utils.swift
//  Monitor Preview
//
//  Created by Maiyun Zhang on 2026-06-04.
//


import AppKit
import CoreGraphics
import CoreImage
import CoreVideo
import ScreenCaptureKit

/** Convert CVImageBuffer to NSImage */
func cvImageBufferToNSImage(imageBuffer: CVImageBuffer) -> NSImage? {
    let context = CIContext()
    let ciImage = CIImage(cvPixelBuffer: imageBuffer)
    guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
        return nil
    }
    return NSImage(cgImage: cgImage, size: .zero)
}


/** Get an Array of active displays */
func getDisplays() async -> [SCDisplay] {
    guard let shareable = try? await SCShareableContent.current else {
        return []
    }
    return shareable.displays
}


class DisplayProperty {
    let width: Int
    let height: Int
    let refreshRate: Double
    /** Localized human-readable name of a display */
    let localizedName: String

    init(width: Int?, height: Int?, refreshRate: Double?, localizedName: String?) {
        self.width = width ?? 0
        self.height = height ?? 0
        self.refreshRate = refreshRate ?? 0
        self.localizedName = localizedName ?? "Unknown Display"
    }

    convenience init(display: SCDisplay) {
        var width: Int? = nil
        var height: Int? = nil
        var refreshRate: Double? = nil
        var localizedName: String? = nil
        let prop = NSDeviceDescriptionKey(rawValue: "NSScreenNumber")
        for nsScreen in NSScreen.screens {
            let screenId = nsScreen.deviceDescription[prop]
            if screenId as! UInt32 == display.displayID {
                localizedName = nsScreen.localizedName
                width = Int(nsScreen.frame.width * nsScreen.backingScaleFactor)
                height = Int(nsScreen.frame.height * nsScreen.backingScaleFactor)
                break
            }
        }
        if let displayMode = CGDisplayCopyDisplayMode(display.displayID) {
            width = displayMode.pixelWidth
            height = displayMode.pixelHeight
            refreshRate = displayMode.refreshRate
        }
        self.init(width: width, height: height, refreshRate: refreshRate, localizedName: localizedName)
    }
}

class ScreenStreamer: NSObject, SCStreamOutput, SCStreamDelegate {
    var scStream: SCStream?
    var onFrame: ((CVImageBuffer) -> Void)

    /** Stop streaming if any exists but do nothing if not */
    func close() async {
        do {
            try await scStream?.stopCapture()
        } catch {}
        scStream = nil
    }

    func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
        guard sampleBuffer.isValid && type == .screen else {
            print("Invalid sampleBuffer or unexpected type \(type)")
            return
        }
        guard let pixelBuffer = sampleBuffer.imageBuffer else { return }
        onFrame(pixelBuffer)
    }

    init(display: SCDisplay, onFrame: @escaping (CVImageBuffer) -> Void) throws {
        self.onFrame = onFrame
        super.init()
        let filter: SCContentFilter = SCContentFilter(display: display, excludingApplications: [], exceptingWindows: [])
        let configuration = SCStreamConfiguration()
        configuration.minimumFrameInterval = CMTime.zero  // Native rate
        configuration.queueDepth = 4
        scStream = SCStream(filter: filter, configuration: configuration, delegate: self)
        let videoQueue = DispatchQueue(label: "VideoQueue")
        try scStream!.addStreamOutput(self, type: .screen, sampleHandlerQueue: videoQueue)
        scStream!.startCapture()
    }
}
