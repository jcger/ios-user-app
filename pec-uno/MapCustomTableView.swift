//
//  MapCustumTableViewController.swift
//  pec-uno
//
//  Created by Julian Gernun on 18/6/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import Foundation
import UIKit

class MapCustomTableViewController: UITableView, UITableViewDelegate {
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, withEvent: event)
        if (point.y < 0) {
            return nil
        }
        return hitView
    }
    
}