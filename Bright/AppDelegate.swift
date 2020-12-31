//
//  AppDelegate.swift
//  Bright
//
//  Created by Roman on 26.05.2020.
//

import Cocoa
import SwiftUI
import DDC
import RxSwift

var app: AppDelegate!

@NSApplicationMain
class AppDelegate: NSScreen, NSApplicationDelegate {
     private var statusMenu: NSMenu = NSMenu();
     private var statusItem: NSStatusItem = NSStatusBar.system.statusItem(
        withLength: NSStatusItem.variableLength
    )
    
    private let container = MainContainer.shared.container;
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let displaySerivce = container.resolve(DisplayService.self)!
        let observerService = container.resolve(MediaKeyObserver.self)!
        
        observerService.start()
        
        displaySerivce.subscribeToDisplayChanges()
        displaySerivce.syncDisplays()
        
        NSApplication.shared.setActivationPolicy(.accessory)
        
        self.buildStatusBar()
    }

    func applicationWillResignActive(_ aNotification: Notification) {
        let UI = container.resolve(UserInterfaceService.self)!
        UI.onDeactivate()
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        let UI = container.resolve(UserInterfaceService.self)!
        UI.onActivate()
    }
    
    private func buildStatusBar() {
        statusItem.button!.title = "🌗"
        statusItem.menu = statusMenu
        
        let titleItem = NSMenuItem()
        titleItem.title = NSLocalizedString("Bright", comment: "")
        titleItem.isEnabled = false
        
        titleItem.action = #selector(self.activate)

        statusMenu.insertItem(titleItem, at: 0)
        statusMenu.insertItem(NSMenuItem.separator(), at: 1)

        let quitItem = NSMenuItem()
        quitItem.title = NSLocalizedString("Quit", comment: " s")
        quitItem.isEnabled = true
        quitItem.target = self

        statusMenu.addItem(quitItem)

        quitItem.action = #selector(self.quit)
    }
    
    @objc private func activate() {
        let appService = container.resolve(AppService.self)!

        appService.activate()
    }
    
    @objc private func quit() {
        let appService = container.resolve(AppService.self)!
        
        appService.quit()
    }
}

