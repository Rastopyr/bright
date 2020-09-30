//
//  ConnectorService.swift
//  Bright
//
//  Created by Roman on 18.06.2020.
//

import Cocoa
import SwiftUI
import RxSwift

class ConnectorService {
    let windowService: WindowService;
    let displayService: DisplayService;
    let rootView: BrightApp;
    let disposeBag = DisposeBag();
    
    init(windowService: WindowService, displayService: DisplayService, brightView: BrightApp) {
        self.windowService = windowService
        self.displayService = displayService
        self.rootView = brightView
    }
    
    public func onActivate() -> Void {
        self.windowService.createWindow(options: CreateWindowOptions(hasCloseButton: true, draggable: true, title: "main"))
        self.windowService.updateWindowVisiblState(title: "main", isVisible: true)
        self.windowService.updateWindowSize(title: "main", size: NSSize(width: 200, height: 200))
        self.windowService.updateWindowPosition(title: "main", point: NSPoint(x: 200, y: 200))
        
        self.windowService.createWindow(options: CreateWindowOptions(hasCloseButton: false, draggable: true, title: "main2"))
        self.windowService.updateWindowVisiblState(title: "main2", isVisible: true)
        self.windowService.updateWindowSize(title: "main2", size: NSSize(width: 200, height: 200))
        self.windowService.updateWindowPosition(title: "main2", point: NSPoint(x: 200, y: 200))
        
        
        let view = NSHostingView(rootView: rootView.edgesIgnoringSafeArea(Edge.Set.top))
        self.windowService.updateView(title: "main", view: view)
        
        let view2 = NSHostingView(rootView: rootView.edgesIgnoringSafeArea(Edge.Set.top))
        self.windowService.updateView(title: "main2", view: view2)

        self.displayService.syncDisplays()
        
    }
    
    public func onDeactivate() -> Void {
    }
}
