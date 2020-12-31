//
//  MediaKeyObserver.swift
//  Bright
//
//  Created by Roman on 13.12.2020.
//

import Foundation
import RxSwift
import MediaKeyTap

class MediaKeyObserver {
    let disposeBag = DisposeBag()
    let mediaKeyService: MediaKeyTapService
    let displayBrightnessService: DisplayBrightnessService
    let appService: AppService
    
    init(mediaKeyservice: MediaKeyTapService, appService: AppService, displayBrightnessService: DisplayBrightnessService) {
        self.mediaKeyService = mediaKeyservice
        self.appService = appService
        self.displayBrightnessService = displayBrightnessService
    }
    
    public func start() {
        mediaKeyService.observeKeys()
        
        mediaKeyService.brightnessTap$
            .do(onNext: { (mediaKey: MediaKey) in
                self.appService.activate()
                
                switch(mediaKey) {
                    case .brightnessUp:
                        self.displayBrightnessService.incrementBrightness()
                    case .brightnessDown:
                        self.displayBrightnessService.decrementBrightness()
                    default: break
                } 
            })
            .debounce(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .delay(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .do(onNext: { _ in
                self.appService.deactivate()
            })
            .subscribe().disposed(by: disposeBag)
    }
}
