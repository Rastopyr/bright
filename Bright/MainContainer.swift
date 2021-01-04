//
//  Container.swift
//  Bright
//
//  Created by Roman on 29.06.2020.
//

import AppKit
import Swinject
import RxSwift
import SwiftUI

private struct DisplayBrightnessServiceEnvironmentKey: EnvironmentKey {
    static var defaultValue: DisplayBrightnessService?
}

extension EnvironmentValues {
    var displayBrightnessService: DisplayBrightnessService? {
        get { self[DisplayBrightnessServiceEnvironmentKey.self] }
        set { self[DisplayBrightnessServiceEnvironmentKey.self] = newValue }
    }
}

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
        
        container.register(WindowService.self) { _ in WindowService( ) }.inObjectScope(.container)
        
        container.register(MediaKeyTapService.self) { _ in MediaKeyTapService() }.inObjectScope(.container)
        
        container.register(DisplayBrightnessService.self) { c in DisplayBrightnessService(
            brightnessService: c.resolve(BrightnessSerivce.self)!,
            displayService: c.resolve(DisplayService.self)!
        ) }.inObjectScope(.container)
        
        container.register(UserInterfaceService.self) { c in UserInterfaceService(
            windowService: c.resolve(WindowService.self)!,
            displayBrightnessService: c.resolve(DisplayBrightnessService.self)!
        )}.inObjectScope(.container)
        
        container.register(MediaKeyObserver.self) { c in MediaKeyObserver.init(
            mediaKeyservice: c.resolve(MediaKeyTapService.self)!,
            appService: c.resolve(AppService.self)!,
            displayBrightnessService: c.resolve(DisplayBrightnessService.self)!
        ) }.inObjectScope(.container)
        
        return container
    }()
    
    private init() {}
}
