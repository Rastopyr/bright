//
//  DisplaySliderControlList.swift
//  Bright
//
//  Created by Roman on 02.01.2021.
//

import SwiftUI
import RxSwift

class DisplayContainer: ObservableObject {
    @Published var displays: [DisplaySliderData] = []
    
    private let disposeBag = DisposeBag()
    private var state$: Observable<[DisplaySliderData]>?
    
    func subscribe(displays$: Observable<[Display]>) {
        self.state$ = displays$
            .scan([], accumulator: { (state: [DisplaySliderData], event: [Display]) -> [DisplaySliderData] in
                let newState = event.map({ display -> DisplaySliderData in
                    let displayInState = state.first(where: { (dsd) -> Bool in
                        return dsd.displayId == display.id
                    })
                    
                    if displayInState == nil {
                        return DisplaySliderData(
                            displayId: display.id,
                            value: display.brightness,
                            label: display.name
                        )
                    }
                    
                    if displayInState!.value == display.brightness {
                        return displayInState!
                    }
                    
                    displayInState!.value = display.brightness
                    
                    return displayInState!
                })
                
                return newState
            }).do(onNext: { state in self.displays = state })
                
        
        disposeBag.insert([
            self.state$!.subscribe()
        ])
    }
}

struct DisplaySliderControlList: View {
    @Environment(\.displayBrightnessService) var displayBrightnessService
    
    @ObservedObject var model = DisplayContainer()
    
    private let disposeBag = DisposeBag()
    
    private func updateBrightnessValue(displayId: CGDirectDisplayID, brightness: Double) -> Void {
        displayBrightnessService!.setBrightness(displayId: displayId, brightness: brightness)
    }
    
    var body: some View {
        return ForEach(model.displays, id: \.id) { displayData in
            DisplaySliderControl(
                onChange: { updatedBrightness in
                    updateBrightnessValue(displayId: displayData.displayId, brightness: updatedBrightness)
                }
            ).environmentObject(displayData)
        }.onAppear(perform: { model.subscribe(displays$: displayBrightnessService!.displays$) })
    }
}

struct DisplaySliderControlList_Previews: PreviewProvider {
    static var previews: some View {
        return Rectangle()
    }
}
