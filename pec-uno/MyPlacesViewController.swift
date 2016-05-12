//
//  MyPlacesViewController.swift
//  pec-uno
//
//  Created by Julian Gernun on 9/4/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import UIKit
import MapKit
import PecUtils

class MyPlacesViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: MyPlacesTableViewController!
    private var currentUser: BackendlessUser?
    private var backendless = Backendless.sharedInstance()
    var locationManager : CLLocationManager!
    var currentAnnotation: MKPointAnnotation!
    var currentLocation: CLLocation!
    var pinImageName = "pin"
    var items: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.backgroundColor = UIColor.clearColor();
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        self.loadUser()
        self.startRequestingLocation()
        self.fetchingPlaces()
        
        mapView.delegate = self
        //mapView.showsUserLocation = true
        mapView.mapType = MKMapType.Standard
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.contentInset = UIEdgeInsetsMake(self.mapView.frame.size.height - 40, 0, 0, 0);
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.contentOffset.y < self.mapView.frame.size.height * -1 ) {
            scrollView .setContentOffset(CGPointMake(scrollView.contentOffset.x, self.mapView.frame.size.height * -1), animated: true)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell? = self.tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell?
        
        cell?.textLabel?.text = self.items[indexPath.row]
        
        return cell!
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
            PecUtils.Places.sharedInstance.latitude = currentLocation!.coordinate.latitude
            PecUtils.Places.sharedInstance.longitude = currentLocation!.coordinate.longitude
            self.stopRequestingLocation()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
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
    
    private func initCells() {

    }
    
    func fetchingPlaces() {
        print(currentUser)
    }
    
    private func loadUser() {
        currentUser = backendless.userService.currentUser
    }
    
}

