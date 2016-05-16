//
//  MyPlacesDetailViewController.swift
//  pec-uno
//
//  Created by Julian Gernun on 15/5/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import Foundation
import PecUtils


class MyPlacesDetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var detailView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    private let backendless = Backendless.sharedInstance()
    private var newImageData: NSData?
    private var chosenPlace: Place?
    private var indicator = PecUtils.Indicator()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.loadData()
    }
    
    @IBAction func goBack(sender: AnyObject) {
        self.back()
    }
    
    private func loadData() {
        if (StaticPlaces.sharedInstance.selected == -1) {
            self.back()
            return
        }
        chosenPlace = StaticPlaces.sharedInstance.places![StaticPlaces.sharedInstance.selected]
        nameLabel.text = chosenPlace!.name
        detailView.text = chosenPlace!.detail
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
        imageView.image = image
        newImageData = UIImagePNGRepresentation(image)!
        
        uploadImage()
        
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
//    @IBAction func saveButt(sender: AnyObject) {
//        let imageData = UIImageJPEGRepresentation(imageView.image!, 0.6)
//        let compressedJPGImage = UIImage(data: imageData!)
//        UIImageWriteToSavedPhotosAlbum(compressedJPGImage!, nil, nil, nil)
//        
//        PecUtils.Alert(title: "Success!", message: "Your image has been saved to Photo Library!")
//            .showSimple(self)
//    }
    
    private func back() -> Bool {
        if let navController = self.navigationController {
            dispatch_async(dispatch_get_main_queue()) {
                navController.popViewControllerAnimated(true)
            }
        }
        return true;
    }
    
    private func uploadImage() {
        let timestamp = Int(ceil(NSDate().timeIntervalSince1970 * 1000))
        print(timestamp)
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

