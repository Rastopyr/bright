//
//  structs.swift
//  Bright
//
//  Created by Roman on 27.05.2020.
//

import Cocoa
import Combine

struct BrightValues {
    var brightness: Float;
}

struct Display: Identifiable {
    let id: UInt32;
    let name: String;
    let isNative: Bool;
    var brightness: Double;
    var order: Int;
    var size: NSRect
}
