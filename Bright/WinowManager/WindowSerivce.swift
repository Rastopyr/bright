//
//  WindowSerivce.swift
//  Bright
//
//  Created by Roman on 13.06.2020.
//

import Cocoa
import RxSwift

internal struct CreateWindowActionBody {
    let options: CreateWindowOptions;
}

internal struct DestroyWindowActionBody {
    let options: DestroyWindowOptions;
}

internal struct ShowWindowActionBody {
    let title: String;
}

internal struct WindowSizeStateActionBody {
    let title: String;
    let size: NSSize;
}

internal struct WindowPositionActionBody {
    let title: String;
    let point: NSPoint;
}

internal struct WindowFrameStateActionBody {
    let title: String;
    let rect: NSRect;
}

internal struct WindowViewStateActionBody {
    let title: String;
    let view: NSView;
}

internal enum WindowServiceEvent {
    case createWindow(CreateWindowActionBody)
    case destroyWindow(DestroyWindowActionBody)
    case windowVisible(ShowWindowActionBody)
    case windowSize(WindowSizeStateActionBody)
    case windowPosition(WindowPositionActionBody)
    case windowView(WindowViewStateActionBody)
    
    case animateWindowSize(WindowSizeStateActionBody)
    case animateWindowPosition(WindowPositionActionBody)
    case animateWindowFrame(WindowFrameStateActionBody)
}

enum Errors: Error {
    case windowAlreadyCreated(String)
    case windowNotCreated(String)
    case windowNotExist(String)
    case emptyWindowServiceEventBody(WindowServiceEvent)
}

typealias WindowServiceState = [String: WindowInstance]

extension Dictionary {
    func set(_ key: Key, _ value: Value) -> [Key: Value] {
        var result = self
        result[key] = value
        return result
    }
    
    func delete(_ key: Key) -> [Key: Value] {
        var result = self;
        result[key] = nil
        return result
    }
}

private func reduceState(state: WindowServiceState, body: CreateWindowActionBody) throws -> WindowServiceState {
    let options = body.options

    if (state[options.title] != nil) {
        throw Errors.windowAlreadyCreated(options.title)
    }

    return state.set(options.title, WindowInstance(options: options))
}

private func reduceState(state: WindowServiceState, body: DestroyWindowActionBody) throws -> WindowServiceState {
    let options = body.options

    if (state[options.title] == nil) {
        throw Errors.windowNotCreated(options.title)
    }
    
    let win = state[options.title]
    
    win?.destroy$.onNext(());
    
    return state.delete(options.title)
}

private func reduceState(state: WindowServiceState, body: ShowWindowActionBody) throws -> WindowServiceState {
    let title = body.title

    let win: WindowInstance? = state[title]

    if (win == nil) {
       throw Errors.windowNotExist(title)
    }

    win?.show$.onNext(())

    return state;
}


private func reduceState(state: WindowServiceState, body: WindowSizeStateActionBody) throws -> WindowServiceState {
    let title = body.title
    let size = body.size

    let win: WindowInstance? = state[title]

    if (win == nil) {
        throw Errors.windowNotExist(title)
    }

    win!.size$.onNext(size)

    return state;
}

private func reduceState(state: WindowServiceState, body: WindowSizeStateActionBody, animate: Bool) throws -> WindowServiceState {
    let title = body.title
    let size = body.size

    let win: WindowInstance? = state[title]

    if (win == nil) {
        throw Errors.windowNotExist(title)
    }

    win!.animateSize$.onNext(size)

    return state;
}

private func reduceState(state: WindowServiceState, body: WindowViewStateActionBody) throws -> WindowServiceState {
    let title = body.title
    let view = body.view

    let win: WindowInstance? = state[title]

    if (win == nil) {
       throw Errors.windowNotExist(title)
    }

    win?.view$.onNext(view)

    return state
}

private func reduceState(state: WindowServiceState, body: WindowPositionActionBody) throws -> WindowServiceState {
    let title = body.title
    let point = body.point

    let win: WindowInstance? = state[title]

    if (win == nil) {
       throw Errors.windowNotExist(title)
    }

    win?.position$.onNext(point)

    return state
}

private func reduceState(state: WindowServiceState, body: WindowPositionActionBody, animate: Bool) throws -> WindowServiceState {
    let title = body.title
    let point = body.point

    let win: WindowInstance? = state[title]

    if (win == nil) {
       throw Errors.windowNotExist(title)
    }

    win?.animatePosition$.onNext(point)

    return state
}

private func reduceState(state: WindowServiceState, body: WindowFrameStateActionBody) throws -> WindowServiceState {
    let title = body.title
    let rect = body.rect

    let win: WindowInstance? = state[title]

    if (win == nil) {
       throw Errors.windowNotExist(title)
    }

    win?.animateFrame$.onNext(rect)

    return state
}

private func reduceState(state: WindowServiceState, body: Any) -> WindowServiceState {
    return state
}

