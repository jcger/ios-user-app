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
    
    var shareData = ShareData.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (self.isLoggedIn()) {
            print("IsLogged!")
            self.loadData()
        }
    }

    override func viewDidAppear(animated: Bool) {
//        if (self.isLoggedIn()) {
//            print("IsLogged!")
//            super.viewDidAppear(animated)
//            self.loadData()
//        } else {
//            print("Isnt logged")
//        }
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
        return self.shareData.object != nil
    }
    
    private func loadData() {
        print("lal")
        self.email.text = self.shareData.email
//        self.fullName.text = String(self.shareData.object.fullname)
        self.username.text = String(self.shareData.object.username)
    }
    
    @IBAction func logout(sender: AnyObject) {
        self.shareData.object = nil
        goToLogin()
    }
}
