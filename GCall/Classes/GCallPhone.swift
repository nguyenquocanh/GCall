//
//  GCallPhone.swift
//  GCall
//
//  Created by Quoc Anh Nguyen on 10/27/15.
//  Copyright © 2015 gcall. All rights reserved.
//

import Foundation
import AVFoundation
import Parse

public class GCallPhone: NSObject, TCDeviceDelegate, TCConnectionDelegate {
    var device:TCDevice? = nil
    var connection:TCConnection? = nil
    var pendingConnection:TCConnection? = nil
    var internetReachability: Reachability!
    var loggedIn: Bool!
    var backgroundTaskAgent: UIBackgroundTaskIdentifier!
    var speakerEnabled: Bool = true
    
    
    override init() {
        super.init()
        self.internetReachability = Reachability.reachabilityForInternetConnection()
        self.internetReachability?.stopNotifier()
        self.loggedIn = false
        self.speakerEnabled = true
        
        self.backgroundTaskAgent = UIBackgroundTaskInvalid
        TwilioClient.sharedInstance().setLogLevel(TCLogLevel.LOG_VERBOSE)
    }
    
    func reachabilityChanged(notify: NSNotification) {
        let netStatus: NetworkStatus = (self.internetReachability.currentReachabilityStatus())
        if netStatus != NetworkStatus.NotReachable && !self.loggedIn {
            self.loginHelper()
        }
    }
    
