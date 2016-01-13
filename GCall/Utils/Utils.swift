//
//  Utils.swift
//  GooglyPuff
//
//  Created by Bjørn Olav Ruud on 07.08.14.
//  Copyright (c) 2014 raywenderlich.com. All rights reserved.
//

import Foundation
import UIKit

var GlobalMainQueue: dispatch_queue_t {
  return dispatch_get_main_queue()
}
/*
var GlobalUserInteractiveQueue: dispatch_queue_t {
  return dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.rawValue), 0)
}

var GlobalUserInitiatedQueue: dispatch_queue_t {
  return dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)
}

var GlobalUtilityQueue: dispatch_queue_t {
  return dispatch_get_global_queue(Int(QOS_CLASS_UTILITY.rawValue), 0)
}

var GlobalBackgroundQueue: dispatch_queue_t {
  return dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.rawValue), 0)
}
*/

class Utils {
    
    class func controllerAvailable(classStr: String) -> Bool {
        if let _: AnyClass = NSClassFromString(classStr) {
            return true
        }
        else {
            return false
        }
    }
    
    class func verticalOffsetForTop(scrollView: UIScrollView) -> CGFloat {
        let topInset = scrollView.contentInset.top
        return topInset
    }
    
    class func verticalOffsetForBottom(scrollView: UIScrollView) -> CGFloat {
        let scrollViewHeight = scrollView.bounds.size.height
        let scrollContentSizeHeight = scrollView.contentSize.height
        let bottomInset = scrollView.contentInset.bottom
        let scrollViewBottomOffset = scrollContentSizeHeight + bottomInset - scrollViewHeight
        return scrollViewBottomOffset
    }
    
    class func RemoveCharacterFromString(string: NSString) -> NSString {
        var stringWithoutSpace: NSString = ""
        if string.rangeOfString(" ").location != NSNotFound {
            stringWithoutSpace = string.stringByReplacingOccurrencesOfString(" ", withString: "%20", options: NSStringCompareOptions.LiteralSearch, range: NSMakeRange(0, string.length))
            return stringWithoutSpace
        }else {
            return string
        }
    }
    
    class func dispatchOnMainThread(delay: Double = 0, block: () -> ()) {
        if delay == 0 {
            dispatch_async(dispatch_get_main_queue()) {
                block()
            }
            return
        }
        
        let d = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
        dispatch_after(d, dispatch_get_main_queue()) {
            block()
        }
    }
    
    class func saveUser(user:User) {
        let filename = NSHomeDirectory().stringByAppendingString("/Documents/account.bin")
        let data = NSKeyedArchiver.archivedDataWithRootObject(user)
        data.writeToFile(filename, atomically: true)
        let urlFilePath: NSURL? = NSURL(fileURLWithPath: filename)
        if let url = urlFilePath {
            do {
                try url.setResourceValue(true, forKey: NSURLIsExcludedFromBackupKey)
            } catch _ {
            }
        }
    }
    
    class func getUser() -> User? {
        if let data = NSData(contentsOfFile: NSHomeDirectory().stringByAppendingString("/Documents/account.bin")) {
            let unarchiveAccounts = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! User?
            if let unwrappedAccounts = unarchiveAccounts {
                return unwrappedAccounts
            }
            else {
                return nil
            }
        }
        else {
            return nil
        }
    }
    
    static let mainStoryboard = UIStoryboard(name: (DeviceType.IS_IPAD) ? "Main_iPad" : "Main_iPhone", bundle: nil)
}

public extension Int {
    public static func random(lower lower: Int, upper: Int) -> Int {
        return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
    }
}

extension Array {
    func contains<T where T: Equatable>(obj: T) -> Bool {
        return self.filter({$0 as? T == obj}).count > 0
    }
    
    func binarySearch<T : Comparable>(array: [T], target: T) -> Bool {
        var left = 0
        var right = array.count - 1
        
        while (left <= right) {
            let mid = (left + right) / 2
            let value = array[mid]
            
            if (value == target) {
                return true
            }
            
            if (value < target) {
                left = mid + 1
            }
            
            if (value > target) {
                right = mid - 1
            }
        }
        
        return false
    }
    func insertSorted<T: Comparable>(inout seq: [T], newItem item: T) {
        let index = seq.reduce(0) { $1 < item ? $0 + 1 : $0 }
        seq.insert(item, atIndex: index)
    }
}

extension String {
    
    func base64Encoded() -> String {
        let plainData = dataUsingEncoding(NSUTF8StringEncoding)
        let base64String = plainData?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        return base64String!
    }
    
    func base64Decoded() -> String {
        let decodedData = NSData(base64EncodedString: self, options:NSDataBase64DecodingOptions(rawValue: 0))
        let decodedString = NSString(data: decodedData!, encoding: NSUTF8StringEncoding)
        return decodedString as! String
    }
}

extension NSString {
    func removeCharacter(str: String, replace: String) -> NSString {
        var stringNew: NSString = ""
        if self.rangeOfString(str).location != NSNotFound {
            stringNew = self.stringByReplacingOccurrencesOfString(str, withString: replace, options: NSStringCompareOptions.LiteralSearch, range: NSMakeRange(0, self.length))
            return stringNew
        }else {
            return self
        }
    }
}

extension UIButton {
    func initButtonWithColor(bgColor: UIColor, withShadow: UIColor) {
        self.clipsToBounds = true
        self.layer.cornerRadius = 6
        self.backgroundColor = bgColor
        let line = UIView(frame: CGRectMake(0, self.frame.size.height - 3, self.frame.size.width, 3))
        line.backgroundColor = withShadow
        self.addSubview(line)
    }
}

extension UIApplicationState {
    
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