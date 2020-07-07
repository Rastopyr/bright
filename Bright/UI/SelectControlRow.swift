//
//  SelectControlRow.swift
//  Bright
//
//  Created by Roman on 07.07.2020.
//

import SwiftUI



struct SelectControlRow: View {
    @State var label: String;
    
    @State private var isHovered = false;
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(
                    isHovered ? Color.black.opacity(0.4) : Color.clear
                ).onHover { (isOver) in
                   self.isHovered = isOver
                }
            
            Text(label).padding(EdgeInsets(
                top: 0,
                leading: 14,
                bottom: 0,
                trailing: 0
            ))
                
        }
        .frame(
            width: CGFloat(126),
            height: CGFloat(26),
            alignment: .trailing
        )
    }
}

struct SelectControlRow_Previews: PreviewProvider {
    static var previews: some View {
        SelectControlRow(label: "by NightShift")
    }
}
