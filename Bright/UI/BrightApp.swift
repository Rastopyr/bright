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
        }, onDisposed: { print("dispose") }).disposed(by: disposeBag)
    }
}

struct BrightApp: View {
    @ObservedObject var DI: MainContainer;
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle().fill(Color.clear).frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                Text("Hello Bright")
            }
        }
    }
}

extension BrightApp {
    struct BrightAppView: View {
        @ObservedObject var model: DisplaysBinding;
        
        var body: some View {
            return ZStack {
                Rectangle().fill(Color.white)
                HStack {
                    ForEach(model.displays, id: \.id) { (display: Display) in
                        VStack {
                            Text(display.name)
                            BrightControl(
                            fillPercent: display.brightness, displayID: display.id) { (id, value) in
                                print(id, value)
                            }

                        }
                    }
                    
                    SelectControl(
                        list: ["by NightShift", "by time range", "disable"]
                    ).frame(width: 200 , height: 400)   
                }
            }
        }
    }
}

struct BrightApp_Previews: PreviewProvider {
    static var previews: some View {
        let displays$ = ReplaySubject<[Display]>.create(bufferSize: 1)
        let ds$ = displays$.asObservable()

        let d = [
            Display(
                id: 1,
                name: "Built-in Display",
                isNative: true,
                brightness: 0.3,
                order: 1,
                size: NSRect(x: 1, y: 1, width: 1, height: 1)
            )
        ]
        
        
        let view = BrightApp.BrightAppView(model: DisplaysBinding(displays$: ds$))
        
        displays$.onNext(d)
        
        return view
    }
}
