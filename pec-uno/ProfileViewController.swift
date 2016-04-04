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
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var email: UILabel!
    
    private var logged = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (self.logged == true) {
            self.loadData()
        }
    }
    
    
    override func viewDidAppear(animated: Bool) {
        if (logged == true) {
            super.viewDidAppear(animated)
        } else {
            self.performSegueWithIdentifier("ProfileLoginSegue", sender: self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func loadData() {
        let imageName = "batman.png"
        let aux = UIImage(named: imageName)
        image = UIImageView(image: aux!)
        self.view.addSubview(image)
    }
    
    @IBAction func logout(sender: AnyObject) {
    }
}
