//
//  Phone.swift
//  GCall
//
//  Created by Quoc Anh Nguyen on 10/27/15.
//  Copyright © 2015 gcall. All rights reserved.
//

import Foundation

let GCDefaultClientName:String = "QuocAnh-iPhone"
let GCBaseCapabilityTokenUrl:String = "http://gcalldemo.herokuapp.com/token"
let GCTwiMLAppSid:String = "AP49247f1fa0b6d92638aa2dbf9049682b"

public class Phone: NSObject, TCDeviceDelegate, TCConnectionDelegate {
    var device:TCDevice? = nil
    var connection:TCConnection? = nil
    var pendingConnection:TCConnection? = nil
    
    func login() {
        NSNotificationCenter.defaultCenter().postNotificationName(kNotifyLoginDidStart, object: nil)
        
        let url:String = self.getCapabilityTokenUrl()
        let swiftRequest = SwiftRequest()
        swiftRequest.get(url, callback: { (err, response, body) -> () in
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
            } else if ( err != nil && response != nil) {
                // We received and error with a response
                NSNotificationCenter.defaultCenter().postNotificationName(kNotifyLoginDidFailWithError, object: nil)
            } else if (err != nil) {
                // We received an error without a response
                NSNotificationCenter.defaultCenter().postNotificationName(kNotifyLoginDidFailWithError, object: nil)
            }
        })
    }
    
    func getCapabilityTokenUrl() -> String {
        
        //var querystring:String = String()
        //querystring += String(format:"&sid=%@", SPTwiMLAppSid)
        //querystring += String(format:"&client=%@", SPDefaultClientName)
        //return String(format:SPBaseCapabilityTokenUrl, querystring)
        //"http://gcall.herokuapp.com/token?client=%@", name
        //return SPBaseCapabilityTokenUrl
        
        return String(format: "http://gcalldemo.herokuapp.com/token?client=%@", "quocanh")
    }
    
    func connectWithParams(params dictParams:Dictionary<String,String>) {
        
        if (!self.capabilityTokenValid())
        {
            self.login()
        }
        self.connection = self.device?.connect(dictParams, delegate: self)
    }
    
    func capabilityTokenValid()->(Bool) {
        let isValid:Bool = false
        /*
        if (self.device != nil) {
            let capabilities = self.device!.capabilities as! NSDictionary
        
            let expirationTimeObject:NSNumber = capabilities.objectForKey("expiration") as! NSNumber
            let expirationTimeValue:Int64 = expirationTimeObject.longLongValue
            let currentTimeValue:NSTimeInterval = NSDate().timeIntervalSince1970
            
            if( (expirationTimeValue-Int64(currentTimeValue)) > 0 ) {
                isValid = true
            }
        }
        */
        return isValid
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
    
    public func deviceDidStartListeningForIncomingConnections(device: TCDevice!) {
        print("Started listening for incoming connections")
    }
    
    public func device(device: TCDevice!, didReceiveIncomingConnection connection: TCConnection!) {
        print("Receiving an incoming connection")
        self.connection = connection
        if self.device?.state == TCDeviceState.Busy {
            self.connection?.reject()
        }
        else {
            self.pendingConnection = connection
            NSNotificationCenter.defaultCenter().postNotificationName(
                kNotifyPendingIncomingConnectionReceived,
                object: nil,
                userInfo:nil)
        }
    }
    
    public func device(device: TCDevice!, didStopListeningForIncomingConnections error: NSError!) {
        print("Stopped listening for incoming connections")
    }
    
    public func connection(connection: TCConnection!, didFailWithError error: NSError!) {
        print("Connection didFailWithError")
    }
    
    public func connectionDidConnect(connection: TCConnection!) {
        print("Connection connectionDidConnect")
    }
    
    public func connectionDidStartConnecting(connection: TCConnection!) {
        print("Connection connectionDidStartConnecting")
    }
    
    public func connectionDidDisconnect(connection: TCConnection!) {
        print("Connection connectionDidDisconnect")
    }
}