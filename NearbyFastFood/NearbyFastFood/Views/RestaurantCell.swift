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
    
    ////////!!!!!!!!!//Highlight color: powder blue

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

    private var restaurantInfo: NSMutableAttributedString {
        get {
            let defaultStr = "$$$$ • \(distance)"
            
            // If price is nil, return default
            guard let dollarCount = business.price?.count else { return NSMutableAttributedString(string: defaultStr) }
            
            // Change Price Color
            let mutableStr = NSMutableAttributedString(string: defaultStr)
            let range = NSRange(location: 0, length: dollarCount)
            mutableStr.addAttributes([NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0, green: 0.7411764706, blue: 0.6666666667, alpha: 1)], range: range)
            return mutableStr
        }
    }
    
    var business: Business! {
        didSet {
            restaurantNameLabel.text = business.name
            restaurantInfoLabel.attributedText = restaurantInfo
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
