//
//  ViewController.swift
//  HalfKeyboard
//
//  Created by Zev Eisenberg on 7/1/20.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }

    @IBAction func checkBoxChanged(_ sender: NSButton) {
        switch sender.state {
        case .on:
            if EventHandler.shared.start() {
                print("started event handler")
            }
            else {
                print("error starting event handler")
            }
        case .off, .mixed:
            fallthrough
        default:
            EventHandler.shared.stop()
        }
    }

}

