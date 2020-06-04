//
//  AppService.swift
//  Bright
//
//  Created by Roman on 04.06.2020.
//

import Cocoa

class AppService {
    @objc func quit() {
        NSApplication.shared.terminate(self)
    }
}
