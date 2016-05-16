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

public class Image: NSObject {
    public var image: String?
    public var place: String?
}

public class Place: NSObject {
    public var objectId: String?
    public var name: String?
    public var detail: String?
    public var location: GeoPoint?
}

public class StaticPlaces: NSObject {
    public class var sharedInstance: StaticPlaces {
        struct Static {
            static var instance: StaticPlaces?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = StaticPlaces()
        }
        
        return Static.instance!
    }
    public var places: Array<Place>?
    public var selected: Int = -1
    public func addPlace(place: Place) {
        self.places?.append(place)
    }
}

class MyPlacesViewController: UITableViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    private var currentUser: BackendlessUser?
    private var backendless = Backendless.sharedInstance()
    private var places = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadUserPlaces()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        }
    }
    
    private func loadUserPlaces() {
        if (StaticPlaces.sharedInstance.places == nil) {
            currentUser = backendless.userService.currentUser
            let dataQuery = BackendlessDataQuery()
            let  queryOptions = QueryOptions()
            queryOptions.relationsDepth = 1
            dataQuery.whereClause = "ownerId = '\(currentUser!.objectId)'"
            dataQuery.queryOptions = queryOptions
        
            var error: Fault?
            let bc = backendless.data.of(Place.ofClass()).find(dataQuery, fault: &error)
            if error == nil {
                StaticPlaces.sharedInstance.places = bc.data as? [Place]
            } else {
                PecUtils.Alert(title: "Error", message: "Error loading places.\n\(error?.description)")
                    .showSimple(self)
            }
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StaticPlaces.sharedInstance.places!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->   UITableViewCell {
        let cell = UITableViewCell()
        let nameLabel = UILabel(frame: CGRect(x:15, y:5, width:200, height:35))
        let detailLabel = UILabel(frame: CGRect(x:15, y:35, width:200, height:35))
        let places = StaticPlaces.sharedInstance.places
        nameLabel.text = places![indexPath.item].name
        detailLabel.text = places![indexPath.item].detail
        if (detailLabel.text?.characters.count > 15) {
            detailLabel.text = (detailLabel.text! as NSString).substringToIndex(15) + "..."
        }
        cell.addSubview(nameLabel)
        cell.addSubview(detailLabel)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let row = indexPath.row
        StaticPlaces.sharedInstance.selected = row
        
        let MyPlacesDetailViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MyPlacesDetail") as UIViewController
        
        self.navigationController!.pushViewController(MyPlacesDetailViewController, animated: true)
        
    }
}

