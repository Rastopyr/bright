//
//  ContentView.swift
//  Bright
//
//  Created by Roman on 26.05.2020.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        BrightApp(onControlChanges: {_ in })
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
