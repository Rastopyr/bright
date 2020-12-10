//
//  WindowSerivce.swift
//  Bright
//
//  Created by Roman on 13.06.2020.
//

import Cocoa
import RxSwift

struct CreateWindowActionBody {
    let options: CreateWindowOptions;
}

struct DestroyWindowActionBody {
    let options: DestroyWindowOptions;
}

struct WindowVisibleStateActionBody {
    let title: String;
    let isVisible: Bool;
}

struct WindowSizeStateActionBody {
    let title: String;
    let size: NSSize;
}

struct WindowPositionActionBody {
    let title: String;
    let point: NSPoint;
}

struct WindowFrameStateActionBody {
    let title: String;
    let rect: NSRect;
}

struct WindowViewStateActionBody {
    let title: String;
    let view: NSView;
}

enum Event {
    case createWindow(CreateWindowActionBody)
    case destroyWindow(DestroyWindowActionBody)
    case windowVisible(WindowVisibleStateActionBody)
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
    case emptyEventBody(Event)
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

func reduceState(state: WindowServiceState, body: CreateWindowActionBody) throws -> WindowServiceState {
    let options = body.options

    if (state[options.title] != nil) {
        throw Errors.windowAlreadyCreated(options.title)
    }

    return state.set(options.title, WindowInstance(options: options))
}

func reduceState(state: WindowServiceState, body: DestroyWindowActionBody) throws -> WindowServiceState {
    let options = body.options

    if (state[options.title] == nil) {
        throw Errors.windowNotCreated(options.title)
    }
    
    let win = state[options.title]
    
    win?.destroy$.onNext(());
    
    let newState = state.delete(options.title)
    
    print(newState)
    
    return newState
}

func reduceState(state: WindowServiceState, body: WindowVisibleStateActionBody) throws -> WindowServiceState {
    let title = body.title
    let isVisible = body.isVisible

    let win: WindowInstance? = state[title]

    if (win == nil) {
       throw Errors.windowNotExist(title)
    }
    
    print(state)

    win?.isVisible$.onNext(isVisible)

    return state;
}


func reduceState(state: WindowServiceState, body: WindowSizeStateActionBody) throws -> WindowServiceState {
    let title = body.title
    let size = body.size

    let win: WindowInstance? = state[title]

    if (win == nil) {
        throw Errors.windowNotExist(title)
    }

    win!.size$.onNext(size)

    return state;
}

func reduceState(state: WindowServiceState, body: WindowSizeStateActionBody, animate: Bool) throws -> WindowServiceState {
    let title = body.title
    let size = body.size

    let win: WindowInstance? = state[title]

    if (win == nil) {
        throw Errors.windowNotExist(title)
    }

    win!.animateSize$.onNext(size)

    return state;
}

func reduceState(state: WindowServiceState, body: WindowViewStateActionBody) throws -> WindowServiceState {
    let title = body.title
    let view = body.view

    let win: WindowInstance? = state[title]

    if (win == nil) {
       throw Errors.windowNotExist(title)
    }

    win?.view$.onNext(view)

    return state
}

func reduceState(state: WindowServiceState, body: WindowPositionActionBody) throws -> WindowServiceState {
    let title = body.title
    let point = body.point

    let win: WindowInstance? = state[title]

    if (win == nil) {
       throw Errors.windowNotExist(title)
    }

    win?.position$.onNext(point)

    return state
}

func reduceState(state: WindowServiceState, body: WindowPositionActionBody, animate: Bool) throws -> WindowServiceState {
    let title = body.title
    let point = body.point

    let win: WindowInstance? = state[title]

    if (win == nil) {
       throw Errors.windowNotExist(title)
    }

    win?.animatePosition$.onNext(point)

    return state
}

func reduceState(state: WindowServiceState, body: WindowFrameStateActionBody) throws -> WindowServiceState {
    let title = body.title
    let rect = body.rect

    let win: WindowInstance? = state[title]

    if (win == nil) {
       throw Errors.windowNotExist(title)
    }

    win?.animateFrame$.onNext(rect)

    return state
}

func reduceState(state: WindowServiceState, body: Any) -> WindowServiceState {
    return state
}

class WindowService {
    private let state$: Observable<WindowServiceState>;
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let newWindow$: PublishSubject<CreateWindowOptions>
    private let destroyWindow$: PublishSubject<DestroyWindowOptions>
    
    private let isVisible$: PublishSubject<(title: String, isVisible: Bool)>
    private let size$: PublishSubject<(title: String, size: NSSize)>
    private let view$: PublishSubject<(title: String, view: NSView)>
    private let position$: PublishSubject<(title: String, point: NSPoint)>
    
    private let animateSize$: PublishSubject<(title: String, size: NSSize)>
    private let animatePosition$: PublishSubject<(title: String, point: NSPoint)>
    private let animateFrame$: PublishSubject<(title: String, rect: NSRect)>
    
    init() {
        self.destroyWindow$ = PublishSubject<DestroyWindowOptions>()
        self.newWindow$ = PublishSubject<CreateWindowOptions>()
        self.isVisible$ = PublishSubject<(title: String, isVisible: Bool)>()
        self.size$ = PublishSubject<(title: String, size: NSSize)>()
        self.view$ = PublishSubject<(title: String, view: NSView)>()
        self.position$ = PublishSubject<(title: String, point: NSPoint)>()
        
        self.animateSize$ = PublishSubject<(title: String, size: NSSize)>()
        self.animatePosition$ = PublishSubject<(title: String, point: NSPoint)>()
        
        self.animateFrame$ = PublishSubject<(title: String, rect: NSRect)>()
    
        self.state$ = Observable.merge(
            self.newWindow$.map({ options in
                return Event.createWindow(CreateWindowActionBody(options: options))
            }),
            
            self.destroyWindow$.map({ options in
                return Event.destroyWindow(DestroyWindowActionBody(options: options))
            }),
            
            self.isVisible$.map({ payload in
                return Event.windowVisible(WindowVisibleStateActionBody(title: payload.title, isVisible: payload.isVisible))
            }),

            self.size$.map({ payload in
                return Event.windowSize(WindowSizeStateActionBody(title: payload.title, size: payload.size))
            }),

            self.view$.map({ payload in
                return Event.windowView(WindowViewStateActionBody(title: payload.title, view: payload.view))
            }),
            
            self.position$.map({ payload in
                return Event.windowPosition(WindowPositionActionBody(title: payload.title, point: payload.point))
            }),
            
            self.animateSize$.map({ payload in
                return Event.animateWindowSize(WindowSizeStateActionBody(title: payload.title, size: payload.size))
            }),
            
            self.animatePosition$.map({ payload in
                return Event.animateWindowPosition(WindowPositionActionBody(title: payload.title, point: payload.point))
            }),
            
            self.animateFrame$.map({ payload in
                return Event.animateWindowFrame(WindowFrameStateActionBody(title: payload.title, rect: payload.rect))
            })
        ).scan(WindowServiceState(), accumulator: { (state, event: Event) in
            switch(event) {
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
        
        self.state$.subscribe().disposed(by: disposeBag)
    }
    
    public func createWindow(options: CreateWindowOptions) {
        self.newWindow$.onNext(options);
    }
    
    public func destroyWindow(options: DestroyWindowOptions) {
        self.destroyWindow$.onNext(options);
    }
    
    public func updateWindowVisiblState(title: String, isVisible: Bool) {
        self.isVisible$.onNext((title, isVisible))
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
