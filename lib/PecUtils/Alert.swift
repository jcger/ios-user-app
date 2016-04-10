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

    public func showSimple(viewController: UIViewController, callback: (() -> Bool)?) {
        self.modalPresentationStyle = .Popover
        let OKAction = UIAlertAction(title: "OK", style: .Default) {
            (action) -> Void in
                callback?()
        }
        self.addAction(OKAction)
        viewController.presentViewController(self, animated: true, completion: nil)
    }
    
    public func showSimple(viewController: UIViewController) {
        self.showSimple(viewController, callback: nil);
    }
}