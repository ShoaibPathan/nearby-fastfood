//
//  RestaurantCell.swift
//  NearbyFastFood
//
//  Created by Priscilla Ip on 2020-07-18.
//  Copyright © 2020 Priscilla Ip. All rights reserved.
//

import UIKit

class RestaurantCell: UITableViewCell {
    
    static var reuseIdentifier: String { String(describing: self) }
    static var nib: UINib { UINib(nibName: String(describing: self), bundle: nil) }
    
    
    @IBOutlet weak var restaurantIcon: UIImageView!
    @IBOutlet weak var restaurantNameLabel: UILabel!
    @IBOutlet weak var restaurantInfoLabel: UILabel!
    
    //Highlight color: powder blue
    //Info dollar color: pickle green
    
//    var dateFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "MMM dd, yyyy"
//        return formatter
//    }()
    
    private var measurementFormatter: MeasurementFormatter = {
        let formatter = MeasurementFormatter()
        formatter.numberFormatter.maximumFractionDigits = 2
        formatter.unitStyle = .long
        return formatter
    }()
    
    private var distance: String {
        get {
            var distanceInMeters = Measurement(value: business.distance ?? 0, unit: UnitLength.meters)
            distanceInMeters.convert(to: .miles)
            return measurementFormatter.string(from: distanceInMeters)
        }
    }
    
    var business: Business! {
        didSet {
            
            restaurantNameLabel.text = business.name
            
            
            
            
            
            
            
            
            
            
            restaurantInfoLabel.text = "$$$$ • \(distance)"
            
            
            
        }
    }
    
    
    
    
    
    
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
