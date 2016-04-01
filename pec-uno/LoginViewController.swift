//
//  LoginViewController.swift
//  pec-uno
//
//  Created by Julian Gernun on 31/3/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    let APP_ID = "6C83ABA0-61D1-5E98-FFAC-358600659800"
    let SECRET_KEY = "A90E22B2-2EAF-ECB8-FFEF-0E6667AB8C00"
    let VERSION_NUM = "v1"
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var pwdTextField: UITextField!
    
    var backendless = Backendless.sharedInstance()
    private var indicador: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backendless.initApp(APP_ID, secret:SECRET_KEY, version:VERSION_NUM)
        self.initIndicator()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func showAlert(title: String, msg: String) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
        alertController.addAction(OKAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func initIndicator() {
        self.indicador.autoresizingMask = [.FlexibleBottomMargin, .FlexibleLeftMargin, .FlexibleWidth, .FlexibleRightMargin, .FlexibleTopMargin, .FlexibleHeight, .FlexibleBottomMargin]
        self.indicador.hidesWhenStopped = true
        self.indicador.center = self.view.center
        self.indicador.activityIndicatorViewStyle = .WhiteLarge
        self.indicador.color = UIColor.grayColor()
        self.view.addSubview(self.indicador)
    }
    
    private func clearForm() {
        self.pwdTextField.text = nil;
    }
    
    private func startIndicator() {
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        indicador.startAnimating()
    }
    
    private func stopIndicator() {
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        indicador.stopAnimating()
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
        self.startIndicator()
//        
//        backendless.userService.login(
//            userNameTextField.text, password: pwdTextField.text,
//            response: { (let registeredUser : BackendlessUser!) -> () in
//                self.stopIndicator()
//                print("User has been logged in (ASYNC): \(registeredUser)")
//            },
//            error: { (let fault : Fault!) -> () in
//                self.stopIndicator()
//                print("Server reported an error: \(fault)")
//                self.clearForm()
//                self.showAlert("Error", msg: "Incorrect credentials")
//                
//            }
//        )
    }

}
