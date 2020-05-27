//
//  AppDelegate.swift
//  Bright
//
//  Created by Roman on 26.05.2020.
//

import Cocoa
import SwiftUI

var app: AppDelegate!


@NSApplicationMain
class AppDelegate: NSScreen, NSApplicationDelegate {

//    var window: NSWindow!
        
    private var displays: Array<Display> = []

    private var statusMenu: NSMenu = NSMenu();
    private var statusItem: NSStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        app = self;
        guard let statusButton = statusItem.button else { return }
        statusButton.title = "🌗"
        
        self.statusItem.menu = self.statusMenu
        
        self.syncDisplays()
        self.subscribeToDisplayChanges()
        
        
        
        self.buildMenu();
        
        NSApp.setActivationPolicy(.accessory)
    }
    
    private func getDisplayBrightness(displayID: UInt32) -> Float {
        var brightness: Float = 1.0
        var service: io_object_t = displayID
        let iterator: io_iterator_t = 0

        service = IOIteratorNext(iterator)
        IODisplayGetFloatParameter(service, 0, kIODisplayBrightnessKey as CFString, &brightness)
        IOObjectRelease(service)
        
        return brightness
    }
    
    

    @objc
    private func syncDisplays() {
        displays = NSScreen.screens.map({ (screen: NSScreen) -> Display in
            return Display(
                name: screen.localizedName,
                brightness: self.getDisplayBrightness(
                    displayID: (screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID)!
                ),
                order: 0)
        })
        
        print(displays)
    }
    
    private func syncBrightness() {
        
    }
    
    private func subscribeToDisplayChanges() {
        NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: NSApplication.shared,
            queue: OperationQueue.main) {
                notification -> Void in
                self.syncDisplays()
        }
        
        CGDisplayRegisterReconfigurationCallback({ _, _, _ in app.syncDisplays() }, nil)
    }
    private func subscribeToBrightnessChanges() {}
    
    private func buildMenu() {
        let titleItem = NSMenuItem()
        titleItem.title = NSLocalizedString("Bright", comment: "on your face")
        titleItem.isEnabled = true
        
        self.statusMenu.insertItem(titleItem, at: 0)
        self.statusMenu.insertItem(NSMenuItem.separator(), at: 1)
        
        let quitItem = NSMenuItem()
        quitItem.title = NSLocalizedString("Quit", comment: "to dark time")
        quitItem.isEnabled = true
        
        self.statusMenu.addItem(quitItem);
        
        quitItem.action = #selector(self.quitApp)
    }
    
    @objc
    private func quitApp() {
        NSApplication.shared.terminate(self)
    }
}


struct AppDelegate_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
