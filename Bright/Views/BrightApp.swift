//
//  Bright.swift
//  Bright
//
//  Created by Roman on 28.05.2020.
//

import SwiftUI
import RxSwift

func getScreenWithMouse() -> NSScreen? {
  let mouseLocation = NSEvent.mouseLocation
  let screens = NSScreen.screens
  let screenWithMouse = (screens.first { NSMouseInRect(mouseLocation, $0.frame, false) })

  return screenWithMouse
}

class DisplaysBinding: ObservableObject {
    private let disposeBag = DisposeBag();
    
    @Published var displays: [Display] = [];
    
    init(displays$: Observable<[Display]>) {
        displays$.subscribe(onNext: {
            self.displays = $0
        }).disposed(by: disposeBag)
    }
}

struct BrightApp: View {
    @ObservedObject var DI: MainContainer;
    @State var displays: [Display] = [];
    
    private let disposeBag = DisposeBag();
    
    var body: some View {
        let displays$ = DI.container.resolve(Observable<[Display]>.self, name: "displays$")!
        
        displays$.subscribe(onNext: {
            self.displays = $0
        }).disposed(by: disposeBag)
        
        return ForEach(displays, id: \.id) { (display: Display) in
            DisplaySliderControl(
               brightnessValue: display.brightness,
               displayName: display.name
            )
        }
    }
}

struct BrightApp_Previews: PreviewProvider {
    static var previews: some View {
        return BrightApp(
            DI: MainContainer.shared
        )
    }
}
