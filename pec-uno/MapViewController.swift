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

public class StaticAllPlaces: NSObject {
    public class var sharedInstance: StaticAllPlaces {
        struct Static {
            static var instance: StaticAllPlaces?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = StaticAllPlaces()
        }
        
        return Static.instance!
    }
    public var places: Array<Place>?
    public var selected: Int = -1
    public func addPlace(place: Place) {
        self.places?.append(place)
    }
}

public class Rating: NSObject {
    public var rating: Int = 0
    public var user: String?
    public var place: String?
}

var tableView: UITableView!

class MapViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, MKMapViewDelegate  {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    private var locationManager : CLLocationManager!
    private var currentLocation: CLLocation!
    private let backendless = Backendless.sharedInstance()
    private var indicator = PecUtils.Indicator()
    private var radius: Double = 100
    private var radiusTextField: UITextField?
    private var ratings: [Rating] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.backgroundColor = UIColor.clearColor();
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.rowHeight = 70.0
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
        mapView.showsUserLocation = true
        self.startRequestingLocation()
        StaticAllPlaces.sharedInstance.places = nil
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
            self.loadGeoPointsAsync(self.radius)
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
    
    private func nextPageAsync(points: BackendlessCollection) {
        if points.getCurrentPage().count == 0 {
            return
        }
        
        let geoPoints = points.getCurrentPage() as! [GeoPoint]
        var places: [Place] = []
        for geoPoint in geoPoints {
            let place = geoPoint.metadata["location"] as? Place
            if (place !== nil) {
                places.append(place!)
            }
        }
        StaticAllPlaces.sharedInstance.places = places
        self.indicator.hide()
        
        self.loadRatings()
    }
    
    func loadAnnotations() {
        if (StaticAllPlaces.sharedInstance.places == nil) {
            return
        }
        for place in StaticAllPlaces.sharedInstance.places! {
            let latitude = CLLocationDegrees((place.location?.latitude)!)
            let longitude = CLLocationDegrees((place.location?.longitude)!)
            let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            var userRating: Int = 0
            var nrRating: Int = 0
            
            for rating in self.ratings {
                if (rating.place == place.objectId) {
                    userRating += rating.rating
                    nrRating++
                }
            }
            
            // Drop a pin
            let dropPin = MKPointAnnotation()
            dropPin.coordinate = location
            dropPin.title = "\(place.name!) - Rating: \(String(Int(userRating/nrRating)))"
            mapView.addAnnotation(dropPin)
        }
    }

    func loadGeoPointsAsync(radius:Double) {
        
        StaticAllPlaces.sharedInstance.places = []
        let annotationsToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
        mapView.removeAnnotations( annotationsToRemove )
        
        self.indicator.show(view)
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
    
    func loadRatings() {
        let query = BackendlessDataQuery()
        backendless.persistenceService.of(Rating.ofClass()).find(
            query,
            response: { ( ratings : BackendlessCollection!) -> () in
                self.ratings = ratings.getCurrentPage() as! [Rating]
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                    self.loadAnnotations()
                    self.zoomToFitMapAnnotations()
                })
            },
            error: { ( fault : Fault!) -> () in
                print("Server reported an error: \(fault)")
            }
        )
    }
    
    func zoomToFitMapAnnotations() {
        if StaticAllPlaces.sharedInstance.places == nil {
            return
        }
        var topLeftCoord: CLLocationCoordinate2D = CLLocationCoordinate2D()
        topLeftCoord.latitude = -90
        topLeftCoord.longitude = 180
        var bottomRightCoord: CLLocationCoordinate2D = CLLocationCoordinate2D()
        bottomRightCoord.latitude = 90
        bottomRightCoord.longitude = -180
        for annotation: MKAnnotation in mapView.annotations {
            topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude)
            topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude)
            bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude)
            bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude)
        }
        
        var region: MKCoordinateRegion = MKCoordinateRegion()
        region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5
        region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5
        region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.4
        region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.4
        region = mapView.regionThatFits(region)
        mapView.setRegion(region, animated: true)
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
        if (StaticAllPlaces.sharedInstance.places == nil) {
            return 0
        }
        return StaticAllPlaces.sharedInstance.places!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let nameLabel = UILabel(frame: CGRect(x:15, y:5, width:200, height:35))
        let detailLabel = UILabel(frame: CGRect(x:15, y:35, width:200, height:35))
        detailLabel.text = StaticAllPlaces.sharedInstance.places![indexPath.item].detail
        
        var userRating: Int = 0
        var nrRating: Int = 0
        
        for rating in self.ratings {
            if (rating.place == StaticAllPlaces.sharedInstance.places![indexPath.item].objectId) {
                userRating += rating.rating
                nrRating++
            }
        }
        let name = StaticAllPlaces.sharedInstance.places![indexPath.item].name
        nameLabel.text = "\(name!) - Rating: \(Int(userRating/nrRating))"
        if (detailLabel.text?.characters.count > 25) {
            detailLabel.text = (detailLabel.text! as NSString).substringToIndex(25) + "..."
        }
        cell.addSubview(nameLabel)
        cell.addSubview(detailLabel)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let row = indexPath.row
        StaticAllPlaces.sharedInstance.selected = row
        
        let MyPlacesDetailViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MapPlaceDetailView") as UIViewController
        
        self.navigationController!.pushViewController(MyPlacesDetailViewController, animated: true)
        
    }
    
    @IBAction func onOptionsClick(sender: AnyObject) {
        let alert = UIAlertController(title: "Options", message: "Search radius (km)", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            let radius: String = (self.radiusTextField?.text)!
            
            if (radius != "") {
                self.radius = Double(radius)!
            }
            self.loadGeoPointsAsync(self.radius)
        }))
        
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = String(self.radius)
            self.radiusTextField = textField
        })
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
