//
//  WindowService.swift
//  Bright
//
//  Created by Roman on 07.09.2020.
//


import Quick
import Nimble

@testable import Bright

class WindowServiceSpec: QuickSpec {
    override func spec() {
        describe("WindowInstance") {
            it("basic position$ test") {
                let win = WindowInstance(
                    title: "testWindow",
                    position: NSPoint( x: 0, y: 0), size: NSSize(width: 0, height: 0)
                );

                win.position$.onNext(NSPoint(x: 1, y: 1));

                let value = try win.position$.value();
                expect(value).to(equal(NSPoint(x: 1, y: 1)));
            }

            it("basic size$ test") {
                let win = WindowInstance(
                    title: "testWndow",
                    position: NSPoint(x: 0, y: 0), size: NSSize(width: 0, height: 0)
                );

                win.size$.onNext(NSSize(width: 1, height: 1));

                let value = try win.size$.value();
                expect(value).to(equal(NSSize(width: 1, height: 1)));
            }
        }
  }
}
