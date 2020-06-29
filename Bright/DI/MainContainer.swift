//
//  Container.swift
//  Bright
//
//  Created by Roman on 29.06.2020.
//


import Swinject
import RxSwift

class MainContainer: ObservableObject {
    public static let shared: MainContainer = {
        return MainContainer()
    }()
    
    public let container: Container = {
        let container = Container()
        
        container.register(AppService.self) { _ in AppService() }.inObjectScope(.container)
        container.register(BrightnessSerivce.self) { _ in BrightnessSerivce() }.inObjectScope(.container)
        container.register(DisplayService.self) { _ in DisplayService(brightnessService: BrightnessSerivce()) }.inObjectScope(.container)
        container.register(Observable.self, name: "displays$") { c in c.resolve(DisplayService.self)!.displays$ }.inObjectScope(.container)

        container.register(BrightApp.self) { c in
            let view = BrightApp(DI: MainContainer.shared)
            return view
        }.inObjectScope(.container)
        
        container.register(WindowService.self) { c in WindowService(
                   mainView: c.resolve(BrightApp.self)!
               )
        }.inObjectScope(.container)
        
        container.register(ConnectorService.self) { c in ConnectorService(
            windowService: c.resolve(WindowService.self)!,
            displayService: c.resolve(DisplayService.self)!
        )}.inObjectScope(.container)
        
        return container
    }()
    
    private init() {}
}