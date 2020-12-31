//
//  State.swift
//  Bright
//
//  Created by Roman on 25.12.2020.
//

import Foundation
import RxSwift

typealias StateHandler<T, K> = (_ state: K, _ event: T) -> K

func createState<T, K>(
    sources: [Observable<T>],
    handler: @escaping StateHandler<T, K>,
    state: K
) -> Observable<K> {
    return Observable.merge(sources).scan(state, accumulator: handler);
}
