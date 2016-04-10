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
    @IBOutlet weak var usernameErrorText: UILabel!
    @IBOutlet weak var fullnameErrorText: UILabel!
    @IBOutlet weak var emailErrorText: UILabel!
    @IBOutlet weak var pwdErrorText: UILabel!
    
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
    
    private func resetErrorHighlight() {
        usernameErrorText.hidden = true
        fullnameErrorText.hidden = true
        emailErrorText.hidden = true
        pwdErrorText.hidden = true
    }
    
    private func checkFormErrors() -> Bool {
        var containsError: Bool = false
        self.resetErrorHighlight()
        
        if (username.text?.characters.count < MIN_LENGTH) {
            usernameErrorText.text = "Too short"
            containsError = true
            usernameErrorText.hidden = false
        }
        
        if (fullName.text?.characters.count < MIN_LENGTH) {
            fullnameErrorText.text = "Too short"
            containsError = true
            fullnameErrorText.hidden = false
        }
        
        let regex = PecUtils.Regex("[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}")
        if (!regex.match(email.text!)) {
            emailErrorText.text = "Wrong email pattern"
            containsError = true
            emailErrorText.hidden = false
        }
        
        if (pwd.text?.characters.count < MIN_LENGTH) {
            pwdErrorText.text = "Too short"
            containsError = true
            pwdErrorText.hidden = false

        } else if (pwd.text != pwdRepeat.text) {
            pwdErrorText.text = "Passwords don't match"
            containsError = true
            pwdErrorText.hidden = false
        }
        
        if containsError == true {
            self.pwdRepeat.text = nil
            self.pwd.text = nil
            PecUtils.Alert(title: "Error", message: "There are errors on the form.\nPlease fix them before continuing.")
                .showSimple(self)
        }
        
        return containsError
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
