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
    
    private let MIN_LENGTH = 6
    private let MAX_LENGTH = 30
    
    enum InputError: ErrorType {
        case inputMissing
        case pwdNotEqual
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //to avoid this view to overlap with the status bar
        self.tableView.contentInset = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0)
        
        initDelegates()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initDelegates() {
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
                if (letterRange != nil || numberRange != nil){
                    return true
                }
                return false
            case fullName:
                if (letterRange != nil || whitespaceRange != nil){
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
    
    private func checkFormErrors() -> Bool {
        if (username.text?.characters.count < MIN_LENGTH) {
            PecUtils.Alert(title: "Error", message: "Username to short.").showSimple(self)
            return true
        }
        
        if (fullName.text?.characters.count < MIN_LENGTH) {
            PecUtils.Alert(title: "Error", message: "Full username to short.").showSimple(self)
            return true
        }
        
        let regex = PecUtils.Regex("[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}")
        if (!regex.match(email.text!)) {
            PecUtils.Alert(title: "Error", message: "Wrong email pattern.").showSimple(self)
            return true
        }
        
        if (pwd.text?.characters.count < MIN_LENGTH) {
            PecUtils.Alert(title: "Error", message: "Password to short.").showSimple(self)
            return true
        }
        
        if (pwd.text != pwdRepeat.text) {
            PecUtils.Alert(title: "Error", message: "Passwords aren't the same.").showSimple(self)
            self.pwdRepeat.text = nil;
            self.pwd.text = nil;
            return true
        }

        return false
    }
    
    /*
        Called on 'create account' click
        Does API register request with user data
        Promps an error if needed
    */
    @IBAction func register(sender: AnyObject) {
        let errors = self.checkFormErrors()
        if (errors) {
            return
        }
        let backendless = Backendless.sharedInstance()
        let user: BackendlessUser = BackendlessUser()
        user.email = email.text
        user.name = username.text
        user.password = pwd.text
        user.setProperty("fullName", object: fullName.text)

        backendless.userService.registering(user,
            response: { (registeredUser) -> Void in
                let email = registeredUser.email
                print("Usuario \(email) registrado correctamente")
                PecUtils.Alert(title: "Success", message: "Welcome\n\(email)!")
                    .showSimple(self)
            },
            error: { (error) -> Void in
                // Código en caso de error en el registro
                let message = error.message
                print("Error registrando al usuario: \(message)")
                PecUtils.Alert(title: "API Error", message: message)
                    .showSimple(self)
            })

    }
}
