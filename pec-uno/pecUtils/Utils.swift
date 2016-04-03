//
//  main.swift
//  pecUtils
//
//  Created by Julian Gernun on 3/4/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import Foundation

class PecUtils {
    public func showAlert(title: String, msg: String) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
        alertController.addAction(OKAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}