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
    
    private let container: Container = {
        let container = Container()
        
        container.register(AppService.self) { _ in AppService() }
        container.register(BrightnessSerivce.self) { _ in BrightnessSerivce() }
        container.register(DisplayService.self) { _ in DisplayService(brightnessService: BrightnessSerivce()) }
        
        return container
    }()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.buildStatusBar()
        
//        var fillPercent$ = Observable<Int>.interval(
//            .milliseconds(300), scheduler: scheduler
//        ).subscribe({ event in
//            print(event)
//        })
        
        let window = NSWindow(
            contentRect: .init(
                origin: .zero,
                size: .init(
                    width: WINDOW_WIDTH,
                    height: WINDOW_HEIGHT
            )),
            
            styleMask: [],
            
            backing: .buffered,
            defer: false
        )
        
        let visualEffect = NSVisualEffectView()
        visualEffect.blendingMode = .behindWindow
        visualEffect.state = .active
        visualEffect.material = .appearanceBased

        window.isOpaque = false
        window.backgroundColor = .clear
        window.hidesOnDeactivate = true

        let hosting = NSHostingView(rootView: ContentView())
        window.contentView = visualEffect
        visualEffect.addSubview(hosting)
        
        hosting.setFrameSize(NSSize(width: WINDOW_WIDTH, height: WINDOW_HEIGHT))
        
        window.center()
        window.setIsVisible(true)
        
//        let displaySerivce = container.resolve(DisplayService.self)!
//        
//        displaySerivce.syncDisplays()
//        displaySerivce.subscribeToDisplayChanges()
//        
//        let brightnessSerivce = container.resolve(BrightnessSerivce.self)!
//        
//        displaySerivce.displays.forEach { (display) in
//            brightnessSerivce.setBrightness(display: display, brightnessValue: 1.0)
//        }
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
        let appService = container.resolve(AppService.self)!
        
        appService.quit()
    }
}


struct AppDelegate_Previews: PreviewProvider {
    static var previews: some View {
        BrightApp()
    }
}