    func login() {
        self.beginBackgroundUpdateTask()
        NSNotificationCenter.defaultCenter().postNotificationName(kNotifyLoginDidStart, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityChanged:", name: kReachabilityChangedNotification, object: nil)
        
        let netStatus: NetworkStatus = self.internetReachability.currentReachabilityStatus()
        if netStatus != NetworkStatus.NotReachable {
            self.loginHelper()
        }
        else {
            self.internetReachability.startNotifier()
        }
    }
    
    func loginHelper() {
        let user = Utils.getUser()
        //let params = [kCapabilityTokenKeyAllowOutgoing: true, kCapabilityTokenKeyAllowIncoming: true, kCapabilityTokenKeyIncomingClient:user!.username]
        let params = [kAccountSid: user!.sid, kAccountToken: user!.token, kClientName:user!.username]
        self.doLoginWithCapabilityTokenParams(params)
    }
    
    func updateCapabilityToken(dictCapabilityParams: NSDictionary) {
        NSNotificationCenter.defaultCenter().postNotificationName(kNotifyLoginDidStart, object: nil)
        self.doLoginWithCapabilityTokenParams(dictCapabilityParams)
    }
    
    func doLoginWithCapabilityTokenParams(dictCapabilityParams: NSDictionary) {
        self.getCapabilityTokenWithParameters(dictCapabilityParams)
    }
    
    func getCapabilityTokenWithParameters(dictParams: NSDictionary) {
        /*
        let outgoing = NSString(format: "token?allowOutgoing=%@", dictParams.objectForKey(kCapabilityTokenKeyAllowOutgoing) as! Bool ? "true" : "false")
        var params: NSString!
        if dictParams.objectForKey(kCapabilityTokenKeyAllowIncoming) as! Bool {
            params = NSString(format: "%@&client=%@", outgoing, dictParams.objectForKey(kCapabilityTokenKeyIncomingClient) as! String)
        }
        else {
            params = outgoing
        }
        
        let urlString = NSString(format: "http://gcalldemo.herokuapp.com/%@", params)
        let swiftRequest = SwiftRequest()
        swiftRequest.get(urlString as String, callback: { (err, response, body) -> () in
            if (err != nil) {
                return
            }
            
            let token = body as? NSString
            print(token)
            
            if (err == nil && token != nil) {
                if ( self.device == nil ) {
                    self.device = TCDevice(capabilityToken: token as! String, delegate: self)
                } else {
                    self.device!.updateCapabilityToken(token as! String)
                }
                
                NSNotificationCenter.defaultCenter().postNotificationName(kNotifyLoginDidFinish, object: nil)
                self.loggedIn = true
            } else if ( err != nil && response != nil) {
                // We received and error with a response
                NSNotificationCenter.defaultCenter().postNotificationName(kNotifyLoginDidFailWithError, object: nil)
            } else if (err != nil) {
                // We received an error without a response
                NSNotificationCenter.defaultCenter().postNotificationName(kNotifyLoginDidFailWithError, object: nil)
            }
            self.endBackgroundUpdateTask()
        })
        */
        PFCloud.callFunctionInBackground("capabilityToken", withParameters: ["sid":dictParams.objectForKey(kAccountSid) as! String,"token":dictParams.objectForKey(kAccountToken) as! String, "name": dictParams.objectForKey(kClientName) as! String]) { (result, error) -> Void in
            if error == nil {
                print(result!)
                if ( self.device == nil ) {
                    self.device = TCDevice(capabilityToken: result as! String, delegate: self)
                } else {
                    self.device!.updateCapabilityToken(result as! String)
                }
                
                NSNotificationCenter.defaultCenter().postNotificationName(kNotifyLoginDidFinish, object: nil)
                self.loggedIn = true
            }
            else if error != nil && result != nil {
                NSNotificationCenter.defaultCenter().postNotificationName(kNotifyLoginDidFailWithError, object: nil)
            }
            else {
                NSNotificationCenter.defaultCenter().postNotificationName(kNotifyLoginDidFailWithError, object: nil)
            }
            self.endBackgroundUpdateTask()
        }
    }
    
    func capabilityTokenValid() -> Bool {
        var isValid:Bool = false
        
        if (self.device != nil) {
            let capabilities = NSDictionary(dictionary: self.device!.capabilities!)
            
            let expirationTimeObject:NSNumber = capabilities.objectForKey("expiration") as! NSNumber
            let expirationTimeValue:Int64 = expirationTimeObject.longLongValue
            let currentTimeValue:NSTimeInterval = NSDate().timeIntervalSince1970
            
            if( (expirationTimeValue-Int64(currentTimeValue)) > 0 ) {
                isValid = true
            }
        }
        
        return isValid;
    }
    
    func connect() {
        self.connectWithParams(nil)
    }
    
    func connectWithParams(dictParams: NSDictionary?) {
        if !self.capabilityTokenValid() {
            self.login()
        }
        let hasOutgoing = NSDictionary(dictionary: self.device!.capabilities!).objectForKey(TCDeviceCapabilityOutgoingKey) as! Bool
        if hasOutgoing {
            if self.connection != nil {
                self.disconnect()
            }
            
            self.connection = self.device?.connect(dictParams as! [NSObject : AnyObject], delegate: self)
            
            if self.connection == nil {
                NSNotificationCenter.defaultCenter().postNotificationName(kNotifyConnectionDidFailToConnect, object: nil)
            }
        }
    }
    
    func disconnect() {
        self.connection?.disconnect()
        NSNotificationCenter.defaultCenter().postNotificationName(kNotifyConnectionIsDisconnecting, object: nil)
    }
    
    func logout() {
        self.device?.unlisten()
        self.connection = nil
        self.pendingConnection = nil
        self.device = nil
        
    }
    
    func acceptConnection() {
        self.connection = self.pendingConnection
        self.pendingConnection = nil
        self.connection?.accept()
    }
    
    func rejectConnection() {
        self.pendingConnection?.reject()
        self.pendingConnection = nil
    }
    
    func ignoreConnection() {
        self.pendingConnection?.ignore()
        self.pendingConnection = nil
    }
    
    func beginBackgroundUpdateTask() {
        if self.backgroundTaskAgent == UIBackgroundTaskInvalid {
            self.backgroundTaskAgent = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({
                self.endBackgroundUpdateTask()
            })
        }
    }
    
    func endBackgroundUpdateTask() {
        if self.backgroundTaskAgent != UIBackgroundTaskInvalid {
            UIApplication.sharedApplication().endBackgroundTask(self.backgroundTaskAgent)
            self.backgroundTaskAgent = UIBackgroundTaskInvalid
        }
    }
    
    func errorFromHTTPResponse(response: NSHTTPURLResponse, domain: NSString) -> NSError{
        let localizedDescription = NSHTTPURLResponse.localizedStringForStatusCode(response.statusCode)
        let errorUserInfo = NSDictionary(object: localizedDescription, forKey: NSLocalizedDescriptionKey)
        let error = NSError(domain: domain as String, code: response.statusCode, userInfo: errorUserInfo as [NSObject : AnyObject])
        return error
    }
    
    //Mark TCDeviceDelegate
    
    public func deviceDidStartListeningForIncomingConnections(device: TCDevice!) {
        NSNotificationCenter.defaultCenter().postNotificationName(kNotifyDeviceDidStartListeningForIncomingConnections, object: nil)
    }
    
    public func device(device: TCDevice!, didStopListeningForIncomingConnections error: NSError!) {
        /*
        let userInfo: NSDictionary!
        if error != nil {
            userInfo = NSDictionary(object: error, forKey: "error")
        }
        //NSNotificationCenter.defaultCenter().postNotificationName(kNotifyDeviceDidStopListeningForIncomingConnections, object: nil, userInfo: userInfo as? [NSObject : AnyObject])
        */
        NSNotificationCenter.defaultCenter().postNotificationName(kNotifyDeviceDidStopListeningForIncomingConnections, object: nil)
    }
    
    public func device(device: TCDevice!, didReceiveIncomingConnection connection: TCConnection!) {
        print("Receiving an incoming connection")
        self.connection = connection
        if self.device?.state == TCDeviceState.Busy {
            self.connection?.reject()
        }
        else {
            self.pendingConnection = connection
            self.pendingConnection?.delegate = self
            let params = self.connection?.parameters
            NSNotificationCenter.defaultCenter().postNotificationName(kNotifyPendingIncomingConnectionReceived, object: nil, userInfo: params)
        }
    }
    
    //Mark TCConnectionDelegate
    public func connectionDidStartConnecting(connection: TCConnection!) {
        NSNotificationCenter.defaultCenter().postNotificationName(kNotifyConnectionIsConnecting, object: nil)
    }
    
    public func connectionDidConnect(connection: TCConnection!) {
        let device = UIDevice.currentDevice()
        device.proximityMonitoringEnabled = true
        //self.updat
    }
    
    public func connectionDidDisconnect(connection: TCConnection!) {
        if connection == self.connection {
            let device = UIDevice.currentDevice()
            device.proximityMonitoringEnabled = false
            self.connection = nil
            NSNotificationCenter.defaultCenter().postNotificationName(kNotifyConnectionDidDisconnect, object: nil)
        }
        else if connection == self.pendingConnection {
            self.pendingConnection = nil
            NSNotificationCenter.defaultCenter().postNotificationName(kNotifyPendingIncomingConnectionDidDisconnect, object: nil)
        }
    }
    
    public func connection(connection: TCConnection!, didFailWithError error: NSError!) {
        self.connection = nil
        let userInfo = NSDictionary(object: error, forKey: "error")
        NSNotificationCenter.defaultCenter().postNotificationName(kNotifyConnectionDidFailWithError, object: nil, userInfo: userInfo as [NSObject : AnyObject])
    }
    
    func updateAudioRoute() {
        if self.speakerEnabled {
            do {
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)
            }
            catch {
                
            }
        }
        else {
            do {
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.None)
            }
            catch {
                
            }
        }
    }
    
    func setMuted(muted: Bool) {
        if self.connection != nil {
            self.connection?.muted = muted
        }
    }
}
