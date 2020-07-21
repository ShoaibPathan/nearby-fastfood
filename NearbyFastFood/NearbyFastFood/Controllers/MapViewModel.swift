//
//  MapViewModel.swift
//  NearbyFastFood
//
//  Created by Priscilla Ip on 2020-07-21.
//  Copyright © 2020 Priscilla Ip. All rights reserved.
//

import MapKit

class MapViewModel: NSObject {
    
    func createAnnotation(business: Business) {
        let annotation = MKPointAnnotation()
        annotation.title = business.name
        if let lat = business.coordinates?.latitude, let lon = business.coordinates?.longitude {
            annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        self.mapView.addAnnotation(annotation)
    }
    
}
