//
//  RestaurantCell.swift
//  NearbyFastFood
//
//  Created by Priscilla Ip on 2020-07-18.
//  Copyright © 2020 Priscilla Ip. All rights reserved.
//

import UIKit

enum RestaurantCategory: String {
    case burgers, pizza, mexican, chinese
    
    var restaurantIcon: UIImage {
        switch self {
        case .burgers:
            return UIImage(named: "burger") ?? UIImage()
        case .pizza:
            return UIImage(named: "pizza") ?? UIImage()
        case .mexican:
            return UIImage(named: "burrito") ?? UIImage()
        case .chinese:
            return UIImage(named: "chopsticks") ?? UIImage()
        }
    }
}





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
    
    
    
    
    
    
    let burgers: Set = ["burgers"]
    let pizza: Set = ["pizza"]
    let mexican: Set = ["mexican", "easternmexican", "jaliscan", "northernmexican", "oaxacan", "pueblan", "tacos", "tamales", "yucatan"]
    let chinese: Set = ["chinese", "cantonese", "congee", "dimsum", "fuzhou", "hainan", "hakka", "henghwa", "hokkien", "hunan", "pekinese", "shanghainese", "szechuan", "teochew"]

    
    
    private func checkRestaurantCategory() -> RestaurantCategory? {
        
        let restaurantCategory: RestaurantCategory

        guard let categories = business.categories else { return nil }
        
        var aliasArray: [String] = []
        categories.forEach { (category) in
            aliasArray.append(category.alias ?? "")
        }
        
        if aliasArray.contains(where: {burgers.contains($0)}) {
            restaurantCategory = .burgers
        } else if aliasArray.contains(where: {pizza.contains($0)}) {
            restaurantCategory = .pizza
        } else if aliasArray.contains(where: {mexican.contains($0)}) {
            restaurantCategory = .mexican
        } else if aliasArray.contains(where: {chinese.contains($0)}) {
            restaurantCategory = .chinese
        } else { return nil }
        
        return restaurantCategory
    }
    
    
    
    private var icon: UIImage {
        get {
            guard let restaurantCategory = checkRestaurantCategory() else { return UIImage() }
            return restaurantCategory.restaurantIcon
        }
    }
    
    
    
    
    
    var business: Business! {
        didSet {
            restaurantIcon.image = icon
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
