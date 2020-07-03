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
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        EventHandler.shared.stop()
    }


}

