//
//  ConnectorService.swift
//  Bright
//
//  Created by Roman on 18.06.2020.
//

import Cocoa
import SwiftUI
import RxSwift

class UserInterfaceService {
    let windowService: WindowService;
    let rootView: BrightApp;
    let disposeBag = DisposeBag();
    
    init(windowService: WindowService, brightView: BrightApp) {
        self.windowService = windowService
        self.rootView = brightView
    }
    
    public func onStart() -> Void {}
    

    public func onActivate() -> Void {
        self.windowService.createWindow(options: CreateWindowOptions(hasCloseButton: false, draggable: true, title: "main"))
        self.windowService.updateWindowVisiblState(title: "main", isVisible: true)
        self.windowService.updateWindowSize(title: "main", size: NSSize(width: 200, height: 200))
        self.windowService.updateWindowPosition(title: "main", point: NSPoint(x: 200, y: 200))

        let view = NSHostingView(rootView: rootView.edgesIgnoringSafeArea(Edge.Set.top))
        self.windowService.updateView(title: "main", view: view)
    }
    
    public func onDeactivate() -> Void {
        self.windowService.destroyWindow(options: DestroyWindowOptions(title: "main"))
    }
}
