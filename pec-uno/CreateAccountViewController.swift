//
//  LoginViewController.swift
//  pec-uno
//
//  Created by Julian Gernun on 31/3/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import UIKit

class CreateAccountViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var fullName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var pwd: UITextField!
    @IBOutlet weak var pwdRepeat: UITextField!
    
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
    
    @IBAction func register(sender: AnyObject) {
        let backendless = Backendless.sharedInstance()
        let user: BackendlessUser = BackendlessUser()
        user.email = email.text
        user.name = username.text
        user.password = pwd.text
        user.setProperty("fullName", object: fullName.text)

        backendless.userService.registering(user, response: { (registeredUser) -> Void in
            let email = registeredUser.email
            print("Usuario \(email) registrado correctamente") },
            error: { (error) -> Void in
                // Código en caso de error en el registro
                let message = error.message
                print("Error registrando al usuario: \(message)")
            })

    }
}
