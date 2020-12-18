//
//  MediaKeyTapService.swift
//  Bright
//
//  Created by Roman on 11.12.2020.
//

import Foundation
import MediaKeyTap
import RxSwift

class MediaKeyTapInstanceDelegate: MediaKeyTapDelegate {
    private let disposeBag = DisposeBag()
    private let brightnessKeyTap$ = PublishSubject<MediaKey>()
    
    let brightnessMediaKey$: Observable<MediaKey>
    
    init() {
        brightnessMediaKey$ = brightnessKeyTap$.asObservable()
        
        disposeBag.insert([
            brightnessKeyTap$
        ])
    }
    
    func handle(mediaKey: MediaKey, event: KeyEvent?, modifiers: NSEvent.ModifierFlags?) {
        switch mediaKey {
            case .brightnessDown, .brightnessUp:
                brightnessKeyTap$.onNext(mediaKey)
            default:
                break
        }
    }
}

class MediaKeyTapService {
    private let disposeBag = DisposeBag()
    private let delegateService = MediaKeyTapInstanceDelegate()
    private let mediaKeyTap: MediaKeyTap;
    
    public let brightnessTap$: Observable<MediaKey>;
    
    init() {
        mediaKeyTap = MediaKeyTap(delegate: delegateService, for: [MediaKey.brightnessUp, MediaKey.brightnessDown], observeBuiltIn: true)
        
        brightnessTap$ = delegateService.brightnessMediaKey$.asObservable()
    }
    
    public func observeKeys() {
        mediaKeyTap.start()
    }
    
    deinit {
        mediaKeyTap.stop()
    }
}
