//
//  RestaurantPointAnnotation.swift
//  NearbyFastFood
//
//  Created by Priscilla Ip on 2020-07-19.
//  Copyright © 2020 Priscilla Ip. All rights reserved.
//

import Foundation
import MapKit

class RestaurantAnnotationView: MKAnnotationView {
    
    static var reuseIdentifier: String { String(describing: self) }
    static var nib: UINib { UINib(nibName: String(describing: self), bundle: nil) }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        centerOffset = CGPoint(x: 0, y: -frame.size.height / 2)
        canShowCallout = false
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupView() {
        
        backgroundColor = .yellow
        
        // Resize image
        let pinImage = UIImage(named: "pin")
        let size = CGSize(width: 30, height: 30)
        UIGraphicsBeginImageContext(size)
        pinImage!.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        image = resizedImage
        
        
    }
    
    
}
