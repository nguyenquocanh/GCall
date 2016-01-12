//
//  SignUpViewController.swift
//  GCall
//
//  Created by Quoc Anh Nguyen on 10/26/15.
//  Copyright © 2015 gcall. All rights reserved.
//

import UIKit
import Parse

protocol SignUpViewControllerDelegate {
    func signupSuccess(signUpViewController: SignUpViewController, userName:String, password: String)
}

class SignUpViewController: UIViewController {
    
    var delegate: SignUpViewControllerDelegate!
    private var overFrame: CGRect!
    
    @IBOutlet weak var txtPhoneNumber: JJMaterialTextfield!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var txtPassword: JJMaterialTextfield!
    @IBOutlet weak var txtRePassword: JJMaterialTextfield!
    @IBOutlet weak var txtUserName: JJMaterialTextfield!
    @IBOutlet weak var txtEmail: JJMaterialTextfield!
    @IBOutlet weak var txtLinkSite: JJMaterialTextfield!
    @IBOutlet weak var viewPadding: UIView!
    @IBOutlet weak var viewBody: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.viewPadding.initViewWithColor(self.view.backgroundColor!, withBorder: true)
        self.viewBody.initViewWithColor(UIColor.whiteColor(), withBorder: false)
        
        self.btnSignUp.initButtonWithBackgroundColor(UIColor(red: 82/255, green: 25/255, blue: 126/255, alpha: 1.0), withTextColor: UIColor.whiteColor(), withBorderColor: nil)
        self.btnSignUp.addTarget(self, action: "didSignUp", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.btnCancel.addTarget(self, action: "didCancel", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.txtUserName.enableMaterialPlaceHolder(true)
        self.txtUserName.errorColor = UIColor.redColor()
        self.txtUserName.lineColor = UIColor(red: 82/255, green: 25/255, blue: 126/255, alpha: 1.0)
        self.txtUserName.tintColor = UIColor(red: 82/255, green: 25/255, blue: 126/255, alpha: 1.0)
        self.txtUserName.placeholder = "Account name"
        self.txtUserName.delegate = self
        self.txtUserName.returnKeyType = UIReturnKeyType.Next
        self.txtUserName.tag = 1
        
        self.txtPassword.enableMaterialPlaceHolder(true)
        self.txtPassword.errorColor = UIColor.redColor()
        self.txtPassword.lineColor = UIColor(red: 82/255, green: 25/255, blue: 126/255, alpha: 1.0)
        self.txtPassword.tintColor = UIColor(red: 82/255, green: 25/255, blue: 126/255, alpha: 1.0)
        self.txtPassword.placeholder = "Password"
        self.txtPassword.delegate = self
        self.txtPassword.secureTextEntry = true
        self.txtPassword.returnKeyType = UIReturnKeyType.Next
        self.txtPassword.tag = 2
        
        self.txtRePassword.enableMaterialPlaceHolder(true)
        self.txtRePassword.errorColor = UIColor.redColor()
        self.txtRePassword.lineColor = UIColor(red: 82/255, green: 25/255, blue: 126/255, alpha: 1.0)
        self.txtRePassword.tintColor = UIColor(red: 82/255, green: 25/255, blue: 126/255, alpha: 1.0)
        self.txtRePassword.placeholder = "Re-Password"
        self.txtRePassword.delegate = self
        self.txtRePassword.secureTextEntry = true
        self.txtRePassword.returnKeyType = UIReturnKeyType.Next
        self.txtRePassword.tag = 3
        
        self.txtEmail.enableMaterialPlaceHolder(true)
        self.txtEmail.errorColor = UIColor.redColor()
        self.txtEmail.lineColor = UIColor(red: 82/255, green: 25/255, blue: 126/255, alpha: 1.0)
        self.txtEmail.tintColor = UIColor(red: 82/255, green: 25/255, blue: 126/255, alpha: 1.0)
        self.txtEmail.placeholder = "Email"
        self.txtEmail.delegate = self
        self.txtEmail.returnKeyType = UIReturnKeyType.Next
        self.txtEmail.tag = 4
        
        self.txtPhoneNumber.enableMaterialPlaceHolder(true)
        self.txtPhoneNumber.errorColor = UIColor.redColor()
        self.txtPhoneNumber.lineColor = UIColor(red: 82/255, green: 25/255, blue: 126/255, alpha: 1.0)
        self.txtPhoneNumber.tintColor = UIColor(red: 82/255, green: 25/255, blue: 126/255, alpha: 1.0)
        self.txtPhoneNumber.placeholder = "Phone number"
        self.txtPhoneNumber.delegate = self
        self.txtPhoneNumber.returnKeyType = UIReturnKeyType.Next
        self.txtPhoneNumber.tag = 5
        
        self.txtLinkSite.enableMaterialPlaceHolder(true)
        self.txtLinkSite.errorColor = UIColor.redColor()
        self.txtLinkSite.lineColor = UIColor(red: 82/255, green: 25/255, blue: 126/255, alpha: 1.0)
        self.txtLinkSite.tintColor = UIColor(red: 82/255, green: 25/255, blue: 126/255, alpha: 1.0)
        self.txtLinkSite.placeholder = "Link site"
        self.txtLinkSite.delegate = self
        self.txtLinkSite.returnKeyType = UIReturnKeyType.Done
        self.txtLinkSite.tag = 6
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleKeyboardShowHide:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleKeyboardShowHide:", name: UIKeyboardWillHideNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didSignUp() {
        if self.txtUserName.text! == "" || self.txtPassword.text! == "" || self.txtRePassword.text! == "" || self.txtEmail.text! == "" || self.txtPhoneNumber.text! == "" || self.txtLinkSite.text! == "" {
            ViewManager.sharedInstance.alertViewWithTitle("Please enter your info!").show()
        }
        else {
            if self.txtPassword.text! == self.txtRePassword.text! {
                ViewManager.sharedInstance.startIndicatorView()
                let user = PFUser()
                user.username = self.txtUserName.text!
                user.password = self.txtPassword.text!
                user.email = self.txtEmail.text!
                // other fields can be set just like with PFObject
                user["phone"] = self.txtPhoneNumber.text!
                user["link"] = self.txtLinkSite.text!
                
                user.signUpInBackgroundWithBlock {
                    (succeeded: Bool, error: NSError?) -> Void in
                    if let error = error {
                        let errorString = error.userInfo["error"] as? NSString
                        // Show the errorString somewhere and let the user try again.
                        print("save user error: \(errorString)")
                        ViewManager.sharedInstance.stopIndicatorView({
                            ViewManager.sharedInstance.alertViewWithTitle(errorString as! String).show()
                        })
                    } else {
                        // Hooray! Let them use the app now.
                        let swiftRequest = SwiftRequest()
                        swiftRequest.post("https://api.twilio.com/2010-04-01/Accounts.json", data: ["FriendlyName":self.txtEmail.text!], auth: ["username":"AC337b9c85813f33fe9dfa3a030d1d8117", "password":"cf52c7bed14343a9a7e821fffb1d3350"]) { (err, response, body) -> () in
                            if err == nil {
                                let json = JSON(body!)
                                let userLogin = try! PFUser.logInWithUsername(self.txtUserName.text!, password:self.txtPassword.text!)
                                userLogin["sid"] = json["sid"].stringValue
                                userLogin["token"] = json["auth_token"].stringValue
                                userLogin.saveInBackgroundWithBlock({ (success, error) -> Void in
                                    if success {
                                        PFCloud.callFunctionInBackground("mailSend", withParameters: ["target": self.txtEmail.text!,"originator": "postmaster@gcall.vn","subject": "You has registered GCALL Service ","text": "This is your iOS originated mail"], block: { (result, error) -> Void in
                                            PFUser.logOut()
                                            ViewManager.sharedInstance.stopIndicatorView({
                                                self.dismissViewControllerAnimated(true, completion: {
                                                    self.delegate.signupSuccess(self, userName: self.txtUserName.text!, password: self.txtPassword.text!)
                                                })
                                            })
                                        })
                                    }
                                    else {
                                        ViewManager.sharedInstance.stopIndicatorView({
                                            print("error saveInBackgroundWithBlock")
                                            ViewManager.sharedInstance.alertViewWithTitle("Signup failed!").show()
                                        })
                                    }
                                })
                            }
                            else {
                                ViewManager.sharedInstance.stopIndicatorView({
                                    print("Error: \(err)")
                                    ViewManager.sharedInstance.alertViewWithTitle("Signup failed!").show()
                                })
                            }
                        }
                    }
                }
            }
            else {
                print("Re-password error")
                ViewManager.sharedInstance.alertViewWithTitle("Oops! re-password failed").show()
            }
        }
    }
    
    func didCancel() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //Keyboard event
    func handleKeyboardShowHide(notification: NSNotification) {
        if notification.name == "UIKeyboardWillHideNotification" {
            var frame = self.view.frame
            frame.origin.y = 0.0
            self.view.frame = frame
            return
        }
        
        let dictKeyboard = NSDictionary(dictionary: notification.userInfo!)
        let frameKeyboard = dictKeyboard.objectForKey(UIKeyboardFrameEndUserInfoKey)?.CGRectValue
        if frameKeyboard!.origin.y > self.overFrame.origin.y {
            var frame = self.view.frame
            frame.origin.y = -(frameKeyboard!.size.height - self.btnSignUp.frame.size.height - 50)
            self.view.frame = frame
        }
    }
}

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let view = self.view.viewWithTag(textField.tag + 1)
        
        if let unwrapView = view {
            unwrapView.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
        }
        return true
    }

    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        //print("textFieldShouldBeginEditing")
        self.overFrame = textField.frame
        //print("- \(self.overFrame.origin.y)")
        return true
    }
}
