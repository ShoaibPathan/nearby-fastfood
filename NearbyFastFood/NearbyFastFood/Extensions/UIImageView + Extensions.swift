//
//  UIImageView + Extensions.swift
//  NearbyFastFood
//
//  Created by Priscilla Ip on 2020-07-20.
//  Copyright © 2020 Priscilla Ip. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
