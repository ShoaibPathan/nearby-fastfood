//
//  RestaurantPointAnnotation.swift
//  NearbyFastFood
//
//  Created by Priscilla Ip on 2020-07-19.
//  Copyright © 2020 Priscilla Ip. All rights reserved.
//

import Foundation
import MapKit

class RestaurantAnnotationView: MKPointAnnotation {
    
    static var reuseIdentifier: String { String(describing: self) }
    static var nib: UINib { UINib(nibName: String(describing: self), bundle: nil) }
    
    var pinTintColor: UIColor?
    
}
