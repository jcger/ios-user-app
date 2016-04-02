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
    @IBOutlet weak var register: UIButton!
    
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
    
    func initDelegates() {
        username.delegate = self
        fullName.delegate = self
        email.delegate = self
        pwd.delegate = self
        pwdRepeat.delegate = self
    }

    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        print("OMG")
        
        switch textField {
        case username: fullName.becomeFirstResponder()
        case fullName: email.becomeFirstResponder()
        case email: pwd.becomeFirstResponder()
        case pwd: pwdRepeat.becomeFirstResponder()
        default: textField.resignFirstResponder()
        }
        
        return false
        
    }
}
