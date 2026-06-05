//
//  scGetDisplays.swift
//  Monitor Preview
//
//  Created by Maiyun Zhang on 2026-06-05.
//

import ScreenCaptureKit

/** Get an Array of active displays */
func scGetDisplays() async -> [SCDisplay] {
    guard let shareable = try? await SCShareableContent.current else {
        return []
    }
    return shareable.displays
}
