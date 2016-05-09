//
//  MyPlacesNew.swift
//  pec-uno
//
//  Created by Julian Gernun on 8/5/16.
//  Copyright © 2016 uoc. All rights reserved.
//

class MyPlacesNewViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    var descriptionPlaceholder = "Description"
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        textView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).CGColor
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 5
        
        textView.text = descriptionPlaceholder
        textView.textColor = UIColor.lightGrayColor()
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
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
        textView.resignFirstResponder()
            return false
        }
        return true
    }
}

