//
//  User.swift
//  GCall
//
//  Created by Quoc Anh Nguyen on 11/2/15.
//  Copyright © 2015 gcall. All rights reserved.
//

import UIKit

class User: NSObject, NSCoding {
    var username: String
    var email:String
    var phone:String
    var link:String
    var sid:String
    var token:String
    
    init(username:String, email:String,phone:String,link:String,sid:String,token:String) {
        self.username = username
        self.email = email
        self.phone = phone
        self.link = link
        self.sid = sid
        self.token = token
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.username = aDecoder.decodeObjectForKey("username") as! String
        self.email = aDecoder.decodeObjectForKey("email") as! String
        self.phone = aDecoder.decodeObjectForKey("phone") as! String
        self.link = aDecoder.decodeObjectForKey("link") as! String
        self.sid = aDecoder.decodeObjectForKey("sid") as! String
        self.token = aDecoder.decodeObjectForKey("token") as! String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.username, forKey: "username")
        aCoder.encodeObject(self.email, forKey: "email")
        aCoder.encodeObject(self.phone, forKey: "phone")
        aCoder.encodeObject(self.link, forKey: "link")
        aCoder.encodeObject(self.sid, forKey: "sid")
        aCoder.encodeObject(self.token, forKey: "token")
    }
}
