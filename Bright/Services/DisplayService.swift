//
//  DisplayServoce.swift
//  Bright
//
//  Created by Roman on 04.06.2020.
//

import Cocoa
import ObjectiveC
import RxSwift

var displayService: DisplayService!

enum DisplayServiceEventTypes {
    case DisplaySync, DisplayBrightnessUpdate
}

struct DisplaySyncEvent {
    let type = DisplayServiceEventTypes.DisplaySync;
    let displays: [Display];
}

struct DisplayBrightnessUpdateEvent {
    let type = DisplayServiceEventTypes.DisplayBrightnessUpdate;
    let displayId: CGDirectDisplayID;
    let displayValue: Double;
}

struct DisplayServiceState {
    var displays: [Display];
}

// displaySync -> DisplaySyncEvent -> displays$
// displayBrightnessUpdate -> DisplayBrightnessUpdateEvent -> displays$

class DisplayService {
    private let brightnessService: BrightnessSerivce;
    
    var displays$: Observable<[Display]>;
    var displayUpdates$: PublishSubject<[Display]>;
    var brightnessUpdate$: Observable<(displayId: CGDirectDisplayID, brightness: Double)>;
    
    init(brightnessService: BrightnessSerivce) {
        
        self.brightnessService = brightnessService
        
        self.displayUpdates$ = PublishSubject()
        self.brightnessUpdate$ = PublishSubject()
        self.displays$ = PublishSubject()
        
        
        displayService = self
        

        self.displays$ = displayUpdates$.share(replay: 1, scope: .forever).asObservable()
        
    }
    
    private func displaysReducer(state: [Display], event: DisplaySyncEvent) -> [Display] {
        return []
    }
    private func displaysReducer(state: [Display], event: DisplayBrightnessUpdateEvent) -> [Display] {
        return []
    }

    @objc
    func syncDisplays() {
        let d = NSScreen.screens.map({ (screen: NSScreen) -> Display in
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
        });
        
        displayUpdates$.onNext(d);
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
        return CGDisplayIsBuiltin(displayID) != 0
    }
}
