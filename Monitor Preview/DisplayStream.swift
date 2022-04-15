//
//  DisplayStream.swift
//  Monitor Preview
//
//  Created by 张迈允 on 2022-04-15.
//

import AppKit
import Foundation
import CoreGraphics

/** Make it possible to use CGError as an Error */
extension CGError: Error {
    
}

/** Get an Array of active displays */
func getDisplays() -> Result<[CGDirectDisplayID], CGError> {
    let pDsplCnt = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
    /* Get the number of active displays. Race condition? */
    let result1 = CGGetOnlineDisplayList(UInt32.max, nil, pDsplCnt)
    if result1 != .success {
        return .failure(result1)
    }
    let displays = UnsafeMutablePointer<CGDirectDisplayID>.allocate(capacity: Int(pDsplCnt.pointee))
    /* Get active displays */
    let result2 = CGGetOnlineDisplayList(pDsplCnt.pointee, displays, pDsplCnt)
    if result2 != .success {
        return .failure(result2)
    }
    /* Convert result to a Swift Array */
    let displaysArr = Array(UnsafeBufferPointer(start: displays, count: Int(pDsplCnt.pointee)))
    return .success(displaysArr)
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
