//
//  ViewManager.swift
//  ManaSoMe
//
//  Created by Quoc Anh Nguyen on 8/25/15.
//  Copyright (c) 2015 AnhNguyen. All rights reserved.
//

import UIKit

class ViewManager: NSObject {
    class var sharedInstance: ViewManager {
        struct Singleton {
            static let instance = ViewManager()
        }
        return Singleton.instance
    }
    
    func startIndicatorView() {
        let indicator = ZFCWaveActivityIndicatorView()
        indicator.center = CGPointMake(UIScreen.mainScreen().bounds.size.width / 2, UIScreen.mainScreen().bounds.size.height / 2)
        indicator.startAnimating()
        let indicatorViewController = UIViewController()
        indicatorViewController.view.addSubview(indicator)
        KGModal.sharedInstance().closeButtonType = KGModalCloseButtonType.None
        KGModal.sharedInstance().showWithContentViewController(indicatorViewController, andAnimated: true)
    }
    
    func createIndicatorInView(view: UIView) -> ZFCWaveActivityIndicatorView {
        let indicator = ZFCWaveActivityIndicatorView()
        indicator.center = CGPointMake(UIScreen.mainScreen().bounds.size.width / 2, UIScreen.mainScreen().bounds.size.height / 2)
        indicator.startAnimating()
        view.addSubview(indicator)
        return indicator
    }
    
    func stopIndicatorView(completion: ()->()) {
        KGModal.sharedInstance().hideAnimated(true, withCompletionBlock: completion)
    }
    
    func alertViewController() -> Hokusai {
        let alertView = Hokusai()
        alertView.colors = HOKColors(
            backGroundColor: UIColor(red: 82/255, green: 25/255, blue: 126/255, alpha: 1.0),
            buttonColor: UIColor.whiteColor().colorWithAlphaComponent(0.1),
            cancelButtonColor: UIColor.whiteColor().colorWithAlphaComponent(0.3),
            fontColor: UIColor.whiteColor()
        )
        //alertView.fontName = "UVNVanBold"
        return alertView
    }
    
    func alertViewWithTitle(title: String) -> Hokusai {
        let alertView = Hokusai()
        alertView.colors = HOKColors(
            backGroundColor: UIColor(red: 82/255, green: 25/255, blue: 126/255, alpha: 1.0),
            buttonColor: UIColor.whiteColor().colorWithAlphaComponent(0.1),
            cancelButtonColor: UIColor.clearColor(),
            fontColor: UIColor.whiteColor()
        )
        alertView.cancelButtonTitle = title
        return alertView
    }
    
    
}
