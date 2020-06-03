//
//  AppDelegate.swift
//  Bright
//
//  Created by Roman on 26.05.2020.
//

import Cocoa
import SwiftUI

var app: AppDelegate!

enum JustError: Error {
    case runtimeError(String)
}

let WINDOW_WIDTH = 750;
let WINDOW_HEIGHT = 315;


@NSApplicationMain
class AppDelegate: NSScreen, NSApplicationDelegate {
        
    private var displays: Array<Display> = []

    private var statusMenu: NSMenu = NSMenu();
    private var statusItem: NSStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    private var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        app = self;
        guard let statusButton = statusItem.button else { return }
        statusButton.title = "🌗"
        
        self.statusItem.menu = self.statusMenu
        
        self.syncDisplays()
        self.subscribeToDisplayChanges()
        
        
        
        self.buildMenu()
        self.buidUI()
        
        window.center()
        window.setIsVisible(true)
    }
    
    private func buidUI() {
        self.buildWindow()
    }
    
    private func buildWindow() -> Void {
        let mainView = BrightApp(
            onControlChanges: { self.setBrightnessForAll(val: $0) }
        )
//        let activeDisplay = self.getActiveDisplay()
        
        window = NSWindow(
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

        let hosting = NSHostingView(rootView: mainView)
        window.contentView = visualEffect
        visualEffect.addSubview(hosting)
        
        hosting.setFrameSize(NSSize(width: WINDOW_WIDTH, height: WINDOW_HEIGHT))
        
    }
    
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
    
    private func getActiveDisplay() -> Display {
        let activeDispay = displays.first { (d) -> Bool in
            return d.name == NSScreen.main?.localizedName
        }
        
        return activeDispay!
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
    
    @objc
    private func syncDisplays() {
        displays = NSScreen.screens.map({ (screen: NSScreen) -> Display in
            let displayID = (screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID)!;
            return Display(
                id: displayID,
                name: screen.localizedName,
                brightness: self.getBrightness(
                    displayID: displayID
                ),
                order: 0,
                size: screen.frame
            )
        })
    }
    
    private func subscribeToBrightnessChanges() {}
    
    private func syncBrightness() {
        
    }
    
    private func setBrightnessForAll(val: Float) -> Void {
        for display in displays {
            print(display)
            AppDelegate.CoreDisplaySetUserBrightness(display.id, Double(val))
        }
    }
    
    private static var CoreDisplaySetUserBrightness: ((CGDirectDisplayID, Double) -> Void) {
      let coreDisplayPath = CFURLCreateWithString(kCFAllocatorDefault, "/System/Library/Frameworks/CoreDisplay.framework" as CFString, nil)
        
        let coreDisplayBundle = CFBundleCreate(kCFAllocatorDefault, coreDisplayPath)
         let funcPointer = CFBundleGetFunctionPointerForName(coreDisplayBundle, "CoreDisplay_Display_SetUserBrightness" as CFString)
      typealias CDSUBFunctionType = @convention(c) (UInt32, Double) -> Void
      return unsafeBitCast(funcPointer, to: CDSUBFunctionType.self)
    }
    
    private func getBrightness(displayID: UInt32) -> Float {
        var brightness: Float = 1.0
        var service: io_object_t = displayID
        let iterator: io_iterator_t = 0

        service = IOIteratorNext(iterator)
        IODisplayGetFloatParameter(service, 0, kIODisplayBrightnessKey as CFString, &brightness)
        IOObjectRelease(service)
        
        return brightness
    }
    
    private func setBrightness(displayID: UInt32, val: Float) -> Void {
//        var service: io_object_t = displayID
//        let iterator: io_iterator_t = 0
        
        print("set val")
         print(displayID)
        print(val)

//        service = IOIteratorNext(iterator)
//        IODisplaySetFloatParameter(displayID, 0, kIODisplayBrightnessKey as CFString, val)
//        IOObjectRelease(displayID)
        
        let service = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IODisplayConnect"))
        
        IODisplaySetFloatParameter(service, 0, kIODisplayBrightnessKey as CFString, val)
        IOObjectRelease(service)
    }
    
    @objc
    private func quitApp() {
        NSApplication.shared.terminate(self)
    }
}


struct AppDelegate_Previews: PreviewProvider {
    static var previews: some View {
        BrightApp(onControlChanges: {_ in })
    }
}
