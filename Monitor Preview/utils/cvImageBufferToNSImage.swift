//
//  cvImageBufferToNSImage.swift
//  Monitor Preview
//
//  Created by Maiyun Zhang on 2026-06-05.
//

import AppKit
import CoreGraphics
import CoreImage

/** Convert CVImageBuffer to NSImage */
func cvImageBufferToNSImage(imageBuffer: CVImageBuffer) -> NSImage? {
    let context = CIContext()
    let ciImage = CIImage(cvPixelBuffer: imageBuffer)
    guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
        return nil
    }
    return NSImage(cgImage: cgImage, size: .zero)
}
