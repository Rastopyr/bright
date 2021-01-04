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
    let windowService: WindowService
    let disposeBag = DisposeBag()
    
    let displayBrightnessService: DisplayBrightnessService
    
    init(windowService: WindowService, displayBrightnessService: DisplayBrightnessService) {
        self.windowService = windowService
        self.displayBrightnessService = displayBrightnessService
    }
    
    public func onStart() -> Void {}
    

    public func onActivate() -> Void {
        self.windowService.createWindow(options: CreateWindowOptions(hasCloseButton: false, draggable: true, title: "main"))
        self.windowService.updateWindowVisiblState(title: "main", isVisible: true)
        self.windowService.updateWindowSize(title: "main", size: NSSize(width: 600, height: 300))
        self.windowService.updateWindowPosition(title: "main", point: NSPoint(x: 500, y: 400))

        let view = NSHostingView(
            rootView: BrightApp()
                        .edgesIgnoringSafeArea(Edge.Set.top)
                        .environment(\.displayBrightnessService, displayBrightnessService)
        )
        
        self.windowService.updateView(title: "main", view: view)
    }
    
    public func onDeactivate() -> Void {
        self.windowService.destroyWindow(options: DestroyWindowOptions(title: "main"))
    }
}
