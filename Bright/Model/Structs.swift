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

struct Display {
    let id: UInt32;
    let name: String;
    var brightness: Float;
    var order: Int;
    var size: NSRect
}
