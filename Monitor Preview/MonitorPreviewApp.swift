//
//  Monitor_PreviewApp.swift
//  Monitor Preview
//
//  Created by Zhang Maiyun on 2022-04-15.
//

import AppKit
import Foundation
import SwiftUI

@main
struct MonitorPreviewApp: App {
    // Based on https://stackoverflow.com/a/65743682/9347959
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        true
    }
}
