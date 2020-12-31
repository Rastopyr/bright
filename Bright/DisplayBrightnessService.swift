//
//  DisplayBrightnessService.swift
//  Bright
//
//  Created by Roman on 25.12.2020.
//

import Foundation
import RxSwift

private enum DisplayBrightnessEvent {
    case updateDsiplays([Display])
    case incrmentBrightness
    case decrementBrightness
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
    
    init(
        brightnessService: BrightnessSerivce,
        displayService: DisplayService
    ) {
        self.brightnessService = brightnessService
        self.displayService = displayService
        
        self.state$ = Observable.merge(
            self.displayService.displays$.map({ DisplayBrightnessEvent.updateDsiplays($0) }),
            self.incrementBrightness$.map({ DisplayBrightnessEvent.incrmentBrightness }),
            self.decrementBrightness$.map({ DisplayBrightnessEvent.decrementBrightness })
        ).scan(DisplayBrighnessState(displays: []), accumulator: { (state: DisplayBrighnessState, event: DisplayBrightnessEvent) -> DisplayBrighnessState in
            switch (event) {
                case .updateDsiplays(let displays):
                    return DisplayBrighnessState(displays: displays)
                    
                case .incrmentBrightness:
                    let mainDisplay = state.displays.first { (display: Display) -> Bool in
                        return display.isNative
                    }
                    
                    if mainDisplay == nil {
                        return state
                    }
                    
                    let newBrightness =  mainDisplay!.brightness + 0.1
                    
                    if (newBrightness > 1) {
                        return state;
                    }
                    
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
                    
                    let newBrightness =  mainDisplay!.brightness - 0.1
                    
                    if (newBrightness <= 0) {
                        return state;
                    }
                    
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
        }).share()
        
        let brightnessUpdate$ = self.state$.distinctUntilChanged({ (a, b) -> Bool in
            return a.displays.allSatisfy { (display) -> Bool in
                return b.displays.contains { (d) -> Bool in
                    return display.id == d.id && display.brightness == d.brightness
                }
            }
        }).do(onNext: { _ in displayService.syncDisplays() } )

        
        disposeBag.insert([
            incrementBrightness$,
            decrementBrightness$,
            self.state$.subscribe(),
            brightnessUpdate$.subscribe()
        ])
    }
    
    public func incrementBrightness() {
        incrementBrightness$.onNext(())
    }
    
    public func decrementBrightness() {
        decrementBrightness$.onNext(())
    }
}
