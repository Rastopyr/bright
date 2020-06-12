//
//  Bright.swift
//  Bright
//
//  Created by Roman on 28.05.2020.
//

import SwiftUI

struct BrightApp: View {
    var body: some View {
        ZStack {
            Rectangle()
            BrightControl(fillPercent: 0.5)
        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity).clipped()
    }
}

struct BrightApp_Previews: PreviewProvider {
    static var previews: some View {
        BrightApp()
    }
}
