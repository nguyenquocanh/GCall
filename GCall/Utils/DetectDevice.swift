//
//  DetectDevice.swift
//  DemoMasterDetail
//
//  Created by Quoc Anh Nguyen on 7/13/15.
//  Copyright (c) 2015 KASAKI NGUYEN. All rights reserved.
//

import Foundation
import UIKit

enum UIUserInterfaceIdiom: Int {
    case Unspecified
    case Phone
    case Pad
}

private var iPad: Bool {
    return  UIDevice.currentDevice().userInterfaceIdiom == .Pad
}

private var iPhone: Bool {
    return  UIDevice.currentDevice().userInterfaceIdiom == .Phone
}

struct ScreenSize
{
    static let SCREEN_WIDTH         = UIScreen.mainScreen().bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.mainScreen().bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType
{
    static let IS_IPHONE_4_OR_LESS  = iPhone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5          = iPhone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6          = iPhone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P         = iPhone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPHONE            = iPhone
    static let IS_IPAD              = iPad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
}

struct Version{
    static let SYS_VERSION_FLOAT = (UIDevice.currentDevice().systemVersion as NSString).floatValue
    static let iOS7 = (Version.SYS_VERSION_FLOAT < 8.0 && Version.SYS_VERSION_FLOAT >= 7.0)
    static let iOS8 = (Version.SYS_VERSION_FLOAT >= 8.0 && Version.SYS_VERSION_FLOAT < 9.0)
    static let iOS9 = (Version.SYS_VERSION_FLOAT >= 9.0 && Version.SYS_VERSION_FLOAT < 10.0)
}