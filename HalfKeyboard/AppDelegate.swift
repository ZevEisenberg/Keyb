//
//  AppDelegate.swift
//  HalfKeyboard
//
//  Created by Zev Eisenberg on 7/1/20.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Make sure we have ability to intercept keys.
        // Via https://github.com/danielpunkass/Blockpass
        let promptFlag = kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString
        AXIsProcessTrustedWithOptions([promptFlag: true] as CFDictionary)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        EventHandler.shared.stop()
    }


}

