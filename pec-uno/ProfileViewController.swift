//
//  ProfileViewController.swift
//  pec-uno
//
//  Created by Julian Gernun on 4/4/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import Foundation

import UIKit
import PecUtils

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var username: UILabel!
    
    private var currentUser: BackendlessUser?
    private var backendless = Backendless.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUser()
        if (self.isLoggedIn()) {
            self.loadData()
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func goToLogin() {
        let profileViewController = self.storyboard?.instantiateViewControllerWithIdentifier("LoginViewController")
        let navigationController = UINavigationController(rootViewController: profileViewController!)
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    private func isLoggedIn() -> Bool {
        return self.currentUser != nil
    }
    
    private func loadData() {
        print(currentUser);
        username.text = currentUser!.name;
        email.text = currentUser!.email;
        let bla = currentUser!.getProperty("fullname") as! String;
        print("fullname: \(bla)")
        fullName.text = bla;
    }
    
    private func loadUser() {
        currentUser = backendless.userService.currentUser
    }
    
    @IBAction func logout(sender: AnyObject) {
        backendless.userService.logout()
        goToLogin()
    }
}
