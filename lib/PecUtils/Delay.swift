//
//  Delay.swift
//  PecUtils
//
//  Created by Julian Gernun on 8/5/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import Foundation


import Foundation

public class Delay {
    
    public init(callback: () -> Void, seconds: NSTimeInterval = 5) {
        self.delay(seconds) {
            callback()
        }
    }
    
    private func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
}