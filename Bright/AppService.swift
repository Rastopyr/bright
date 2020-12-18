//
//  AppService.swift
//  Bright
//
//  Created by Roman on 04.06.2020.
//

import Cocoa

class AppService {
    
    private let app: NSApplication;
    
    init(appInstance: NSApplication) {
        self.app = appInstance
    }
    
    public func quit() {
        app.terminate(self)
    }
    
    public func activate() {
        app.activate(ignoringOtherApps: true)
    }
    
    public func deactivate() {
        app.hide(nil)
        app.deactivate()
    }
}
