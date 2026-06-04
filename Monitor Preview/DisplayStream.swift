//
//  DisplayStream.swift
//  Monitor Preview
//
//  Created by Zhang Maiyun on 2022-04-15.
//

import AppKit
import CoreGraphics
import ScreenCaptureKit

struct MPError: Error {
    var inner: CGError
}

/** Get an Array of active displays */
func getDisplays() async -> [SCDisplay] {
    guard let shareable = try? await SCShareableContent.current else {
        print("No display found")
        return []
    }
    return shareable.displays
}

/** Find the localized human-readable name of a display */
func displayName(display: SCDisplay) -> String {
    let prop = NSDeviceDescriptionKey(rawValue: "NSScreenNumber")
    for nsScreen in NSScreen.screens {
        let screenId = nsScreen.deviceDescription[prop]
        if screenId as! UInt32 == display.displayID {
            return nsScreen.localizedName
        }
    }
    return ""
}

/** Summarize display properties */
func displayProp(display: SCDisplay) -> String {
    if let displayMode = CGDisplayCopyDisplayMode(display.displayID) {
        let width = displayMode.pixelWidth
        let height = displayMode.pixelHeight
        let refRate = displayMode.refreshRate
        return "\(width)x\(height) @ \(refRate) Hz"
    }
    return ""
}
