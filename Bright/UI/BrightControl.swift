//
//  BrightControl.swift
//  Bright
//
//  Created by Roman on 02.06.2020.
//

import SwiftUI
import RxSwift

let CONTROL_WIDTH: CGFloat = 96
let CONTROL_HEIGHT: CGFloat = 232

let scheduler = SerialDispatchQueueScheduler(qos: .default)

struct BrightControl: View {
    @State var fillPercent: Double = 0.0

    private var fillHeight: CGFloat {
        return CONTROL_HEIGHT * CGFloat(self.fillPercent)
    }

    private var position: CGPoint {
        return CGPoint(
            x: CONTROL_WIDTH / 2,
            y: CONTROL_HEIGHT - (fillHeight / 2)
        )
    }
    
    var body: some View {
        let dragGuesture = DragGesture(
            minimumDistance: 0,
            coordinateSpace: .local
        ).onChanged({
            let fillPercentCandidate = 1.0 - Double(
                $0.location.y / CONTROL_HEIGHT
            )
            
            guard fillPercentCandidate <= 1 else {
                self.fillPercent = 1;
                return;
            }
            
            guard fillPercentCandidate >= 0 else {
                self.fillPercent = 0;
                return;
            }
            
            self.fillPercent = fillPercentCandidate;
        })
        
        return ZStack {
            Rectangle().fill(Color.white.opacity(0.5))
            Rectangle()
                .fill(
                   Color.white.opacity(0.8)
                 )
                .frame(
                    width: CONTROL_WIDTH,
                    height: self.fillHeight
                )
                .position(position)
                .contentShape(Rectangle())
                .gesture(dragGuesture)
        }
        .cornerRadius(CGFloat(10.0))
        .frame(width: CONTROL_WIDTH, height: CONTROL_HEIGHT)
    }
}

struct BrightControl_Previews: PreviewProvider {
    static var previews: some View {
        BrightControl(
            fillPercent: 0.5
        )
    }
}
