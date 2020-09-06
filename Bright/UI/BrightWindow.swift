//
//  BrightWindow.swift
//  Bright
//
//  Created by Roman on 05.09.2020.
//

import Cocoa
import SwiftUI

func createWindow<V: View>(
    size: NSSize,
    point: NSPoint,
    childView: V
) -> NSWindow {
    let window =  NSWindow(
       contentRect: .init(
           origin: .zero,
           size: size
        ),
       
       styleMask: [],
       backing: .buffered,
       defer: false
    );
    
    window.isOpaque = false
    window.backgroundColor = .clear
    
    let visualEffect = NSVisualEffectView()
    visualEffect.blendingMode = .behindWindow
    visualEffect.state = .active
    visualEffect.material = .light
    
    let hosting = NSHostingView(rootView: childView)
    
    let visualHosting = NSView()
    
    visualHosting.setFrameSize(size)
    visualHosting.addSubview(visualEffect)
    
    visualEffect.setFrameSize(size)

    window.contentView = visualHosting
    visualEffect.addSubview(hosting)
    
    hosting.setFrameSize(size)
    
    visualHosting.wantsLayer = true
    visualHosting.layer?.masksToBounds = true
    visualHosting.layer?.cornerRadius = 14.0;
    
    window.setFrameOrigin(point)

    return window;
}

struct BrightWindow: View {
    
    private let window: NSWindow;
    
    init<V: View>(
        size: NSSize,
        point: NSPoint,
        childView: V,
        isVisiible: Bool
    ) {
        print("init")
        self.window = createWindow(
            size: size,
            point: point,
            childView: childView
        )
        
        window.setIsVisible(isVisiible)
    }
    
    var body: some View {
        Text("")
    }
}

struct BrightWindow_Previews: PreviewProvider {
    static var previews: some View {
        BrightWindow(
            size: NSSize(width: 100, height: 100),
            point: NSPoint(x: 100, y: 100),
            childView: Text("Test view"),
            isVisiible: true
        )
    }
}
