//
//  MyPlacesDetailViewController.swift
//  pec-uno
//
//  Created by Julian Gernun on 15/5/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import Foundation
import PecUtils


class MyPlacesDetailViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var detailView: UITextView!
    private let backendless = Backendless.sharedInstance()
    private var chosenPlace: Place?
    private var indicator = PecUtils.Indicator()
    private let regionRadius: CLLocationDistance = 1000
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let annotationsToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
        mapView.removeAnnotations( annotationsToRemove )
        self.loadData()
        
        self.mapView.delegate = self
        self.initMap()
     }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (StaticPlaces.sharedInstance.selected == -1) {
            self.back()
        }
    }
    
    private func centerMapOnLocation(location: CLLocationCoordinate2D) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    private func initMap() {
        let latitude = CLLocationDegrees((chosenPlace?.location?.latitude)!)
        let longitude = CLLocationDegrees((chosenPlace?.location?.longitude)!)
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

        // Drop a pin
        let dropPin = MKPointAnnotation()
        dropPin.coordinate = location
        dropPin.title = chosenPlace?.name
        mapView.addAnnotation(dropPin)
        centerMapOnLocation(location)
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
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        return true;
    }
}

