//
//  DisplayServoce.swift
//  Bright
//
//  Created by Roman on 04.06.2020.
//

import Cocoa
import ObjectiveC
import Swift

var displayService: DisplayService!

class DisplayService {
    var displays: Array<Display> = []
    
    private let brightnessService: BrightnessSerivce;
    
    init(brightnessService: BrightnessSerivce) {
        self.brightnessService = brightnessService
        
        displayService = self
    }

    @objc
    func syncDisplays() {
        displays = NSScreen.screens.map({ (screen: NSScreen) -> Display in
            let displayID = (screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID)!
            
            let isNative = self.isNativeDisplay(displayID: displayID)
            
            return Display(
                id: displayID,
                name: screen.localizedName,
                isNative: isNative,
                brightness: brightnessService.getBrightness(
                    displayID: displayID,
                    isNative: isNative
                ),
                order: 0,
                size: screen.frame
            )
        })
    }
    
    func subscribeToDisplayChanges() {
        NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: NSApplication.shared,
            queue: OperationQueue.main) {
                notification -> Void in
                self.syncDisplays()
        }
        
        CGDisplayRegisterReconfigurationCallback({ _, _, _ in displayService.syncDisplays()}, nil)
    }
    
    private func isNativeDisplay(displayID: UInt32) -> Bool {
        print(displayID, CGDisplayIsBuiltin(displayID))
        return CGDisplayIsBuiltin(displayID) != 0
    }
}
