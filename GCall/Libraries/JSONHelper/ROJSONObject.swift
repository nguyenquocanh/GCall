//
//  JSONObject.swift
//  RASCOcloud
//
//  Created by Robin Oster on 02/07/14.
//  Copyright (c) 2014 Robin Oster. All rights reserved.
//

import Foundation

class ROJSONObject {
    
    var jsonData:JSON

    required init() {
        jsonData = []
    }
    
    required init(jsonData:AnyObject) {
        self.jsonData = JSON(jsonData)
    }
    
    required init(jsonString:String) {
        let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        var error:NSError?
        
        if let _ = data {
            var json:AnyObject?
            do {
                json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
            } catch let error1 as NSError {
                error = error1
                json = nil
            }
            
            if (error != nil) {
                print("Something went wrong during the creation of the json dict \(error)")
            } else {
                self.jsonData = JSON(json!)
                return
            }
        }
        
        self.jsonData = JSON("")
    }

    func getJSONValue(key:String) -> JSON {
        return jsonData[key]
    }
    
    func getValue(key:String) -> AnyObject {
        return jsonData[key].object
    }
    
    /*
    func getArray<T : ROJSONObject>(key:String) -> [T] {
        var elements = [T]()
        println("...............1")
        for jsonValue in getJSONValue(key).array! {
            println("...............2")
            var element = (T.self as T.Type)()
            
            element.jsonData = jsonValue
            elements.append(element)
        }
        println("...............3")
        return elements
    }*/
    
    func getArray<T : ROJSONObject>(key:String) -> [T] {
        var elements = [T]()
        if let temp = getJSONValue(key).array {
            for jsonValue in temp {
                let element = (T.self as T.Type).init()
                element.jsonData = jsonValue
                elements.append(element)
            }
            return elements
        }
        return elements
    }
    
    func getDate(key:String, dateFormatter:NSDateFormatter? = nil) -> NSDate? {
        // TODO: implement your own data parsing
        return nil
    }
}

class Value<T> {
    class func get(rojsonobject:ROJSONObject, key:String) -> T {
        return rojsonobject.getValue(key) as! T
    }
    
    class func getArray<T : ROJSONObject>(rojsonobject:ROJSONObject, key:String? = nil) -> [T] {
        
        // If there is a key given fetch the array from the dictionary directly if not fetch all objects and pack it into an array
        if let dictKey = key {
            return rojsonobject.getArray(dictKey) as [T]
        } else {
            var objects = [T]()
            
            for jsonValue in rojsonobject.jsonData.array! {
                let object = (T.self as T.Type).init()
                object.jsonData = jsonValue
                objects.append(object)
            }
            
            return objects
        }
    }
    
    class func getDate(rojsonobject:ROJSONObject, key:String, dateFormatter:NSDateFormatter? = nil) -> NSDate? {
        return rojsonobject.getDate(key, dateFormatter: dateFormatter)
    }
}