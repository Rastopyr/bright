//
//  Bright.swift
//  Bright
//
//  Created by Roman on 28.05.2020.
//

import SwiftUI
import RxSwift



class DisplaysBinding: ObservableObject {
    private let disposeBag = DisposeBag();
    
    @Published var displays: [Display] = [];
    
    init(displays$: Observable<[Display]>) {
        displays$.subscribe(onNext: {
            self.displays = $0
        }, onDisposed: { print("dispose") }).disposed(by: disposeBag)
    }
    
    private func dispose() {
        self.disposeBag.
    }
}

struct BrightApp: View {
    private let displays$: Observable<[Display]>;

    init() {
        self.displays$ = AppDelegate.container.resolve(Observable.self, name: "displays$")!;
    }
    
    var body: some View {
        return BrightApp.BrightAppView(
            model: DisplaysBinding(displays$: self.displays$)
        )
    }
}

extension BrightApp {
    struct BrightAppView: View {
        @ObservedObject var model: DisplaysBinding;
        
        var body: some View {
            return ZStack {
                Rectangle().fill(Color.clear)
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
                }
            }
            .frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 0,
                maxHeight: .infinity
            ).clipped()
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
