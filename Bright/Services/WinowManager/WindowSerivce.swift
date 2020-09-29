//
//  WindowSerivce.swift
//  Bright
//
//  Created by Roman on 13.06.2020.
//

import Cocoa
import RxSwift

struct CreateWindowActionBody {
    let title: String;
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

struct WindowViewStateActionBody {
    let title: String;
    let view: NSView;
}

enum Event {
    case createWindow(CreateWindowActionBody)
    case windowVisible(WindowVisibleStateActionBody)
    case windowSize(WindowSizeStateActionBody)
    case windowPosition(WindowPositionActionBody)
    case windowView(WindowViewStateActionBody)
}

enum Errors: Error {
    case windowAlreadyCreated(String)
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
}

func reduceState(state: WindowServiceState, body: CreateWindowActionBody) throws -> WindowServiceState {
    let title = body.title

    if (state[title] != nil) {
        throw Errors.windowAlreadyCreated(title)
    }

    return state.set(title, WindowInstance(title: title))
}

func reduceState(state: WindowServiceState, body: WindowVisibleStateActionBody) throws -> WindowServiceState {
    let title = body.title
    let isVisible = body.isVisible

    let win: WindowInstance? = state[title]

    if (win == nil) {
       throw Errors.windowNotExist(title)
    }

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

func reduceState(state: WindowServiceState, body: Any) -> WindowServiceState {
    return state
}

class WindowService {
    private let state$: Observable<WindowServiceState>;
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let newWindow$: PublishSubject<String>
    private let isVisible$: PublishSubject<(title: String, isVisible: Bool)>
    private let size$: PublishSubject<(title: String, size: NSSize)>
    private let view$: PublishSubject<(title: String, view: NSView)>
    private let position$: PublishSubject<(title: String, point: NSPoint)>
    
    init() {
        self.newWindow$ = PublishSubject<String>()
        self.isVisible$ = PublishSubject<(title: String, isVisible: Bool)>()
        self.size$ = PublishSubject<(title: String, size: NSSize)>()
        self.view$ = PublishSubject<(title: String, view: NSView)>()
        self.position$ = PublishSubject<(title: String, point: NSPoint)>()
    
        self.state$ = Observable.merge(
            self.newWindow$.map({ title in
                return Event.createWindow(CreateWindowActionBody(title: title))
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
            })
        ).scan(WindowServiceState(), accumulator: { (state, event: Event) in
            switch(event) {
                case let .createWindow(value):
                    return try reduceState(state: state, body: value)
                case let .windowVisible(value):
                    return try reduceState(state: state, body: value)
                case let .windowSize(value):
                    return try reduceState(state: state, body: value)
                case let .windowView(value):
                    return try reduceState(state: state, body: value)
                case let .windowPosition(value):
                    return try reduceState(state: state, body: value)
            }
        })
        
        self.state$.subscribe().disposed(by: disposeBag)
    }
    
    public func createWindow(title: String) {
        self.newWindow$.onNext(title);
    }
    
    public func updateWindowVisiblState(title: String, isVisible: Bool) {
        self.isVisible$.onNext((title, isVisible))
    }
    
    public func updateWindowSize(title: String, size: NSSize) {
        self.size$.onNext((title, size))
    }
    
    public func updateView(title: String, view: NSView) {
        self.view$.onNext(( title, view ))
    }
    
    public func updateWindowPosition(title: String, size: NSPoint) {
        self.position$.onNext((title: title, point: size))
    }
}