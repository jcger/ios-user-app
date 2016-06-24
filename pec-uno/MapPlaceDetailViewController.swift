//
//  MapPlaceDetail.swift
//  pec-uno
//
//  Created by Julian Gernun on 20/6/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import Foundation
import PecUtils


class MapPlaceDetailViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var ratingTextField: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var detailView: UITextView!
    private let backendless = Backendless.sharedInstance()
    private var chosenPlace: Place?
    private var indicator = PecUtils.Indicator()
    private var placeRating:Int = 0
    private let regionRadius: CLLocationDistance = 1000
    private var currentUser: BackendlessUser?
    private var userRatings: [Rating] = []
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let annotationsToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
        mapView.removeAnnotations( annotationsToRemove )
        self.loadData()
        
        self.mapView.delegate = self
        currentUser = backendless.userService.currentUser
        self.initMap()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (StaticAllPlaces.sharedInstance.selected == -1) {
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
        let name = chosenPlace?.name
        dropPin.coordinate = location
        dropPin.title = "\(name!) - Rating:\(self.placeRating)"
        mapView.addAnnotation(dropPin)
        centerMapOnLocation(location)
    }
    
    private func loadData() {
        if (StaticAllPlaces.sharedInstance.selected == -1) {
            self.back()
            return
        }

        chosenPlace = StaticAllPlaces.sharedInstance.places![StaticAllPlaces.sharedInstance.selected]
        nameLabel.text = chosenPlace!.name
        detailView.text = chosenPlace!.detail
        
        loadRating()
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
    
    private func loadRating() {
        let id = chosenPlace!.objectId!
        let whereClause = "place = '\(id)'"
        let dataQuery = BackendlessDataQuery()
        dataQuery.whereClause = whereClause
        
        self.indicator.show(view)
        var error: Fault?
        let bc = backendless.data.of(Rating.ofClass()).find(dataQuery, fault: &error)
        if error == nil {
            self.indicator.hide()

            var rating: Int = 0

            self.userRatings = bc.data as! [Rating]
            for rate in self.userRatings {
                rating += rate.rating
            }
            self.placeRating = Int(rating/bc.data.count)
            if (bc.data.count > 0) {
                nameLabel.text = "\(chosenPlace!.name!) (\(self.placeRating)/5)"
            } else {
                nameLabel.text = "\(chosenPlace!.name!)"
            }
        } else {
            self.indicator.hide()
            PecUtils.Alert(title: "Error", message: "Error retrieving place rating.")
                .showSimple(self)
            print("Error! \(error)")
        }
    }
    
    private func updateRate(rating: Rating) {
        rating.rating = Int(ratingTextField.text!)!
        
        self.indicator.show(view)
        let dataStore = backendless.data.of(Rating.ofClass())
        dataStore.save(
            rating,
            response: { (result: AnyObject!) -> Void in
                self.indicator.hide()
                self.loadRating()
                PecUtils.Alert(title: "Success", message: "Place successfully rated!")
                    .showSimple(self)
            },
            error: { (fault: Fault!) -> Void in
                self.indicator.hide()
                PecUtils.Alert(title: "Error", message: "Error saving the place.\n\(fault)")
                    .showSimple(self)
        })

    }
    
    @IBAction func rate(sender: AnyObject) {
        if (chosenPlace!.ownerId == currentUser?.objectId) {
            PecUtils.Alert(title: "Error", message: "You can't vote for your own places!")
                .showSimple(self)
            return
        }
        
        for rating in self.userRatings {
            if (rating.user == currentUser!.objectId) {
                self.updateRate(rating)
                return
            }
        }
        let rate = Rating()
        rate.user = currentUser!.objectId
        rate.place = chosenPlace!.objectId
        rate.rating = Int(ratingTextField.text!)!
        
        self.indicator.show(view)
        let dataStore = backendless.data.of(Rating.ofClass())
        
        // save object asynchronously
        dataStore.save(
            rate,
            response: { (result: AnyObject!) -> Void in
                PecUtils.Alert(title: "Success", message: "Place successfully rated!")
                    .showSimple(self)
                self.loadRating()
                self.indicator.hide()
            },
            error: { (fault: Fault!) -> Void in
                PecUtils.Alert(title: "Error", message: "Error retrieving place rating.")
                    .showSimple(self)
                self.indicator.hide()
                print("Server reported an error: \(fault)")
        })
    }
}

