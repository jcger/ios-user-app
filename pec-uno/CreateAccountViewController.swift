//
//  LoginViewController.swift
//  pec-uno
//
//  Created by Julian Gernun on 31/3/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import UIKit
import PecUtils

class CreateAccountViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var fullName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var pwd: UITextField!
    @IBOutlet weak var pwdRepeat: UITextField!
    
    private let MIN_LENGTH = 3
    private let MAX_LENGTH = 30
    private var indicator = PecUtils.Indicator()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initDelegates()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func initDelegates() {
        username.delegate = self
        fullName.delegate = self
        email.delegate = self
        pwd.delegate = self
        pwdRepeat.delegate = self
    }

    /*
        Function called on keyboards 'next' click
        Sets focus on the next text field
    */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
            case username: fullName.becomeFirstResponder()
            case fullName: email.becomeFirstResponder()
            case email: pwd.becomeFirstResponder()
            case pwd: pwdRepeat.becomeFirstResponder()
            default: textField.resignFirstResponder()
        }
        
        return false
    }
    
    func textField(textField: UITextField,
        shouldChangeCharactersInRange range: NSRange,
        replacementString string: String)
        -> Bool
    {
        // ignores changes that doesn't add characters, like backspace
        if string.characters.count == 0 {
            return true
        }
        
        if (textField.text?.characters.count > MAX_LENGTH) {
            return false
        }
        
        let letterRange = string.rangeOfCharacterFromSet(NSCharacterSet.letterCharacterSet())
        let numberRange = string.rangeOfCharacterFromSet(NSCharacterSet.decimalDigitCharacterSet())
        let whitespaceRange = string.rangeOfCharacterFromSet(NSCharacterSet.whitespaceCharacterSet())
        
        switch textField {
            case username:
                if (letterRange != nil || numberRange != nil) {
                    return true
                }
                return false
            case fullName:
                if (letterRange != nil || whitespaceRange != nil) {
                    return true
                }
                return false
            case email:
                if (letterRange != nil || numberRange != nil || string == "@" || string == ".") {
                    return true
                }
                return false
            default:
                return true
        }
        
    }
    
    private func highlightError(field: UITextField) {
        let errorColor: UIColor = UIColor( red: 1.0, green: 0.0, blue:0.0, alpha: 1.0 )
        field.layer.borderColor = errorColor.CGColor
        field.layer.borderWidth = 1
        field.layer.cornerRadius = 5.0
    }
    
    private func resetErrorHighlight() {
        username.layer.borderWidth = 0
        fullName.layer.borderWidth = 0
        email.layer.borderWidth = 0
        pwd.layer.borderWidth = 0
        pwdRepeat.layer.borderWidth = 0
    }
    
    private func checkFormErrors() -> Bool {
        var errorMsg: String = String()
        self.resetErrorHighlight()
        
        if (username.text?.characters.count < MIN_LENGTH) {
            self.highlightError(username)
            errorMsg += " - Username too short.(Min: \(MIN_LENGTH))\n"
        }
        
        if (fullName.text?.characters.count < MIN_LENGTH) {
            self.highlightError(fullName)
            errorMsg += " - Full name too short.(Min: \(MIN_LENGTH))\n"
        }
        
        let regex = PecUtils.Regex("[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}")
        if (!regex.match(email.text!)) {
            self.highlightError(email)
            errorMsg += " - Wrong email pattern.\n"
        }
        
        if (pwd.text?.characters.count < MIN_LENGTH) {
            self.highlightError(pwd)
            errorMsg += " - Password too short. (Min: \(MIN_LENGTH))\n"

        } else if (pwd.text != pwdRepeat.text) {
            errorMsg += " - Passwords aren't the same.\n"
        }
        
        if errorMsg.isEmpty {
            return false
        } else {
            self.pwdRepeat.text = nil
            self.pwd.text = nil
            PecUtils.Alert(title: "Error", message: errorMsg)
                .showSimple(self)

            return true
        }
    }
    
    /*
        Called on 'create account' click
        Does API register request with user data
        Prompts an error if needed
    */
    @IBAction func register(sender: AnyObject) {
        let errors = self.checkFormErrors()
        if (errors) {
            return
        }
        
        self.indicator.show(view);
        let backendless = Backendless.sharedInstance()
        let user: BackendlessUser = BackendlessUser()
        user.email = email.text
        user.name = username.text
        user.password = pwd.text
        user.setProperty("fullname", object: fullName.text)

        backendless.userService.registering(user,
            response: { (registeredUser) -> Void in
                self.indicator.hide()
                PecUtils.Alert(title: "Success", message: "Account created successfully!")
                    .showSimple(self, callback: self.back)
            },
            error: { (error) -> Void in
                let message = error.message
                self.indicator.hide()
                PecUtils.Alert(title: "API Error", message: message)
                    .showSimple(self)
            })

    }
    
    private func back() -> Bool {
        if let navController = self.navigationController {
            dispatch_async(dispatch_get_main_queue()) {
                navController.popViewControllerAnimated(true)
                self.indicator.hide();
            }
        }
        return true;
    }
    
    @IBAction func back(sender: AnyObject) {
        self.back();
    }
}
