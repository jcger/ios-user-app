//
//  Utils.swift
//  PecUtils
//
//  Created by Julian Gernun on 3/4/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import Foundation

public class Alert: UIAlertController  {
    
    public convenience init(title: String?, message: String?) {
        self.init()
        self.init(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
    }

    public func showSimple(viewController: UIViewController) {
        self.modalPresentationStyle = .Popover
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
        self.addAction(OKAction)
        viewController.presentViewController(self, animated: true, completion: nil)
    }
}