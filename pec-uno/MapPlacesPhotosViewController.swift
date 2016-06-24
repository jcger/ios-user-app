//
//  MapPlacesPhotos.swift
//  pec-uno
//
//  Created by Julian Gernun on 24/6/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import Foundation
import PecUtils

class MapPlacesPhotosViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    private let backendless = Backendless.sharedInstance()
    private var newImageData: NSData?
    private var chosenPlace: Place?
    private var indicator = PecUtils.Indicator()
    private var images: Array<Image>?
    private var currentImage: Int?
    private var noImage: Bool?
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadData()
    }
    
    private func loadData() {
        if (StaticAllPlaces.sharedInstance.selected == -1) {
            return
        }

        chosenPlace = StaticAllPlaces.sharedInstance.places![StaticAllPlaces.sharedInstance.selected]
        print(chosenPlace)
        nameLabel.text = chosenPlace!.name
        
        currentImage = 0
        fetchImages()
        imageView.userInteractionEnabled = true
    }
    
    private func fetchImages() {
        let dataQuery = BackendlessDataQuery()
        let  queryOptions = QueryOptions()
        queryOptions.relationsDepth = 1
        dataQuery.whereClause = "place = '\(chosenPlace!.objectId!)'"
        dataQuery.queryOptions = queryOptions
        var error: Fault?
        let bc = backendless.data.of(Image.ofClass()).find(dataQuery, fault: &error)
        if error == nil {
            images = (bc.data as? [Image])!
            if (images!.count > 0) {
                noImage = false
                downloadImage(images![currentImage!].image!)
            } else {
                noImage = true
                imageView.image = UIImage(named: "no_image")
                self.indicator.hide();
            }
        } else {
            self.indicator.hide();
            PecUtils.Alert(title: "Error", message: "Error loading places.\n\(error?.description)")
                .showSimple(self)
        }
    }
    
    func downloadImage(fileUrl: String) {
        let this = self
        self.indicator.show(view);
        let imgURL: NSURL = NSURL(string: fileUrl)!
        let request: NSURLRequest = NSURLRequest(URL: imgURL)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request){
            (data, response, error) -> Void in
            
            if (error == nil && data != nil) {
                func display_image() {
                    self.imageView.image = UIImage(data: data!)
                    self.indicator.hide()
                }
                dispatch_async(dispatch_get_main_queue(), display_image)
            }
        }
        task.resume()
        
    }
    
    @IBAction func previous(sender: AnyObject) {
        if (currentImage! > 0) {
            currentImage!--
            downloadImage(images![currentImage!].image!)
        }
    }
    @IBAction func next(sender: AnyObject) {
        if (currentImage! + 1 < images!.count) {
            currentImage!++
            downloadImage(images![currentImage!].image!)
        }
    }
    
    @IBAction func imageTapped(sender: UITapGestureRecognizer) {
        let newImageView = UIImageView(image: imageView.image)
        newImageView.frame = self.view.frame
        newImageView.backgroundColor = .blackColor()
        newImageView.contentMode = .ScaleAspectFit
        newImageView.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: "dismissFullscreenImage:")
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
    }
    
    func dismissFullscreenImage(sender: UITapGestureRecognizer) {
        sender.view?.removeFromSuperview()
    }
}

