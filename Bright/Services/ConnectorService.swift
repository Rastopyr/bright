//
//  ConnectorService.swift
//  Bright
//
//  Created by Roman on 18.06.2020.
//

import Cocoa

class ConnectorService {
    let windowService: WindowService;
    let displayService: DisplayService;
    
    init(windowService: WindowService, displayService: DisplayService) {
        self.windowService = windowService;
        self.displayService = displayService;
    }
    
    public func onActivate() -> Void {
        self.windowService.createWindow()
        
        self.displayService.syncDisplays()
        
    }
    
    public func onDeactivate() -> Void {
    }
}
