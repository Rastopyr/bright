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
    
    case animateSize(NSSize)
    case animatePosition(NSPoint)
    case animateFrame(NSRect)
    
    case destroy
}

struct CreateWindowOptions {
    let hasCloseButton: Bool;
    let draggable: Bool;
    let title: String;
}

struct DestroyWindowOptions {
    let title: String;
}

struct WindowInstanceState {
    let win: NSWindow;
    var view: NSView?;
    var effectContainer: NSVisualEffectView?;
}

class WindowInstance {
    public let title: String;
    private var disposeBag = DisposeBag()
    
    private let state$: Observable<WindowInstanceState>
    
    public let onPositionChange$: Observable<NSPoint>
    public let onSizeChange$: Observable<NSSize>
    
    public let position$: PublishSubject<NSPoint>
    public let size$: PublishSubject<NSSize>
    public let animatePosition$: PublishSubject<NSPoint>
    public let animateSize$: PublishSubject<NSSize>
    public let animateFrame$: PublishSubject<NSRect>
    public let view$: PublishSubject<NSView>
    public let destroy$: PublishSubject<Void>
    
    public let isVisible$: PublishSubject<Bool>;
    
    init(options: CreateWindowOptions) {
        self.position$ = PublishSubject<NSPoint>()
        self.size$ = PublishSubject<NSSize>()
        self.view$ = PublishSubject<NSView>()
        self.isVisible$ = PublishSubject<Bool>()
        self.destroy$ = PublishSubject<Void>()
        
        self.onSizeChange$ = self.size$.asObservable()
        self.onPositionChange$ = self.position$.asObservable()
        
        self.animatePosition$ = PublishSubject<NSPoint>()
        self.animateSize$ = PublishSubject<NSSize>()
        
        self.animateFrame$ = PublishSubject<NSRect>()
        
        self.title = options.title;
        
        var win: NSWindow? = WindowInstance.createWndow(options: options);
        
        self.state$ = Observable.merge(
            self.size$.map({ Events.updateSize($0) }),
            self.position$.map({ Events.updatePosition($0) }),
            self.view$.map({ Events.updateView($0) }),
            self.isVisible$.map({ Events.updateVisibility($0) }),
            self.animatePosition$.map({ Events.animatePosition($0) }),
            self.animateSize$.map({ Events.animateSize($0) }),
            self.animateFrame$.map({ Events.animateFrame($0) }),
            self.destroy$.map({ Events.destroy })
        ).scan(
            WindowInstanceState(
                win: win!
            ),
            accumulator: { (state: WindowInstanceState, event: Events) -> WindowInstanceState in
                switch (event) {
                    case .updateSize(let size):
                        let win = state.win
                        
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
                        
                        return state;
                    case .updatePosition(let point):
                        let win = state.win
                        
                        win.setFrameTopLeftPoint(point)
                        
                        return state
                    case .updateView(let view):
                        let win = state.win
                        
                        let visualEffect = NSVisualEffectView()
                        visualEffect.blendingMode = .behindWindow
                        visualEffect.state = .active
                        visualEffect.material = .sidebar

                        visualEffect.setFrameSize(NSSize(width: win.frame.width, height: win.frame.height))
                        view.setFrameSize(NSSize(width: win.frame.width, height: win.frame.height))

                        let parentView = NSView();

                        parentView.addSubview(visualEffect)
                        parentView.addSubview(view)

                        parentView.wantsLayer = true
                        parentView.layer?.cornerRadius = 14.0
                        parentView.layer?.masksToBounds = true
                        
                        parentView.setFrameSize(NSSize(width: win.frame.width, height: win.frame.height))

                        win.contentView = parentView
                        
                        return WindowInstanceState(win: win, view: view, effectContainer: visualEffect)
                    case let .updateVisibility(isVisible):
                        let win = state.win

                        win.setIsVisible(isVisible)
                        return state
                        
                    case .animateSize(let size):
                        let win = state.win
        
//                        NSAnimationContext.runAnimationGroup({ [weak win] (context) in
//                            context.duration = 0.25
//
//                            win!.animator().setFrame(
//                                NSRect(
//                                    x: win!.frame.origin.x,
//                                    y: win!.frame.origin.y,
//                                    width: size.width,
//                                    height: size.height
//                                ),
//                                display: true,
//                                animate: true
//                            )
//
//                            win!.setContentSize(size)
//
//                            state.view?.animator().setFrameSize(size)
//                            state.effectContainer?.animator().setFrameSize(size)
//                        })
                        
                        return state
                    case .animatePosition(let point):
                        let win = state.win
                        
//                        NSAnimationContext.runAnimationGroup({ (context) in
//                            context.duration = 0.25
//
//                            win.animator().setFrameTopLeftPoint(point)
//                        })
                        
                        return state
                case .animateFrame(let rect):
                    let win = state.win
                    
//                    NSAnimationContext.runAnimationGroup({ (context) in
//                        context.duration = 0.25
//
//                        win.animator().setFrame(rect, display: true, animate: true)
//
//                        let size = NSSize(width: rect.width, height: rect.height)
//
//                        win.setContentSize(size)
//                        state.view?.animator().setFrameSize(size)
//                        state.effectContainer?.animator().setFrameSize(size)
//                    })
                    
                    return state
                case .destroy:
                    let win = state.win

                    win.setIsVisible(false)

                    return state
                }
            }).share()
        
        disposeBag.insert([
            self.size$,
            self.position$,
            self.view$,
            self.isVisible$,
            self.animatePosition$,
            self.animateSize$,
            self.animateFrame$,
            self.destroy$,
            self.state$.subscribe(onDisposed: {
                win = nil
                print("win disposed")
            })
        ])
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
        
        print(newWindow.canBecomeMain)
        
        return newWindow
    }
}
