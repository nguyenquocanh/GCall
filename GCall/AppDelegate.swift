//
//  AppDelegate.swift
//  GCall
//
//  Created by Quoc Anh Nguyen on 10/26/15.
//  Copyright © 2015 gcall. All rights reserved.
//

import UIKit
import Parse
import PushKit
import ZeroPush

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var loginViewController: LoginViewController?
    var phoneViewController: PhoneViewController?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        //Pushwoosh
        //PushNotificationManager.pushManager().delegate = self
        PushNotificationManager.pushManager().handlePushReceived(launchOptions)
        PushNotificationManager.pushManager().sendAppOpen()
        PushNotificationManager.pushManager().registerForPushNotifications()
        
        if  UIApplication.instancesRespondToSelector(Selector("registerUserNotificationSettings:")) {
            application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound], categories: nil))
        }

        // Initialize Parse.
        Parse.enableLocalDatastore()
        Parse.setApplicationId("JxmlaydBSVWjQgWTGFj6OuWTaOpR07k7O6Iwz5ws",
            clientKey: "W73FwFrd1Sqm49JoKysuaI8viXj2GIRiP6wqoHwW")
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        UIApplication.sharedApplication().statusBarHidden = false
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        let currentUser = PFUser.currentUser()
        if currentUser != nil {
            // Do stuff with the user
            self.phoneViewController = Utils.mainStoryboard.instantiateViewControllerWithIdentifier("PhoneViewController") as? PhoneViewController
            self.phoneViewController?.showSplash = true
            self.window?.rootViewController = self.phoneViewController
        } else {
            // Show the signup or login screen
            self.loginViewController = Utils.mainStoryboard.instantiateViewControllerWithIdentifier("LoginViewController") as? LoginViewController
            self.window?.rootViewController = self.loginViewController
        }
        
        self.window?.makeKeyAndVisible()

        return true
    }
    
}

extension AppDelegate: PKPushRegistryDelegate {
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        //register for voip notifications
        let voipRegistry = PKPushRegistry(queue: dispatch_get_main_queue())
        voipRegistry.desiredPushTypes = Set([PKPushTypeVoIP])
        voipRegistry.delegate = self
    }
    
    func pushRegistry(registry: PKPushRegistry!, didUpdatePushCredentials credentials: PKPushCredentials!, forType type: String!) {
        
        //print out the VoIP token. We will use this to test the nofications.
        NSLog("voip token: \(credentials.token)")
        PushNotificationManager.pushManager().handlePushRegistration(credentials.token)
    }
    
    func pushRegistry(registry: PKPushRegistry!, didReceiveIncomingPushWithPayload payload: PKPushPayload!, forType type: String!) {
        
        /*
        PushNotificationManager.pushManager().handlePushReceived(payload.dictionaryPayload)
        
        let payloadDict = payload.dictionaryPayload["aps"] as? Dictionary<String, String>
        let message = payloadDict?["alert"]
        
        //present a local notifcation to visually see when we are recieving a VoIP Notification
        if UIApplication.sharedApplication().applicationState == UIApplicationState.Background {
            
            let localNotification = UILocalNotification();
            localNotification.alertBody = message
            localNotification.applicationIconBadgeNumber = 1;
            localNotification.soundName = UILocalNotificationDefaultSoundName;
            UIApplication.sharedApplication().presentLocalNotificationNow(localNotification);
        }
        else {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let alert = UIAlertView(title: "VoIP Notification", message: message, delegate: nil, cancelButtonTitle: "Ok");
                alert.show()
            })
        }
        */

        NSLog("incoming voip notfication: \(payload.dictionaryPayload)")
    }
    
    func pushRegistry(registry: PKPushRegistry!, didInvalidatePushTokenForType type: String!) {
        NSLog("token invalidated")
        PushNotificationManager.pushManager().unregisterForPushNotifications()
    }
}

extension AppDelegate {
    func isForeground() -> Bool {
        let state = UIApplication.sharedApplication().applicationState
        return state == UIApplicationState.Active
    }
}

extension UIApplicationState {
    
    //help to output a string instead of an enum number
    var stringValue : String {
        get {
            switch(self) {
            case .Active:
                return "Active"
            case .Inactive:
                return "Inactive"
            case .Background:
                return "Background"
            }
        }
    }
}

