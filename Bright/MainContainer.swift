//
//  Container.swift
//  Bright
//
//  Created by Roman on 29.06.2020.
//

import AppKit
import Swinject
import RxSwift

class MainContainer: ObservableObject {
    public static let shared: MainContainer = {
        return MainContainer()
    }()
    
    public let container: Container = {
        let container = Container()
        
        container.register(NSApplication.self) { _ in NSApp }.inObjectScope(.container)
        container.register(AppService.self) { c in AppService(appInstance: c.resolve(NSApplication.self)!) }.inObjectScope(.container)
        container.register(BrightnessSerivce.self) { _ in BrightnessSerivce() }.inObjectScope(.container)
        container.register(DisplayService.self) { _ in DisplayService(brightnessService: BrightnessSerivce()) }.inObjectScope(.container)
        container.register(Observable.self, name: "displays$") { c in c.resolve(DisplayService.self)!.displays$ }.inObjectScope(.container)
        
        container.register(WindowService.self) { _ in WindowService( ) }.inObjectScope(.container)

        container.register(BrightApp.self) { c in
            let view = BrightApp(DI: MainContainer.shared)
            return view
        }.inObjectScope(.container)
        
        container.register(MediaKeyTapService.self) { _ in MediaKeyTapService() }
        
        container.register(ConnectorService.self) { c in ConnectorService(
            windowService: c.resolve(WindowService.self)!,
            displayService: c.resolve(DisplayService.self)!,
            brightView: c.resolve(BrightApp.self)!
        )}.inObjectScope(.container)
        
        container.register(MediaKeyObserver.self) { c in MediaKeyObserver.init(mediaKeyservice: c.resolve(MediaKeyTapService.self)!, appService: c.resolve(AppService.self)!) }
        
        return container
    }()
    
    private init() {}
}
