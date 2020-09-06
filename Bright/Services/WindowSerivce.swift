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
            window?.makeKeyAndOrderFront(self)
            return;
        }
        
        window = NSWindow(
            contentRect: .init(
                origin: .zero,
                size: .init(
                    width: 0,
                    height: 0
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
        
        let hosting = NSHostingView(rootView: mainView)

        window?.contentView = visualEffect
        visualEffect.addSubview(hosting)
        
        hosting.setFrameSize(NSSize(width: 1, height: 1))
        
        window?.center()
        window?.setIsVisible(true)

        window?.hidesOnDeactivate = true
        
    }
}
