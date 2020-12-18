//
//  BrightnessService.swift
//  Bright
//
//  Created by Roman on 04.06.2020.
//

import Foundation
import DDC
import Cocoa

class BrightnessSerivce {
    func setBrightness(display: Display, brightnessValue: Double) -> Void {
        if (display.isNative == true) {
            BrightnessSerivce.setNativeBrightness?(display.id, brightnessValue)
            BrightnessSerivce.DisplayServicesBrightnessChanged?(display.id, brightnessValue);
        } else {
            BrightnessSerivce.setExternalBrightness(displayID: display.id, brightnessValue: brightnessValue)
        }
        
    }
    
    func getBrightness(displayID: UInt32, isNative: Bool) -> Double {
        if (isNative == true) {
            return  BrightnessSerivce.getNativeBrightness?(displayID) ?? 0.0
        }
        
        return BrightnessSerivce.getExternalBrightness(displayID: displayID)
    }
    
    // source https://github.com/MonitorControl/MonitorControl/blob/master/MonitorControl/Model/InternalDisplay.swift#L62
    private static var getNativeBrightness: ((CGDirectDisplayID) -> Double)? {
      let coreDisplayPath = CFURLCreateWithString(kCFAllocatorDefault, "/System/Library/Frameworks/CoreDisplay.framework" as CFString, nil)
      if let coreDisplayBundle = CFBundleCreate(kCFAllocatorDefault, coreDisplayPath) {
        if let funcPointer = CFBundleGetFunctionPointerForName(coreDisplayBundle, "CoreDisplay_Display_GetUserBrightness" as CFString) {
          typealias CDGUBFunctionType = @convention(c) (UInt32) -> Double
          return unsafeBitCast(funcPointer, to: CDGUBFunctionType.self)
        }
      }
      return nil
    }
    
    // source: https://github.com/MonitorControl/MonitorControl/blob/master/MonitorControl/Model/InternalDisplay.swift#L75
    private static var setNativeBrightness: ((CGDirectDisplayID, Double) -> Void)? {
      let coreDisplayPath = CFURLCreateWithString(kCFAllocatorDefault, "/System/Library/Frameworks/CoreDisplay.framework" as CFString, nil)
      if let coreDisplayBundle = CFBundleCreate(kCFAllocatorDefault, coreDisplayPath) {
        if let funcPointer = CFBundleGetFunctionPointerForName(coreDisplayBundle, "CoreDisplay_Display_SetUserBrightness" as CFString) {
          typealias CDSUBFunctionType = @convention(c) (UInt32, Double) -> Void
          return unsafeBitCast(funcPointer, to: CDSUBFunctionType.self)
        }
      }
      return nil
    }
    
    private static var DisplayServicesBrightnessChanged: ((CGDirectDisplayID, Double) -> Void)? {
      let displayServicesPath = CFURLCreateWithString(kCFAllocatorDefault, "/System/Library/PrivateFrameworks/DisplayServices.framework" as CFString, nil)
      if let displayServicesBundle = CFBundleCreate(kCFAllocatorDefault, displayServicesPath) {
        if let funcPointer = CFBundleGetFunctionPointerForName(displayServicesBundle, "DisplayServicesBrightnessChanged" as CFString) {
          typealias DSBCFunctionType = @convention(c) (UInt32, Double) -> Void
          return unsafeBitCast(funcPointer, to: DSBCFunctionType.self)
        }
      }
      return nil
    }
    
    private static func getExternalBrightness(displayID: UInt32) -> Double {
        guard let (currentValue, _) = DDC(for: displayID)?.read(command: .brightness, tries: 1, minReplyDelay: 1000) else {
            return 0.0
        }
        
        return Double(currentValue) / 100;
    }
    
    private static func setExternalBrightness(displayID: UInt32, brightnessValue: Double) -> Void {
        guard DDC(for: displayID)?.write(command: .brightness, value: UInt16(brightnessValue * 100)) == true else {
          return
        }
    }
}
