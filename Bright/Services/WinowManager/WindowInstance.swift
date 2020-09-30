//
//  WindowInstance.swift
//  Bright
//
//  Created by Roman on 29.09.2020.
//

import Foundation
import RxSwift
import Cocoa

enum Events {
    case updateSize(NSSize)
    case updatePosition(NSPoint)
    case updateView(NSView)
    case updateVisibility(Bool)
}

struct CreateWindowOptions {
    let hasCloseButton: Bool;
    let draggable: Bool;
    let title: String;
}

class WindowInstance {
    public let title: String;
    private let disposeBag = DisposeBag()
    
    private let state$: Observable<NSWindow>
    
    public let onPositionChange$: Observable<NSPoint>
    public let onSizeChange$: Observable<NSSize>
    
    public let position$: PublishSubject<NSPoint>
    public let size$: PublishSubject<NSSize>
    public let view$: PublishSubject<NSView>
    
    public let isVisible$: PublishSubject<Bool>;
    
    init(options: CreateWindowOptions) {
        self.position$ = PublishSubject<NSPoint>();
        self.size$ = PublishSubject<NSSize>();
        self.view$ = PublishSubject<NSView>();
        self.isVisible$ = PublishSubject<Bool>();
        
        self.onSizeChange$ = self.size$.asObservable();
        self.onPositionChange$ = self.position$.asObservable();
        
        self.title = options.title;
        
        self.state$ = Observable.merge(
            self.size$.map({ Events.updateSize($0) }),
            self.position$.map({ Events.updatePosition($0) }),
            self.view$.map({ Events.updateView($0) }),
            self.isVisible$.map({ Events.updateVisibility($0) })
        ).scan(WindowInstance.createWndow(options: options), accumulator: { (win: NSWindow, event: Events) -> NSWindow in
            switch (event) {
                case let .updateSize(size):
                    win.setFrame(
                        NSRect(
                            x: win.frame.origin.x,
                            y: win.frame.origin.y,
                            width: size.width,
                            height: size.height
                        ),
                        display: true,
                        animate: false
                    )
                    
                    return win;
                case let .updatePosition(point):
                    win.setFrameTopLeftPoint(point)
                    return win
                case let .updateView(view):
                    let visualEffect = NSVisualEffectView()
                    visualEffect.blendingMode = .behindWindow
                    visualEffect.state = .active
                    visualEffect.material = .ultraDark

                    visualEffect.setFrameSize(NSSize(width: win.frame.width, height: win.frame.height))
                    view.setFrameSize(NSSize(width: win.frame.width, height: win.frame.height))

                    let parentView = NSView();

                    parentView.addSubview(visualEffect)
                    parentView.addSubview(view)

                    parentView.wantsLayer = true
                    parentView.layer?.cornerRadius = 14.0
                    parentView.layer?.masksToBounds = true

                    
                    win.contentView = parentView
                    
                    return win
                case let .updateVisibility(isVisible):
                    win.setIsVisible(isVisible)
                    return win
            }
        }).share()
        
        self.state$.subscribe().disposed(by: disposeBag)
    }
    
    private static func createWndow(options: CreateWindowOptions) -> NSWindow {
        let newWindow = NSWindow(
            contentRect: .init(
                origin: .zero,
                size: .init(
                    width: 0,
                    height: 0
            )),
            
            styleMask: [],
            
            backing: .buffered,
            defer: false
        )

//        newWindow.showsToolbarButton = false
        
//        if options.hasCloseButton {
//
//            newWindow.styleMask.insert(.closable)
//            newWindow.styleMask.insert(.titled)
//
//            newWindow.standardWindowButton(NSWindow.ButtonType.miniaturizeButton)?.isHidden = true
//            newWindow.standardWindowButton(NSWindow.ButtonType.zoomButton)?.isHidden = true
//
//
//            newWindow.toolbar?.isVisible = false
//            newWindow.titlebarAppearsTransparent = true
//            newWindow.titleVisibility = .hidden
//
//            newWindow.appearance = NSAppearance(appearanceNamed: NSAppearance.Name.vibrantDark, bundle: nil)
//
//
//        }
//
//        newWindow.isMovableByWindowBackground = options.draggable
        
        if options.hasCloseButton {
            newWindow.styleMask.insert(.closable)
            newWindow.styleMask.insert(.titled)
            newWindow.styleMask.insert(.fullSizeContentView)
            
            newWindow.titlebarAppearsTransparent = true
            newWindow.titleVisibility = .hidden

            newWindow.standardWindowButton(.miniaturizeButton)!.isHidden = true
            newWindow.standardWindowButton(.zoomButton)!.isHidden = true
        }

        newWindow.isMovableByWindowBackground = true

        newWindow.isOpaque = false
        newWindow.backgroundColor = .clear
        
        newWindow.makeKeyAndOrderFront(nil)
        
        return newWindow
    }
}
