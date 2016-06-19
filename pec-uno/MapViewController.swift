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

var tableView: UITableView!

class MapViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, MKMapViewDelegate  {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    private var locationManager : CLLocationManager!
    private var currentLocation: CLLocation!
    private let backendless = Backendless.sharedInstance()
    private var indicator = PecUtils.Indicator()
    private var DEFAULT_RADIUS_KM: Double = 100
    private var places: [Place] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.backgroundColor = UIColor.clearColor();
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        }
        
        mapView.delegate = self
        mapView.mapType = MKMapType.Standard
        self.startRequestingLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let latitude = view.annotation?.coordinate.latitude
        let longitude = view.annotation?.coordinate.longitude
        
        self.currentLocation = CLLocation(latitude: latitude!, longitude: longitude!)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (!locations.isEmpty && abs(locations.last!.timestamp.timeIntervalSinceNow) < 5) {
            currentLocation = locations.last
            
            let center = CLLocationCoordinate2D(latitude: currentLocation!.coordinate.latitude, longitude: currentLocation!.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            self.mapView.setRegion(region, animated: true)
            self.stopRequestingLocation()
            loadGeoPointsAsync(self.DEFAULT_RADIUS_KM)
        }
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
    
    private func nextPageAsync(points: BackendlessCollection) {
        if points.getCurrentPage().count == 0 {
            return
        }
        
        let geoPoints = points.getCurrentPage() as! [GeoPoint]
        for geoPoint in geoPoints {
            let place = geoPoint.metadata["location"] as! Place
            self.places.append(place)
        }
        
        points.nextPageAsync(
            { (let rest : BackendlessCollection!) -> () in
                self.nextPageAsync(rest)
            },
            error: { (let fault : Fault!) -> () in
                print("Server reported an error: \(fault)")
            }
        )
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
        })
    }

    func loadGeoPointsAsync(radius:Double) {
        
        let query = BackendlessGeoQuery.queryWithPoint(
            GEO_POINT(latitude: currentLocation!.coordinate.latitude, longitude: currentLocation!.coordinate.longitude),
            radius: radius, units: KILOMETERS,
            categories: ["location"]
            ) as! BackendlessGeoQuery
        query.includeMeta = true
        
        backendless.geoService.getPoints(
            query,
            response: { (let points : BackendlessCollection!) -> () in
                self.indicator.hide();
                self.nextPageAsync(points)
            },
            error: { (let fault : Fault!) -> () in
                self.indicator.hide();
                PecUtils.Alert(title: "Error", message: "Error retrieving the places.")
                    .showSimple(self)
                print("Error! \(fault)")
            }
        )
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.contentInset = UIEdgeInsetsMake(self.mapView.frame.size.height-40, 0, 0, 0);
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.contentOffset.y < self.mapView.frame.size.height * -1 ) {
            scrollView .setContentOffset(CGPointMake(scrollView.contentOffset.x, self.mapView.frame.size.height * -1), animated: true)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.places.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell? = self.tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell?
        
        cell?.textLabel?.text = self.places[indexPath.row].name
        
        return cell!
    }
}
