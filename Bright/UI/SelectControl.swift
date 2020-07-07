//
//  SelectControl.swift
//  Bright
//
//  Created by Roman on 07.07.2020.
//

import SwiftUI

struct SelectControl: View {
    @State var list: [String];
    @State var activeIndex: Int = 0;
    
    @State var isOpen = false;
    
    @State var width = 126;
    @State var rowHeight = 26;
    
    
    var body: some View {
        let tapGuesture = TapGesture().onEnded {
            self.isOpen = !self.isOpen;
        }
        return ZStack {
            ZStack {
                Rectangle()
                    .fill(
                        Color.white.opacity(0.4)
                    )
                    
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        minHeight: 0,
                        maxHeight: .infinity
                    ).clipped()
                
                if (!isOpen) {
                    SelectControlRow(label: list[activeIndex])
                } else {
                    VStack(spacing: 0) {
                        ForEach(list, id: \.self) { listElement in
                            SelectControlRow(label: listElement)
                        }
                    }
                }
                
                Image("chevron_down").position(x: 18, y: 14)
            }
                .cornerRadius(5.0)
                .frame(
                    width: CGFloat(width),
                    height: CGFloat(!isOpen
                        ? rowHeight
                        : rowHeight * list.count
                    )
                )
                .clipped()
                .gesture(tapGuesture)
        }.offset(
            x: 0,
            y: CGFloat(isOpen
                ? list.count * rowHeight / 2
                : rowHeight / 2
            )
        )
    }
}

struct SelectControl_Previews: PreviewProvider {
    static var previews: some View {
        SelectControl(
            list: ["by NightShift", "by time range", "disabled"],
            isOpen: true
        
        ).frame(width: 200 , height: 400)
    }
}
