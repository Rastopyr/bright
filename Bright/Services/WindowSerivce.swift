//
//  WindowSerivce.swift
//  Bright
//
//  Created by Roman on 13.06.2020.
//

import Cocoa
import SwiftUI

class WindowService {
    private var window: NSWindow?;
    private var mainView: BrightApp;

    init(mainView: BrightApp) {
        self.mainView = mainView;
    }
    
    func createWindow() {
        if (window !== nil) {
            return;
        }
        window = NSWindow(
            contentRect: .init(
                origin: .zero,
                size: .init(
                    width: WINDOW_WIDTH,
                    height: WINDOW_HEIGHT
            )),
            
            styleMask: [],
            
            backing: .buffered,
            defer: false
        )
        
        let visualEffect = NSVisualEffectView()
        visualEffect.blendingMode = .behindWindow
        visualEffect.state = .active
        visualEffect.material = .ultraDark

        window?.isOpaque = false
        window?.backgroundColor = .clear
        window?.hidesOnDeactivate = true
        
        let hosting = NSHostingView(rootView: mainView)

        window?.contentView = visualEffect
        visualEffect.addSubview(hosting)
        
        hosting.setFrameSize(NSSize(width: WINDOW_WIDTH, height: WINDOW_HEIGHT))
        
        window?.center()
        window?.setIsVisible(true)
        
        window?.hidesOnDeactivate = true
    }
}
