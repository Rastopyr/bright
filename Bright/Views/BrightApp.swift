//
//  Bright.swift
//  Bright
//
//  Created by Roman on 28.05.2020.
//

import SwiftUI
import RxSwift

func getScreenWithMouse() -> NSScreen? {
  let mouseLocation = NSEvent.mouseLocation
  let screens = NSScreen.screens
  let screenWithMouse = (screens.first { NSMouseInRect(mouseLocation, $0.frame, false) })

  return screenWithMouse
}

struct BrightApp: View {
    var body: some View {
        DisplaySliderControlList()
    }
}

struct BrightApp_Previews: PreviewProvider {
    static var previews: some View {
        return Rectangle()
    }
}
