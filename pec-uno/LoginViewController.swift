//
//  LoginViewController.swift
//  pec-uno
//
//  Created by Julian Gernun on 31/3/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    let APP_ID = ""
    let SECRET_KEY = ""
    let VERSION_NUM = "v1"
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var pwdTextField: UITextField!
    
    var backendless = Backendless.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backendless.initApp(APP_ID, secret:SECRET_KEY, version:VERSION_NUM)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func loginAction(sender: AnyObject) {
        print("OMG")
        backendless.userService.login(
            userNameTextField.text, password: pwdTextField.text,
            response: { (let registeredUser : BackendlessUser!) -> () in
                print("User has been logged in (ASYNC): \(registeredUser)")
            },
            error: { (let fault : Fault!) -> () in
                print("Server reported an error: \(fault)")
            }
        )
    }
}
