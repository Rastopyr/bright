//
//  DisplaySliderControl.swift
//  Bright
//
//  Created by Roman on 01.01.2021.
//

import SwiftUI

struct DisplaySliderControl: View {
    @State var brightnessValue: Double = 0
    @State var displayName: String = "unknown"
    
    var body: some View {
        return VStack {
            Slider(value: $brightnessValue, in: 0.0...1.0)
            Text("\(displayName)")
        }.padding()
    }
}

struct DisplaySliderControl_Previews: PreviewProvider {
    static var previews: some View {
        DisplaySliderControl()
    }
}
