//
//  AppService.swift
//  Bright
//
//  Created by Roman on 04.06.2020.
//

import Cocoa

class AppService {
    public func quit() {
        NSApplication.shared.terminate(self)
    }
    
    public func activate() {
        NSApp.activate(ignoringOtherApps: true)
    }
}
