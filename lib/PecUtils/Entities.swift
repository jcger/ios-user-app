//
//  Entities.swift
//  PecUtils
//
//  Created by Julian Gernun on 9/5/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import Foundation

public class Places: NSObject {
    public class var sharedInstance: Places {
        struct Static {
            static var instance: Places?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = Places()
        }
        
        return Static.instance!
    }
    
    public var user: String?
    public var name: String?
    public var detail: String?
    public var longitude: Double = 0.0
    public var latitude: Double = 0.0
}
