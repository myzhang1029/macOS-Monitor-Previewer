//
//  DisplayProperty.swift
//  Monitor Preview
//
//  Created by Maiyun Zhang on 2026-06-05.
//

import AppKit
import CoreGraphics
import ScreenCaptureKit

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
        var width: Int?
        var height: Int?
        var refreshRate: Double?
        var localizedName: String?
        let prop = NSDeviceDescriptionKey(rawValue: "NSScreenNumber")
        for nsScreen in NSScreen.screens {
            guard let screenId = nsScreen.deviceDescription[prop] as? CGDirectDisplayID else {
                continue
            }
            if screenId == display.displayID {
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

