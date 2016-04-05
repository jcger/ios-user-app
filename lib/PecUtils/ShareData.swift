//
//  SharedData.swift
//  PecUtils
//
//  Created by Julian Gernun on 5/4/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import Foundation


public class ShareData {
    public class var sharedInstance: ShareData {
        struct Static {
            static var instance: ShareData?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = ShareData()
        }
        
        return Static.instance!
    }
    
    public var email: String!
    
    public var object : AnyObject! //Some Object
    
}