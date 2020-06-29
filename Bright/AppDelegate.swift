//
//  AppDelegate.swift
//  Bright
//
//  Created by Roman on 26.05.2020.
//

import Cocoa
import SwiftUI
import Swinject
import DDC
import RxSwift

var app: AppDelegate!

let WINDOW_WIDTH = 750;
let WINDOW_HEIGHT = 315;


@NSApplicationMain
class AppDelegate: NSScreen, NSApplicationDelegate {
     private var statusMenu: NSMenu = NSMenu();
     private var statusItem: NSStatusItem = NSStatusBar.system.statusItem(
        withLength: NSStatusItem.variableLength
    )
    
    public static let container: Container = {
        let container = Container()
        
        container.register(AppService.self) { _ in AppService() }.inObjectScope(.container)
        container.register(BrightnessSerivce.self) { _ in BrightnessSerivce() }.inObjectScope(.container)
        container.register(DisplayService.self) { _ in DisplayService(brightnessService: BrightnessSerivce()) }.inObjectScope(.container)
        container.register(Observable.self, name: "displays$") { c in c.resolve(DisplayService.self)!.displays$ }.inObjectScope(.container)
       
        
        container.register(BrightApp.self) { c in
            BrightApp()
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
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let displaySerivce = AppDelegate.container.resolve(DisplayService.self)!
        
        displaySerivce.subscribeToDisplayChanges()
        displaySerivce.syncDisplays()
    }

    func applicationWillResignActive(_ aNotification: Notification) {
        let connectorService = AppDelegate.container.resolve(ConnectorService.self)!
               connectorService.onDeactivate()
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        let connectorService = AppDelegate.container.resolve(ConnectorService.self)!
        connectorService.onActivate()
    }
    
    private func buildStatusBar() {
        statusItem.button!.title = "🌗"
        statusItem.menu = statusMenu
        
        let titleItem = NSMenuItem()
        titleItem.title = NSLocalizedString("Bright", comment: "123")
        titleItem.isEnabled = false

        statusMenu.insertItem(titleItem, at: 0)
        statusMenu.insertItem(NSMenuItem.separator(), at: 1)

        let quitItem = NSMenuItem()
        quitItem.title = NSLocalizedString("Quit", comment: "123")
        quitItem.isEnabled = true
        quitItem.target = self

        statusMenu.addItem(quitItem)

        quitItem.action = #selector(self.quit)
    }
    
    @objc func quit() {
        let appService = AppDelegate.container.resolve(AppService.self)!
        
        appService.quit()
    }
}

