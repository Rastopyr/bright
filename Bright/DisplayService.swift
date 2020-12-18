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

struct Display: Identifiable {
    let id: UInt32;
    let name: String;
    let isNative: Bool;
    var brightness: Double;
    var order: Int;
    var size: NSRect
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

class DisplayService {
    private let disposeBag = DisposeBag()
    private let brightnessService: BrightnessSerivce
    
    public let displays$: Observable<[Display]>
    
    private let displayUpdates$ = PublishSubject<[Display]>()
    private let brightnessUpdate$ = PublishSubject<(displayId: CGDirectDisplayID, brightness: Double)>()
    
    init(brightnessService: BrightnessSerivce) {
        self.brightnessService = brightnessService

        self.displays$ = displayUpdates$.share(replay: 1, scope: .forever).asObservable()
        
        disposeBag.insert([
            displayUpdates$,
            brightnessUpdate$
        ]);
    }

    @objc func syncDisplays() {
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
    
    private func isNativeDisplay(displayID: UInt32) -> Bool {
        return CGDisplayIsBuiltin(displayID) != 0
    }
    
    func subscribeToDisplayChanges() {
        NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: NSApplication.shared,
            queue: OperationQueue.main
        ) { _ in self.syncDisplays() }
        
        CGDisplayRegisterReconfigurationCallback({ _, _, _ in displayService.syncDisplays()}, nil)
    }
}
