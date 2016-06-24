//
//  InformationViewController.swift
//  pec-uno
//
//  Created by Julian Gernun on 9/4/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import UIKit
import PecUtils

class InformationViewController: UIViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var nrUsers: UILabel!
    @IBOutlet weak var nrPlaces: UILabel!
    private let backendless = Backendless.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        }
        
        loadNrUsers()
        loadNrPlaces()
    }
    
    func loadNrUsers() {
        let dataStore = self.backendless.persistenceService.of(BackendlessUser.ofClass())
        dataStore.find(
            { (let users : BackendlessCollection!) -> () in
                self.nrUsers.text = String(users.data.count)
            },
            error: { (let fault : Fault!) -> () in
                PecUtils.Alert(title: "Error", message: "Error retrieving nr of users.")
                    .showSimple(self)
            }
        )
        
    }
    
    
    func loadNrPlaces() {
        let dataStore = self.backendless.persistenceService.of(Place.ofClass())
        dataStore.find(
            { (let places : BackendlessCollection!) -> () in
                self.nrPlaces.text = String(places.data.count)
            },
            error: { (let fault : Fault!) -> () in
                print(fault)
                PecUtils.Alert(title: "Error", message: "Error retrieving nr of places.")
                    .showSimple(self)
            }
        )
    }
}
