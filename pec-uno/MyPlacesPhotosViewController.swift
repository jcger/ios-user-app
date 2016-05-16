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
    @IBOutlet weak var collectionView: UICollectionViewCell!
    
    
    private let backendless = Backendless.sharedInstance()
    private var newImageData: NSData?
    private var chosenPlace: Place?
    private var indicator = PecUtils.Indicator()
    private var currentUser: BackendlessUser?
    private var images: Array<Image>?
    
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
        
        fetchImages()

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
            "\(chosenPlace!.objectId!)\(timestamp).jpg",
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
        self.indicator.show(view);
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
            loadImages()
            self.indicator.hide();
        } else {
            self.indicator.hide();
            PecUtils.Alert(title: "Error", message: "Error loading places.\n\(error?.description)")
                .showSimple(self)
        }
    }
    
    private func loadImages() {
        
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
}

