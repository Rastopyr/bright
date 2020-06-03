//
//  Bright.swift
//  Bright
//
//  Created by Roman on 28.05.2020.
//

import SwiftUI

struct BrightApp: View {
    let onControlChanges: (_: Float) -> Void;

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.clear)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            BrightControl(
                onControlChanges: self.onControlChanges
            ).environmentObject(ControlData())
        }
    }
}

struct BrightApp_Previews: PreviewProvider {
    static var previews: some View {
        BrightApp(onControlChanges: {_ in })
    }
}