class WindowService {
    private let state$: Observable<WindowServiceState>;
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let newWindow$: PublishSubject<CreateWindowOptions>
    private let destroyWindow$: PublishSubject<DestroyWindowOptions>
    private let showWindow$: PublishSubject<(String)>
    private let size$: PublishSubject<(title: String, size: NSSize)>
    private let view$: PublishSubject<(title: String, view: NSView)>
    private let position$: PublishSubject<(title: String, point: NSPoint)>
    
    private let animateSize$: PublishSubject<(title: String, size: NSSize)>
    private let animatePosition$: PublishSubject<(title: String, point: NSPoint)>
    private let animateFrame$: PublishSubject<(title: String, rect: NSRect)>
    
    init() {
        destroyWindow$ = PublishSubject<DestroyWindowOptions>()
        newWindow$ = PublishSubject<CreateWindowOptions>()
        showWindow$ = PublishSubject<(String)>()
        size$ = PublishSubject<(title: String, size: NSSize)>()
        view$ = PublishSubject<(title: String, view: NSView)>()
        position$ = PublishSubject<(title: String, point: NSPoint)>()
        
        animateSize$ = PublishSubject<(title: String, size: NSSize)>()
        animatePosition$ = PublishSubject<(title: String, point: NSPoint)>()
        
        animateFrame$ = PublishSubject<(title: String, rect: NSRect)>()
    
        state$ = Observable.merge(
            newWindow$.map({ options in
                return WindowServiceEvent.createWindow(CreateWindowActionBody(options: options))
            }),
            
            destroyWindow$.map({ options in
                return WindowServiceEvent.destroyWindow(DestroyWindowActionBody(options: options))
            }),
            
            showWindow$.map({ title in
                return WindowServiceEvent.windowVisible(ShowWindowActionBody(title: title))
            }),

            size$.map({ payload in
                return WindowServiceEvent.windowSize(WindowSizeStateActionBody(title: payload.title, size: payload.size))
            }),

            view$.map({ payload in
                return WindowServiceEvent.windowView(WindowViewStateActionBody(title: payload.title, view: payload.view))
            }),
            
            position$.map({ payload in
                return WindowServiceEvent.windowPosition(WindowPositionActionBody(title: payload.title, point: payload.point))
            }),
            
            animateSize$.map({ payload in
                return WindowServiceEvent.animateWindowSize(WindowSizeStateActionBody(title: payload.title, size: payload.size))
            }),
            
            animatePosition$.map({ payload in
                return WindowServiceEvent.animateWindowPosition(WindowPositionActionBody(title: payload.title, point: payload.point))
            }),
            
            animateFrame$.map({ payload in
                return WindowServiceEvent.animateWindowFrame(WindowFrameStateActionBody(title: payload.title, rect: payload.rect))
            })
        ).scan(WindowServiceState(), accumulator: { (state, WindowServiceEvent: WindowServiceEvent) in
            switch(WindowServiceEvent) {
                case .createWindow(let windowOptions):
                    return try reduceState(state: state, body: windowOptions)
                case .destroyWindow(let options):
                    return try reduceState(state: state, body: options)
                case .windowVisible(let isVisible):
                    return try reduceState(state: state, body: isVisible)
                case .windowSize(let size):
                    return try reduceState(state: state, body: size)
                case .windowView(let view):
                    return try reduceState(state: state, body: view)
                case .windowPosition(let point):
                    return try reduceState(state: state, body: point)
                case .animateWindowSize(let size):
                    return try reduceState(state: state, body: size, animate: true)
                case .animateWindowPosition(let point):
                    return try reduceState(state: state, body: point, animate: true)
                case .animateWindowFrame(let rect):
                    return try reduceState(state: state, body: rect)
            }
        }).share()

        disposeBag.insert([
            destroyWindow$,
            newWindow$,
            showWindow$,
            size$,
            view$,
            position$,
            animateSize$,
            animatePosition$,
            animateFrame$,
            state$.subscribe()
        ])
    }
    
    public func createWindow(options: CreateWindowOptions) {
        self.newWindow$.onNext(options);
    }
    
    public func destroyWindow(options: DestroyWindowOptions) {
        self.destroyWindow$.onNext(options);
    }
    
    public func updateWindowVisiblState(title: String, isVisible: Bool) {
        self.showWindow$.onNext((title))
    }
    
    public func updateWindowSize(title: String, size: NSSize) {
        self.size$.onNext((title, size))
    }
    
    public func animateWindowSize(title: String, size: NSSize) {
        self.animateSize$.onNext((title, size))
    }
    
    public func animateFrame(title: String, rect: NSRect) {
        self.animateFrame$.onNext((title, rect))
    }
    
    public func animateWindowPosition(title: String, point: NSPoint) {
        self.animatePosition$.onNext((title, point))
    }
    
    public func updateView(title: String, view: NSView) {
        self.view$.onNext(( title, view ))
    }
    
    public func updateWindowPosition(title: String, point: NSPoint) {
        self.position$.onNext((title: title, point: point))
    }
}
