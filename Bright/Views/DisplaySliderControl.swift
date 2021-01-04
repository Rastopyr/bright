//
//  DisplaySliderControl.swift
//  Bright
//
//  Created by Roman on 01.01.2021.
//

import SwiftUI
//import Combine

final class DisplaySliderData: ObservableObject, Identifiable {
    @Published var displayId: CGDirectDisplayID = 0
    @Published var value: Double = 0.0
    @Published var label: String = "unknown"
    
    let id: String;
    
    init (displayId: CGDirectDisplayID, value: Double, label: String) {
        self.id = "\(displayId)-\(value)"
        self.displayId = displayId
        self.value = value
        self.label = label
    }
}

struct DisplaySliderControl: View {
    @EnvironmentObject var state: DisplaySliderData
    
    let onChange: (_ newValue: Double) -> Void;

    var body: some View {
        return VStack {
            Slider(
                value: $state.value,
                in: 0.0...1.0,
                onEditingChanged: { _ in onChange(state.value) }
            ).padding()
            Text(state.label)
        }
    }
}

struct DisplaySliderControl_Previews: PreviewProvider {
    static var previews: some View {
        let state = DisplaySliderData(
            displayId: CGDirectDisplayID(), value: 0.0, label: "unknown"
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            state.value = 0.5
        }
        
        return DisplaySliderControl(onChange: { _ in
               ()
            }
        ).environmentObject(state)
    }
}
