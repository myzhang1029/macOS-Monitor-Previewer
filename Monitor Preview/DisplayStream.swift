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
func getDisplays() async -> [CGDirectDisplayID] {
    guard let shareable = try? await SCShareableContent.current else {
        print("No display found")
        return []
    }
    return shareable.displays.map({ display in
        display.displayID
    })
}

/** Find the localized human-readable name of a display */
func displayName(displayId: CGDirectDisplayID) -> String {
    let nsScreens = NSScreen.screens
    var name = ""
    for nsScreen in nsScreens {
        let screenId = nsScreen.deviceDescription[NSDeviceDescriptionKey(rawValue: "NSScreenNumber")]
        if screenId as! UInt32 == displayId {
            name = nsScreen.localizedName
            break
        }
    }
    return name
}

/** Summarize display properties */
func displayProp(displayId: CGDirectDisplayID) -> String {
    var prop = ""
    switch CGDisplayCopyDisplayMode(displayId)
    {
    case .some(let displayMode):
        let width = displayMode.pixelWidth
        let height = displayMode.pixelHeight
        let refRate = displayMode.refreshRate
        prop = "\(width)x\(height) \(refRate) Hz"
    case .none:
        prop = ""
    }
    return prop
}

/** Set up a display streaming with default parameters and internal size */
func streamDisplay(
    displayId: CGDirectDisplayID,
    dispatchQueue: DispatchQueue,
    handler: CGDisplayStreamFrameAvailableHandler?
) -> CGDisplayStream? {
    var width: Int
    var height: Int
    switch CGDisplayCreateImage(displayId) {
    case .some(let render):
        width = render.width
        height = render.height
    case .none:
        switch CGDisplayCopyDisplayMode(displayId)
        {
        case .some(let displayMode):
            width = displayMode.pixelWidth
            height = displayMode.pixelHeight
        case .none:
            width = 1920
            height = 1080
        }
    }
    return CGDisplayStream(
        dispatchQueueDisplay: displayId,
        outputWidth: width,
        outputHeight: height,
        pixelFormat: Int32(k32BGRAPixelFormat),
        /* Use the whole surface, preserve aspect ratio, show cursor */
        properties: nil,
        queue: dispatchQueue,
        handler: handler
    )
}
