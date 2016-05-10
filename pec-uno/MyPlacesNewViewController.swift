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
    private let descriptionPlaceholder = "Description"
    private var indicator = PecUtils.Indicator()
    private var currentUser: BackendlessUser?
    private var currentLocation: CLLocation!
    private let pinImageName = "pin"
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        textView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).CGColor
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 5
        
        textView.text = descriptionPlaceholder
        textView.textColor = UIColor.lightGrayColor()
        
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
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = descriptionPlaceholder
            textView.textColor = UIColor.lightGrayColor()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (!locations.isEmpty && abs(locations.last!.timestamp.timeIntervalSinceNow) < 5) {
            currentLocation = locations.last
            
            let center = CLLocationCoordinate2D(latitude: currentLocation!.coordinate.latitude, longitude: currentLocation!.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            self.mapView.setRegion(region, animated: true)
            let annotation = self.createAnnotation(currentLocation!.coordinate.latitude, longitude: currentLocation!.coordinate.longitude, locationName: "Current position")
            mapView.addAnnotation(annotation)
            if (currentAnnotation !== nil) {
                mapView.removeAnnotation(currentAnnotation)
            }
            currentAnnotation = annotation
            self.stopRequestingLocation()
        }
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
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "MyPin"
        
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        }
        
        let detailButton: UIButton = UIButton(type: UIButtonType.DetailDisclosure)
        
        // Reuse the annotation if possible
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            annotationView!.canShowCallout = true
            annotationView!.image = UIImage(named: self.pinImageName)
            annotationView!.rightCalloutAccessoryView = detailButton
        } else {
            annotationView!.annotation = annotation
        }
        
        return annotationView
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
        
        let backendless = Backendless.sharedInstance()
        currentUser = backendless.userService.currentUser

        let place = GeoPoint.geoPoint(
            GEO_POINT(latitude: PecUtils.Places.sharedInstance.latitude, longitude: PecUtils.Places.sharedInstance.longitude),
            categories: [],
            metadata: ["name": nameTextField.text!, "detail": textView.text, "Users":currentUser!]
            ) as! GeoPoint

        self.indicator.show(view);
        backendless.geoService.savePoint(
            place,
            response: { (let point : GeoPoint!) -> () in
                self.indicator.hide();
                PecUtils.Alert(title: "Success", message: "Place saved successfully!")
                    .showSimple(self, callback: self.back)
            },
            error: { (let fault : Fault!) -> () in
                self.indicator.hide();
                PecUtils.Alert(title: "Error", message: "\(fault)")
                    .showSimple(self, callback: self.back)
            }
        )
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

