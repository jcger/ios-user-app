//
//  MyPlacesEditViewController.swift
//  pec-uno
//
//  Created by Julian Gernun on 22/5/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import Foundation
import PecUtils

class MyPlacesEditViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameError: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var mapView: MKMapView!

    private var currentAnnotation: MKPointAnnotation!
    private var locationManager : CLLocationManager!
    private let MIN_LENGTH = 3
    private var indicator = PecUtils.Indicator()
    private var currentUser: BackendlessUser?
    private var currentLocation: GeoPoint!
    private var chosenPlace: Place?
    private let backendless = Backendless.sharedInstance()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        textView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).CGColor
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 5
        
        mapView.delegate = self
        mapView.mapType = MKMapType.Standard

        self.loadData()
        self.initMap()
    }
    
    private func centerMapOnLocation(location: CLLocationCoordinate2D) {
        let regionRadius: CLLocationDistance = 1000
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
        nameTextField.text = chosenPlace!.name
        textView.text = chosenPlace!.detail
        currentLocation = chosenPlace!.location
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let latitude = view.annotation?.coordinate.latitude
        let longitude = view.annotation?.coordinate.longitude
        
        currentLocation = GeoPoint(point: GEO_POINT(latitude: latitude!, longitude: longitude!))
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKPointAnnotation {
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myPin")
            
            pinAnnotationView.draggable = true
            pinAnnotationView.canShowCallout = true
            pinAnnotationView.animatesDrop = true
            
            return pinAnnotationView
        }
        
        return nil
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    
    /* hides all the error labels */
    private func resetErrorHighlight() {
        nameError.hidden = true
    }
    
    func checkFormErrors() -> Bool {
        var containsError: Bool = false
        self.resetErrorHighlight()
        
        if (nameTextField.text?.characters.count < MIN_LENGTH) {
            containsError = true
            nameError.hidden = false
        }
        return containsError
    }
    
    func update() {
        let errors = self.checkFormErrors()
        if (errors) {
            return
        }
        
        self.indicator.show(view)
        
        let dataStore = Backendless.sharedInstance().data.of(Place.ofClass())
        
        let place = Place()
        place.ownerId = chosenPlace!.ownerId
        place.objectId = chosenPlace!.objectId
        place.name = self.nameTextField.text!
        place.detail = self.textView.text!
        place.location = currentLocation
        
        dataStore.save(
            place,
            response: { (result: AnyObject!) -> Void in
                self.indicator.hide();
                StaticPlaces.sharedInstance.places![StaticPlaces.sharedInstance.selected] = (result as? Place)!
                PecUtils.Alert(title: "Success", message: "Place saved successfully!")
                    .showSimple(self, callback: self.back)
            },
            error: { (fault: Fault!) -> Void in
                self.indicator.hide();
                PecUtils.Alert(title: "Error", message: "Error saving the place.\n\(fault)")
                    .showSimple(self, callback: self.back)
        })
    }
    
    func delete() {
        self.indicator.show(view)
        let dataStore = Backendless.sharedInstance().data.of(Place.ofClass())
        dataStore.remove(
            chosenPlace,
            response: { (result: AnyObject!) -> Void in
                self.indicator.hide();
                StaticPlaces.sharedInstance.places!.removeAtIndex(StaticPlaces.sharedInstance.selected)
                StaticPlaces.sharedInstance.selected = -1
                PecUtils.Alert(title: "Success", message: "Place deleted successfully!")
                    .showSimple(self, callback: self.back)
            },
            error: { (fault: Fault!) -> Void in
                self.indicator.hide();
                PecUtils.Alert(title: "Error", message: "Error deleting the place.\n\(fault)")
                    .showSimple(self, callback: self.back)
        })
    }
    
    @IBAction func onSave(sender: AnyObject) {
        self.update()
    }
    @IBAction func onDelete(sender: AnyObject) {
        self.delete()
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

