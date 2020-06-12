//
//  View.swift
//  Bright
//
//  Created by Roman on 12.06.2020.
//

import SwiftUI

extension View {
    public func visualEffect(effect: VisualEffect) -> some View {
        background(VisualEffectView(effect: effect))
    }
}
