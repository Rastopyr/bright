//
//  MediaKeyObserver.swift
//  Bright
//
//  Created by Roman on 13.12.2020.
//

import Foundation
import RxSwift

class MediaKeyObserver {
    let disposeBag = DisposeBag()
    let mediaKeyService: MediaKeyTapService;
    let appService: AppService;
    
    init(mediaKeyservice: MediaKeyTapService, appService: AppService) {
        self.mediaKeyService = mediaKeyservice;
        self.appService = appService;
    }
    
    public func start() {
        mediaKeyService.observeKeys()
        
        mediaKeyService.brightnessTap$
            .do(onNext: {  _ in
                self.appService.activate()
            })
            .debounce(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .delay(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .do(onNext: { _ in
                self.appService.deactivate()
            })
            .subscribe().disposed(by: disposeBag)
    }
}
