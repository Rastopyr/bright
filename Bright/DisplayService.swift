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

enum DisplayServiceDisplayServiceEventTypes {
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

internal struct BrighnessUpdateDisplayServiceEvent {
    let displayId: UInt32;
    let brightness: Double;
}

internal struct DisplaysUpdateDisplayServiceEvent {}


internal struct DisplayServiceState {
    var displays: [Display];
}

internal enum DisplayServiceEvent {
    case updateDisplays
    case brightnessUpdate(BrighnessUpdateDisplayServiceEvent)
}

internal func reduceDisplayServiceState(state: DisplayServiceState, event: DisplaysUpdateDisplayServiceEvent, brightnessService: BrightnessSerivce) -> DisplayServiceState {    
    let mainScreenBrightness = brightnessService.getBrightness(displayID: 0, isNative: true)
    
    let displays = NSScreen.screens.map({ (screen: NSScreen) -> Display in
        let displayId = (screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID)!
        
        let isNative =  CGDisplayIsBuiltin(displayId) != 0
        
        let displayBrightness = brightnessService.getBrightness(
            displayID: displayId,
            isNative: isNative
        )
        
        let brightness = displayBrightness == -1.0 ? mainScreenBrightness : displayBrightness

        return Display(
            id: displayId,
            name: screen.localizedName,
            isNative: isNative,
            brightness: brightness,
            order: 0,
            size: screen.frame
        )
    });
    
    return DisplayServiceState(displays: displays)
}

internal func reduceDisplayServiceState(state: DisplayServiceState, event: BrighnessUpdateDisplayServiceEvent) -> DisplayServiceState {
    return DisplayServiceState(
        displays: state.displays.map({ (display) -> Display in
            if (display.id == event.displayId) {
                return Display(
                    id: display.id,
                    name: display.name,
                    isNative: display.isNative,
                    brightness: event.brightness,
                    order: display.order,
                    size: display.size
                )
            }
            
            return display
        })
    )
}

class DisplayService {
    private let disposeBag = DisposeBag()
    private let brightnessService: BrightnessSerivce
    
    public let displays$: Observable<[Display]>
    
    private let displaysUpdate$ = PublishSubject<Void>()
    private let brightnessUpdate$ = PublishSubject<(displayId: CGDirectDisplayID, brightness: Double)>()
    
    private let state$: Observable<DisplayServiceState>
    
    init(brightnessService: BrightnessSerivce) {
        self.brightnessService = brightnessService
        
//        let updateInterval$ = Observable<Int>.interval(RxTimeInterval.seconds(3), scheduler: MainScheduler.asyncInstance)
        
        self.state$ = Observable.merge(
//            updateInterval$.map({ _ in DisplayServiceEvent.updateDisplays }),
            self.displaysUpdate$.map({ DisplayServiceEvent.updateDisplays }),
            self.brightnessUpdate$.map({ DisplayServiceEvent.brightnessUpdate(BrighnessUpdateDisplayServiceEvent(displayId: $0.displayId, brightness: $0.brightness)) })
        ).scan(DisplayServiceState(displays: []), accumulator: { (state: DisplayServiceState, event: DisplayServiceEvent) -> DisplayServiceState in
            switch (event) {
                case .updateDisplays:
                    return reduceDisplayServiceState(
                        state: state,
                        event: DisplaysUpdateDisplayServiceEvent(),
                        brightnessService: brightnessService
                    )
                case .brightnessUpdate(let brightnessDisplayServiceEvent):
                    return reduceDisplayServiceState(state: state, event: brightnessDisplayServiceEvent)
            }
        }).share(replay: 1, scope: .whileConnected)
        
        self.displays$ = self.state$.map({ $0.displays })
        
        disposeBag.insert([
            displaysUpdate$,
            brightnessUpdate$,
            self.state$.subscribe()
        ]);
        
        displayService = self;
    }

    public func syncDisplays() {
        displaysUpdate$.onNext(());
    }
    
    public func subscribeToDisplayChanges() {
        NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: NSApplication.shared,
            queue: OperationQueue.main
        ) { _ in self.syncDisplays() }
        
        
        CGDisplayRegisterReconfigurationCallback({ _, _, _ in displayService.syncDisplays()}, nil)
    }
}
