//
//  Delay.swift
//  PecUtils
//
//  Created by Julian Gernun on 3/4/16.
//  Copyright © 2016 uoc. All rights reserved.
//
// Usage:
//
// PecUtils.Delay(callback: {
//  functionToBeExecuted()
// })

import Foundation

public class Delay {

    // a delayed function
    public init(callback: () -> Void, seconds: NSTimeInterval = 5) {
        // use this instead of NSTimer
        self.delay(seconds) {
            print(NSDate())
            // do stuffs
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
