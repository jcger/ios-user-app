//
//  MyPlacesDetailViewController.swift
//  pec-uno
//
//  Created by Julian Gernun on 15/5/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import Foundation
import PecUtils


class MyPlacesDetailViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var detailView: UITextView!
    private let backendless = Backendless.sharedInstance()
    private var chosenPlace: Place?
    private var indicator = PecUtils.Indicator()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.loadData()
    }
    
    private func loadData() {
        if (StaticPlaces.sharedInstance.selected == -1) {
            self.back()
            return
        }
        chosenPlace = StaticPlaces.sharedInstance.places![StaticPlaces.sharedInstance.selected]
        nameLabel.text = chosenPlace!.name
        detailView.text = chosenPlace!.detail
    }
    
    
    private func back() -> Bool {
        if let navController = self.navigationController {
            dispatch_async(dispatch_get_main_queue()) {
                navController.popViewControllerAnimated(true)
            }
        }
        return true;
    }
}

