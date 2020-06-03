//
//  BrightControl.swift
//  Bright
//
//  Created by Roman on 02.06.2020.
//

import SwiftUI
import Combine

let CONTROL_WIDTH: CGFloat = 96
let CONTROL_HEIGHT: CGFloat = 232

final class ControlData: ObservableObject  {
    let didChange = PassthroughSubject<ControlData, Never>()

    @Published var progress = 0.0 {
        didSet {
            didChange.send(self)
        }
    }
}

struct BrightControl: View {
    @EnvironmentObject var controlData: ControlData
    
    let onControlChanges: (_: Float) -> Void;
    
    var body: some View {
        VStack {
            Slider(
                value: $controlData.progress,
                in: 0...1,
                onEditingChanged: { _ in  self.onControlChanges(Float(self.controlData.progress)) }
            )
                .rotationEffect(Angle(degrees: -90))
                .frame(width: CONTROL_WIDTH, height: CONTROL_HEIGHT)
                .clipped()
        }.frame(width: CONTROL_WIDTH, height: CONTROL_HEIGHT)
        
    }
}

struct BrightControl_Previews: PreviewProvider {
    static var previews: some View {
        BrightControl(onControlChanges: {_ in }).environmentObject(ControlData())
    }
}
