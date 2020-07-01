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
        if EventHandler.shared.start() {
            print("started event handler")
        }
        else {
            print("error starting event handler")
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        EventHandler.shared.stop()
    }


}

