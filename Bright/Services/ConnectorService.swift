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
        self.windowService.createWindow(title: "main")
        self.windowService.updateWindowVisiblState(title: "main", isVisible: true)
//        self.windowService.updateWindowSize(title: "main", size: NSSize(width: 0, height: 0))
//        self.windowService.updateWindowSize(title: "main", size: NSSize(width: 1000, height: 1000))
        self.windowService.updateWindowPosition(title: "main", size: NSPoint(x: 0, y: 1000))
        
        let view = NSHostingView(rootView: rootView)
        self.windowService.updateView(title: "main", view: view)
        
        Observable.interval(RxTimeInterval.milliseconds(150), scheduler: MainScheduler.asyncInstance).take(10).do { (time: Int) in
            
            self.windowService.updateWindowSize(title: "main", size: NSSize(width: time * 10, height: time * 100))
            self.windowService.updateWindowPosition(title: "main", size: NSPoint(x: 0, y: time * 100))
        }.subscribe().disposed(by: disposeBag)
        
        self.displayService.syncDisplays()
        
    }
    
    public func onDeactivate() -> Void {
    }
}
