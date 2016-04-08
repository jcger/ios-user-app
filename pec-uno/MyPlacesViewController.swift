//
//  MyPlacesViewController.swift
//  pec-uno
//
//  Created by Julian Gernun on 9/4/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import UIKit

class MyPlacesViewController: UIViewController {
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
            revealViewController().rightViewRevealWidth = 150
        }
    }
}

