//
//  IndicatorController.swift
//  PecUtils
//
//  Created by Julian Gernun on 3/4/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import Foundation
import UIKit

public class Indicator : UIActivityIndicatorView  {

    public convenience init() {
        self.init(frame: CGRectMake(0, 0, 50, 50))
        
        self.autoresizingMask = [
            .FlexibleBottomMargin,
            .FlexibleLeftMargin,
            .FlexibleWidth,
            .FlexibleRightMargin,
            .FlexibleTopMargin,
            .FlexibleHeight,
            .FlexibleBottomMargin
        ]
        self.hidesWhenStopped = true
        self.activityIndicatorViewStyle = .WhiteLarge
        self.color = UIColor.blackColor()
    }
    
    public func show(view: UIView!) {
        self.center = view.center
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        self.startAnimating()
        view.addSubview(self)
    }
    
    public func hide() {
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        self.stopAnimating()
        self.removeFromSuperview()
    }

}