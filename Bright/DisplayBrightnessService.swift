//
//  DisplayBrightnessService.swift
//  Bright
//
//  Created by Roman on 25.12.2020.
//

import Foundation
import RxSwift


internal struct SetBrightnessEvent {
    let displayId: CGDirectDisplayID;
    let brightness: Double;
}

private enum DisplayBrightnessEvent {
    case updateDsiplays([Display])
    case incrmentBrightness
    case decrementBrightness
    case setBrightness(SetBrightnessEvent)
}

private struct DisplayBrighnessState {
    let displays: [Display]
}

class DisplayBrightnessService {
    private let brightnessService: BrightnessSerivce
    private let displayService: DisplayService
    
    private let disposeBag = DisposeBag()
    private let state$: Observable<DisplayBrighnessState>
    
    private let incrementBrightness$ = PublishSubject<Void>()
    private let decrementBrightness$ = PublishSubject<Void>()
    private let setBrightness$ = PublishSubject<SetBrightnessEvent>()
    
    public let displays$: Observable<[Display]>
    
    init(
        brightnessService: BrightnessSerivce,
        displayService: DisplayService
    ) {
        self.brightnessService = brightnessService
        self.displayService = displayService
        
        self.state$ = Observable.merge(
            self.displayService.displays$.map({ DisplayBrightnessEvent.updateDsiplays($0) }),
            self.incrementBrightness$.map({ DisplayBrightnessEvent.incrmentBrightness }),
            self.decrementBrightness$.map({ DisplayBrightnessEvent.decrementBrightness }),
            self.setBrightness$.map({ event in DisplayBrightnessEvent.setBrightness(event) })
        ).scan(DisplayBrighnessState(displays: []), accumulator: { (state: DisplayBrighnessState, event: DisplayBrightnessEvent) -> DisplayBrighnessState in
            switch (event) {
                case .updateDsiplays(let displays):
                    return DisplayBrighnessState(displays: displays)
                    
                case .setBrightness(let event):
                    let display = state.displays.first { (display: Display) -> Bool in
                        return display.id == event.displayId
                    }
                    
                    if display == nil {
                        return state
                    }
                    
                    brightnessService.setBrightness(display: display!, brightnessValue: event.brightness)
                    
                    return DisplayBrighnessState(displays: state.displays.map({ display in
                        if (display.id != event.displayId) {
                            return display;
                        }
                        
                        return Display(
                            id: display.id,
                            name: display.name,
                            isNative: display.isNative,
                            brightness: event.brightness,
                            order: display.order,
                            size: display.size
                        )
                    }))
                    
                case .incrmentBrightness:
                    let mainDisplay = state.displays.first { (display: Display) -> Bool in
                        return display.isNative
                    }
                    
                    if mainDisplay == nil {
                        return state
                    }
                    
                    let newBrightnessValue =  mainDisplay!.brightness + 0.05
                    let newBrightness = newBrightnessValue > 1 ? 1 : newBrightnessValue
                    
                    state.displays.forEach { (display) in
                        brightnessService.setBrightness(display: display, brightnessValue: newBrightness)
                    }
                    
                    return DisplayBrighnessState(displays: state.displays.map({ (display) -> Display in
                        return Display(
                            id: display.id,
                            name: display.name,
                            isNative: display.isNative,
                            brightness: newBrightness,
                            order: display.order,
                            size: display.size
                        )
                    }))
                case .decrementBrightness:
                    let mainDisplay = state.displays.first { (display: Display) -> Bool in
                        return display.isNative
                    }
                    
                    if mainDisplay == nil {
                        return state
                    }
                    
                    let newBrightnessValue =  mainDisplay!.brightness - 0.05
                    let newBrightness = newBrightnessValue <= 0 ? 0 : newBrightnessValue
                    
                    state.displays.forEach { (display) in
                        brightnessService.setBrightness(display: display, brightnessValue: newBrightness)
                    }
                    
                    return DisplayBrighnessState(displays: state.displays.map({
                        Display(
                            id: $0.id,
                            name: $0.name,
                            isNative: $0.isNative,
                            brightness: newBrightness,
                            order: $0.order,
                            size: $0.size
                        )
                    }))
            }
        }).share(replay: 1, scope: .whileConnected)
        
        self.displays$ = self.state$.map({ $0.displays })

        disposeBag.insert([
            incrementBrightness$,
            decrementBrightness$,
            setBrightness$,
            self.state$.subscribe()
        ])
    }
    
    public func incrementBrightness() {
        incrementBrightness$.onNext(())
    }
    
    public func decrementBrightness() {
        decrementBrightness$.onNext(())
    }
    
    public func setBrightness(displayId: CGDirectDisplayID, brightness: Double) {
        setBrightness$.onNext(SetBrightnessEvent(
            displayId: displayId, brightness: brightness
        ))
    }
}
