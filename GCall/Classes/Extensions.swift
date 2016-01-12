//
//  Extensions.swift
//  GCall
//
//  Created by Quoc Anh Nguyen on 10/26/15.
//  Copyright © 2015 gcall. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func initViewWithColor(bgColor: UIColor, withBorder: Bool) {
        self.clipsToBounds = true
        self.layer.cornerRadius = 6
        self.backgroundColor = bgColor
        if withBorder {
            self.layer.borderColor = UIColor.whiteColor().CGColor
            self.layer.borderWidth = 1.0
        }
    }
}

extension UIButton {
    func initButtonWithBackgroundColor(bgColor: UIColor, withTextColor: UIColor, withBorderColor: UIColor?) {
        self.clipsToBounds = true
        self.layer.cornerRadius = 6
        self.backgroundColor = bgColor
        self.titleLabel?.textColor = withTextColor
        if let color = withBorderColor {
            self.layer.borderColor = color.CGColor
            self.layer.borderWidth = 1.0
        }
    }
    
    func initButtonCornerRadius(cornerRadius:CGFloat, withBackground: UIColor, withTextColor: UIColor, withBorderColor: UIColor?) {
        self.clipsToBounds = true
        self.layer.cornerRadius = cornerRadius
        self.backgroundColor = withBackground
        self.titleLabel?.textColor = withTextColor
        if let color = withBorderColor {
            self.layer.borderColor = color.CGColor
            self.layer.borderWidth = 1.0
        }
    }
}