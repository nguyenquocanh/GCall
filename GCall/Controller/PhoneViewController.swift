//
//  PhoneViewController.swift
//  GCall
//
//  Created by Quoc Anh Nguyen on 10/27/15.
//  Copyright © 2015 gcall. All rights reserved.
//

import UIKit
import Parse
import AVFoundation
import AudioToolbox

class PhoneViewController: UIViewController {
    
    private var phone:GCallPhone = GCallPhone()
    var showSplash: Bool = false
    private var audioPlayer: AVAudioPlayer!
    private var playSoundID: SystemSoundID = 0
    private var timerPlaySound: NSTimer!
    private var indicatorWaitingCall2: IMGActivityIndicator!
    
    @IBOutlet weak var lblHangup: UILabel!
    @IBOutlet weak var btnHangup: UIButton!
    @IBOutlet weak var lblReject: UILabel!
    @IBOutlet weak var lblAnswer: UILabel!
    @IBOutlet weak var btnLogout: UIButton!
    @IBOutlet weak var btnReject: UIButton!
    @IBOutlet weak var btnAnswer: UIButton!
    @IBOutlet weak var viewPadding: UIView!
    @IBOutlet weak var viewBody: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        if self.showSplash {
            JTSplashView.splashViewWithBackgroundColor(nil, circleColor: nil, circleSize: nil)
            NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: Selector("hideSplashView"), userInfo: nil, repeats: false)
        }
        // Do any additional setup after loading the view.
        
        self.viewPadding.initViewWithColor(self.view.backgroundColor!, withBorder: true)
        self.viewBody.initViewWithColor(UIColor.whiteColor(), withBorder: false)
        
        //let activityIndicatorView = NVActivityIndicatorView(frame: self.btnAnswer.frame, type: NVActivityIndicatorType.BallScaleMultiple)
        //self.view.addSubview(activityIndicatorView)
        //activityIndicatorView.sendSubviewToBack(self.btnAnswer)
        //activityIndicatorView.startAnimation()
        
        self.btnAnswer.initButtonCornerRadius(self.btnAnswer.bounds.size.width / 2, withBackground: UIColor(red: 82/255, green: 25/255, blue: 126/255, alpha: 1.0), withTextColor: UIColor.whiteColor(), withBorderColor: nil)
        self.btnAnswer.addTarget(self, action: "didAnswer", forControlEvents: UIControlEvents.TouchUpInside)
        //self.btnAnswer.addSubview(activityIndicatorView)
        
        self.btnReject.initButtonCornerRadius(self.btnReject.bounds.size.width / 2, withBackground: UIColor.whiteColor(), withTextColor: UIColor.blackColor(), withBorderColor: UIColor(red: 82/255, green: 25/255, blue: 126/255, alpha: 1.0))
        self.btnReject.addTarget(self, action: "didReject", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.btnLogout.addTarget(self, action: "didLogout", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.btnHangup.initButtonCornerRadius(self.btnHangup.bounds.size.width / 2, withBackground: UIColor.whiteColor(), withTextColor: UIColor.blackColor(), withBorderColor: UIColor(red: 82/255, green: 25/255, blue: 126/255, alpha: 1.0))
        self.btnHangup.addTarget(self, action: "didHangup", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.hideButton(true)
        self.btnHangup.hidden = true
        self.lblHangup.hidden = true
        
        self.indicatorWaitingCall2 = IMGActivityIndicator(frame: CGRectMake(0, 0, 200, 200))
        self.indicatorWaitingCall2.center = self.viewBody.center
        //self.indicatorWaitingCall = LiquidLoader(frame: CGRectMake(0, 0, 200, 200), effect: Effect.GrowCircle(UIColor(red: 82/255, green: 25/255, blue: 126/255, alpha: 1.0)))
        //self.indicatorWaitingCall.center = self.viewBody.center
        self.viewBody.addSubview(self.indicatorWaitingCall2)
        
        let soundFilePath = NSBundle.mainBundle().pathForResource("incoming", ofType: "wav")
        let soundFileURL = NSURL.fileURLWithPath(soundFilePath!)
        AudioServicesCreateSystemSoundID(soundFileURL, &self.playSoundID)
        
        self.phone.login()
        
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "loginDidFinish:", name: kNotifyLoginDidFinish, object: nil)
        
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceDidStartListeningForIncomingConnections:", name: kNotifyDeviceDidStartListeningForIncomingConnections, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector:Selector("pendingIncomingConnectionReceived:"),
            name:kNotifyPendingIncomingConnectionReceived, object:nil)
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector:Selector("pendingIncomingConnectionDidDisconnect:"),
            name:kNotifyPendingIncomingConnectionDidDisconnect, object:nil)
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector:Selector("connectionDidDisconnect:"),
            name:kNotifyConnectionDidDisconnect, object:nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func hideSplashView() {
        JTSplashView.finishWithCompletion { () -> Void in
            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
        }
    }
    
    func loginDidFinish(notification: NSNotification) {
        
    }
    
    func didLogout() {
        let alertViewController = ViewManager.sharedInstance.alertViewController()
        alertViewController.addButton("Logout") {
            ViewManager.sharedInstance.startIndicatorView()
            self.phone.logout()
            PFUser.logOut()
            let loginViewController = Utils.mainStoryboard.instantiateViewControllerWithIdentifier("LoginViewController") as? LoginViewController
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            ViewManager.sharedInstance.stopIndicatorView({
                appDelegate.window?.rootViewController = loginViewController
            })
        }
        alertViewController.show()
    }

    func didAnswer() {
        self.phone.acceptConnection()
        self.hideButton(true)
        self.btnHangup.hidden = false
        self.lblHangup.hidden = false
        self.btnLogout.hidden = true
        self.indicatorWaitingCall2.hidden = true
        if self.timerPlaySound != nil {
            self.timerPlaySound.invalidate()
            self.timerPlaySound = nil
        }
    }
    
    func didReject() {
        self.phone.rejectConnection()
        self.btnHangup.hidden = true
        self.lblHangup.hidden = true
        self.btnLogout.hidden = false
        self.indicatorWaitingCall2.hidden = false
        if self.timerPlaySound != nil {
            self.timerPlaySound.invalidate()
            self.timerPlaySound = nil
        }
    }
    
    func didHangup() {
        self.phone.disconnect()
    }
    
    func isForeground() -> Bool {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.isForeground()
    }
    
    func pendingIncomingConnectionReceived(notification:NSNotification) {
        print("pendingIncomingConnectionReceived")
        //let parameters = notification.userInfo
        
        if !self.isForeground() {
            
            let application = UIApplication.sharedApplication()
            let notification:UILocalNotification = UILocalNotification()
            let oldNotifies = application.scheduledLocalNotifications
            if oldNotifies?.count > 0 {
                application.cancelAllLocalNotifications()
            }
            notification.alertBody = "Incoming Call"
            //notification.soundName = UILocalNotificationDefaultSoundName
            application.presentLocalNotificationNow(notification)
            self.timerPlaySound = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: Selector("playSound"), userInfo: nil, repeats: true)
        }
        
        self.hideButton(false)
        self.btnLogout.hidden = true
        self.indicatorWaitingCall2.hidden = true
    }
    
    func playSound() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        AudioServicesPlaySystemSound(self.playSoundID)
    }
    
    func pendingIncomingConnectionDidDisconnect(notification:NSNotification) {
        //self.performSelectorOnMainThread("cancelAlert", withObject: nil, waitUntilDone: false)
        if !self.isForeground() {
            UIApplication.sharedApplication().cancelAllLocalNotifications()
        }
        self.hideButton(true)
        self.btnHangup.hidden = true
        self.lblHangup.hidden = true
        self.btnLogout.hidden = false
        self.indicatorWaitingCall2.hidden = false
        if self.timerPlaySound != nil {
            self.timerPlaySound.invalidate()
            self.timerPlaySound = nil
        }
    }
    
    func connectionDidDisconnect(notification:NSNotification) {
        self.hideButton(true)
        self.btnHangup.hidden = true
        self.lblHangup.hidden = true
        self.btnLogout.hidden = false
        self.indicatorWaitingCall2.hidden = false
        if self.timerPlaySound != nil {
            self.timerPlaySound.invalidate()
            self.timerPlaySound = nil
        }
    }
    
    func hideButton(flag: Bool) {
        self.btnAnswer.hidden = flag
        self.btnReject.hidden = flag
        self.lblAnswer.hidden = flag
        self.lblReject.hidden = flag
    }

}
