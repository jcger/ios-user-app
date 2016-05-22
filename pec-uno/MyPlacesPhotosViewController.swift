//
//  MyPlacesPhotosViewController.swift
//  pec-uno
//
//  Created by Julian Gernun on 16/5/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import Foundation
import PecUtils

class MyPlacesPhotosViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    private let backendless = Backendless.sharedInstance()
    private var newImageData: NSData?
    private var chosenPlace: Place?
    private var indicator = PecUtils.Indicator()
    private var currentUser: BackendlessUser?
    private var images: Array<Image>?
    private var currentImage: Int?
    private var noImage: Bool?
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.loadData()
    }
    
    private func loadData() {
        if (StaticPlaces.sharedInstance.selected == -1) {
            return
        }
        chosenPlace = StaticPlaces.sharedInstance.places![StaticPlaces.sharedInstance.selected]
        nameLabel.text = chosenPlace!.name
        
        currentImage = 0
        fetchImages()
        imageView.userInteractionEnabled = true
    }
    
    private func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
            imagePicker.allowsEditing = false
            self.presentViewController(imagePicker, animated: true, completion: nil)
        } else {
            PecUtils.Alert(title: "Error", message: "Camera is not available")
                .showSimple(self)
        }
    }
    
    private func openGallery() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
            imagePicker.allowsEditing = true
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        newImageData = UIImagePNGRepresentation(image)!
        
        uploadImage()
        
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    private func uploadImage() {
        let timestamp = Int(ceil(NSDate().timeIntervalSince1970 * 1000))
        self.indicator.show(view);
        backendless.fileService.upload(
            "\(chosenPlace!.objectId!)\(timestamp).png",
            content: newImageData,
            overwrite:true,
            response: { ( uploadedFile : BackendlessFile!) -> () in
                self.uploadRelation(uploadedFile)
            },
            error: { ( fault : Fault!) -> () in
                self.indicator.hide();
                PecUtils.Alert(title: "Error!", message: "Error uploading your image")
                    .showSimple(self)
        })
    }
    
    private func fetchImages() {
        currentUser = backendless.userService.currentUser
        let dataQuery = BackendlessDataQuery()
        let  queryOptions = QueryOptions()
        queryOptions.relationsDepth = 1
        dataQuery.whereClause = "ownerId = '\(currentUser!.objectId)' and place = '\(chosenPlace!.objectId!)'"
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

    private func uploadRelation(file: BackendlessFile!) {
        let imageRelation = Image()
        imageRelation.image = file.fileURL
        imageRelation.place = chosenPlace?.objectId
        
        let dataStore = backendless.data.of(Image.ofClass())
        
        dataStore.save(
            imageRelation,
            response: { (result: AnyObject!) -> Void in
                self.indicator.hide();
                self.images?.append(imageRelation)
                self.fetchImages()
                PecUtils.Alert(title: "Success!", message: "Your image has been uploaded successfully!")
                    .showSimple(self)
            },
            error: { (fault: Fault!) -> Void in
                self.indicator.hide();
                PecUtils.Alert(title: "Error!", message: "Error uploading your image")
                    .showSimple(self)
        })
    }
    
    @IBAction func upload(sender: AnyObject) {
        self.openGallery()
    }
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
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
    
    func remove(newPosition: Int) {

        let dataStore = backendless.data.of(Image.ofClass())
        
        let image = images![self.currentImage!];
        
        dataStore.save(
            image,
            response: { (result: AnyObject!) -> Void in
                let savedImage = result as! Image
                
                // now delete the saved object
                dataStore.remove(
                    savedImage,
                    response: { (result: AnyObject!) -> Void in
                        self.images!.removeAtIndex(self.currentImage!)
                        self.currentImage = newPosition
                        self.fetchImages()
                    },
                    error: { (fault: Fault!) -> Void in
                        print("Server reported an error (2): \(fault)")
                })
                
            },
            error: { (fault: Fault!) -> Void in
                print("Server reported an error (1): \(fault)")
        })
    }
    
    @IBAction func onDelete(sender: AnyObject) {
        let count = images!.count
        if (count > 0) {
            var newPosition = currentImage!
            if (self.currentImage == count - 1) {
                newPosition--
            }
            self.remove(newPosition)
        }
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

