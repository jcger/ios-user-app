//
//  LoginViewController.swift
//  pec-uno
//
//  Created by Julian Gernun on 31/3/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import UIKit
import PecUtils

class LoginViewController: UIViewController {
    let APP_ID = "6C83ABA0-61D1-5E98-FFAC-358600659800"
    let SECRET_KEY = "A90E22B2-2EAF-ECB8-FFEF-0E6667AB8C00"
    let VERSION_NUM = "v1"
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var pwdTextField: UITextField!
    
    var backendless = Backendless.sharedInstance()
    var indicator = PecUtils.Indicator()
    let shareData = PecUtils.ShareData.sharedInstance
    
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
    
    private func clearForm() {
        self.pwdTextField.text = nil;
    }
    
    private func goToProfile() {
        let profileViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ProfileViewController")
        let navigationController = UINavigationController(rootViewController: profileViewController!)
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    
    /*
    Called when user clicks on submit
    Does login API request and show alert on error
    */
    @IBAction func loginAction(sender: AnyObject) {
        indicator.show(view)
        
        backendless.userService.login(
            userNameTextField.text, password: pwdTextField.text,
            response: { (let registeredUser : BackendlessUser!) -> () in
//                print("User has been logged in (ASYNC): \(registeredUser)")
                self.indicator.hide()
                print("First")
                print(registeredUser.email)
                self.shareData.email = registeredUser.email
                self.shareData.object = registeredUser
                self.goToProfile()
            },
            error: { (let fault : Fault!) -> () in
//                print("Server reported an error: \(fault)")
                self.indicator.hide()
                self.clearForm()
                PecUtils.Alert(title: "Error", message: "Incorrect credentials")
                    .showSimple(self)
                self.shareData.object = nil
            }
        )
    }
    
}
