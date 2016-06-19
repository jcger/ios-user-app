//
//  MyPlacesNew.swift
//  pec-uno
//
//  Created by Julian Gernun on 8/5/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import PecUtils

class MyPlacesNewViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameError: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    
    private var currentAnnotation: MKPointAnnotation!
    private var locationManager : CLLocationManager!
    private let MIN_LENGTH = 3
    private var indicator = PecUtils.Indicator()
    private var currentUser: BackendlessUser?
    private var currentLocation: CLLocation!
    private let backendless = Backendless.sharedInstance()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        textView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).CGColor
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 5
        
        mapView.delegate = self
        mapView.mapType = MKMapType.Standard
        self.startRequestingLocation()
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (!locations.isEmpty && abs(locations.last!.timestamp.timeIntervalSinceNow) < 5) {
            currentLocation = locations.last
            
            let center = CLLocationCoordinate2D(latitude: currentLocation!.coordinate.latitude, longitude: currentLocation!.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            self.mapView.setRegion(region, animated: true)
            let annotation = self.createAnnotation(currentLocation!.coordinate.latitude, longitude: currentLocation!.coordinate.longitude, locationName: "Position")
            mapView.addAnnotation(annotation)
            if (currentAnnotation !== nil) {
                mapView.removeAnnotation(currentAnnotation)
            }
            currentAnnotation = annotation
            self.stopRequestingLocation()
        }
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let latitude = view.annotation?.coordinate.latitude
        let longitude = view.annotation?.coordinate.longitude
        
        self.currentLocation = CLLocation(latitude: latitude!, longitude: longitude!)
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
    
    private func startRequestingLocation() {
        if (self.locationManager == nil) {
            self.locationManager = CLLocationManager()
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.requestWhenInUseAuthorization()
        }
        
        self.locationManager.startUpdatingLocation()
    }
    
    private func stopRequestingLocation() {
        self.locationManager.stopUpdatingLocation()
    }
    
    //Return CLLocation Coordinate
    private func getLocationObject(latitude:Double, longitude:Double) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )
    }
    
    private func createAnnotation(latitude:Double, longitude:Double, locationName:String) -> MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.coordinate = self.getLocationObject(latitude, longitude: longitude)
        annotation.title = locationName
        return annotation
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
    
    @IBAction func uploadPlace(sender: AnyObject) {
        let errors = self.checkFormErrors()
        if (errors) {
            return
        }
        
        let place = Place()
        place.name = self.nameTextField.text!
        place.detail = self.textView.text!
        
        place.location = GeoPoint.geoPoint(
            GEO_POINT(latitude: currentLocation!.coordinate.latitude, longitude: currentLocation!.coordinate.longitude),
            categories: ["location"],
            metadata: ["location": place]
            ) as? GeoPoint
        
        backendless.geoService.savePoint(
            place.location,
            response: { (let point : GeoPoint!) -> () in
                self.indicator.hide();
                PecUtils.Alert(title: "Success", message: "Place saved successfully!")
                    .showSimple(self, callback: self.back)
            },
            error: { (let fault : Fault!) -> () in
                self.indicator.hide();
                PecUtils.Alert(title: "Error", message: "Error saving the place.\n\(fault)")
                    .showSimple(self, callback: self.back)
            }
        )
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

