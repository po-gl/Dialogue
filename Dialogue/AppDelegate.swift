//
//  AppDelegate.swift
//  Dialogue
//
//  Created by Porter Glines on 2/11/23.
//

#if os(OSX)
import Foundation
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
#endif
