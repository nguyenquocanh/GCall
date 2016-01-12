//
//  LoginViewController.swift
//  GCall
//
//  Created by Quoc Anh Nguyen on 10/26/15.
//  Copyright © 2015 gcall. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var txtPassword: JJMaterialTextfield!
    @IBOutlet weak var txtUserName: JJMaterialTextfield!
    @IBOutlet weak var viewPadding: UIView!
    @IBOutlet weak var viewBody: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.viewPadding.initViewWithColor(self.view.backgroundColor!, withBorder: true)
        self.viewBody.initViewWithColor(UIColor.whiteColor(), withBorder: false)
        
        self.btnLogin.initButtonWithBackgroundColor(UIColor(red: 82/255, green: 25/255, blue: 126/255, alpha: 1.0), withTextColor: UIColor.whiteColor(), withBorderColor: nil)
        self.btnLogin.addTarget(self, action: "didLogin", forControlEvents: UIControlEvents.TouchUpInside)
        self.btnSignUp.initButtonWithBackgroundColor(UIColor.whiteColor(), withTextColor: UIColor(red: 82/255, green: 25/255, blue: 126/255, alpha: 1.0), withBorderColor: UIColor(red: 82/255, green: 25/255, blue: 126/255, alpha: 1.0))
        self.btnSignUp.addTarget(self, action: "didSignUp", forControlEvents: UIControlEvents.TouchUpInside)
                self.txtUserName.enableMaterialPlaceHolder(true)
        self.txtUserName.errorColor = UIColor.redColor()
        self.txtUserName.lineColor = UIColor(red: 82/255, green: 25/255, blue: 126/255, alpha: 1.0)
        self.txtUserName.tintColor = UIColor(red: 82/255, green: 25/255, blue: 126/255, alpha: 1.0)
        self.txtUserName.placeholder = "Username"
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
        self.txtPassword.returnKeyType = UIReturnKeyType.Done
        self.txtPassword.tag = 2

        let panel1 = MYIntroductionPanel(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height), title: "Click to call on website", description: "Transfer to mobile number when the internet signal is too weak. Send waiting message when there is no staff.", image: UIImage(named: "click_to_call"))
        
        let panel2 = MYIntroductionPanel(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height), title: "Mini call center", description: "Build your own call center within 60s in your smartphone with 3 free accounts. Balance staff's workload.", image: UIImage(named: "mini_call_center"))
        
        let panel3 = MYIntroductionPanel(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height), title: "Outsource call center", description: "Use outsourced call center with multi-languages and multi-professional skills whenever your employees overload. Pay as you go.", image: UIImage(named: "outsource_call_center"))
        
        let panel4 = MYIntroductionPanel(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height), title: "ENJOY!", description: nil, image: UIImage(named: "enjoy_gcall"))
        
        let panels = NSArray(array: [panel1,panel2,panel3,panel4])
        
        let introductionView = MYBlurIntroductionView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))
        //introductionView.backgroundColor = UIColor(red: 82/255, green: 25/255, blue: 126/255, alpha: 1.0)
        introductionView.delegate = self
        introductionView.setBackgroundColor(UIColor(red: 82/255, green: 25/255, blue: 126/255, alpha: 1.0))
        introductionView.buildIntroductionWithPanels(panels as [AnyObject])
        self.view.addSubview(introductionView)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didLogin() {
        if self.txtUserName.text == "" || self.txtPassword.text == "" {
            ViewManager.sharedInstance.alertViewWithTitle("Please enter information!").show()
        }
        else {
            PFUser.logInWithUsernameInBackground(self.txtUserName.text!, password:self.txtPassword.text!) {(user: PFUser?, error: NSError?) -> Void in
                if user != nil {
                    print("The login success")
                    // Do stuff after successful login.
                    let userLocal = User(username: user!.username!, email: user!.email!, phone: user?.objectForKey("phone") as! String, link: user?.objectForKey("link") as! String, sid: user?.objectForKey("sid") as! String, token: user?.objectForKey("token") as! String)
                    Utils.saveUser(userLocal)
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    let phoneViewController = Utils.mainStoryboard.instantiateViewControllerWithIdentifier("PhoneViewController") as? PhoneViewController
                    appDelegate.window?.rootViewController = phoneViewController
                } else {
                    // The login failed. Check error to see why.
                    //print("The login failed. Check error to see why \(error)")
                    ViewManager.sharedInstance.alertViewWithTitle("The login failed!").show()
                }
            }
        }
    }
    
    func didSignUp() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let signupViewController = Utils.mainStoryboard.instantiateViewControllerWithIdentifier("SignUpViewController") as? SignUpViewController
        signupViewController?.delegate = self
        appDelegate.window?.rootViewController?.presentViewController(signupViewController!, animated: true, completion: nil)
    }
}

extension LoginViewController: UITextFieldDelegate {
    
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
}

extension LoginViewController: SignUpViewControllerDelegate {
    func signupSuccess(signUpViewController: SignUpViewController, userName: String, password: String) {
        self.txtUserName.text = userName
        self.txtPassword.text = password
        self.didLogin()
    }
}

extension LoginViewController: MYIntroductionDelegate {
    func introduction(introductionView: MYBlurIntroductionView!, didFinishWithType finishType: MYFinishType) {
        print("finish")
    }
}
