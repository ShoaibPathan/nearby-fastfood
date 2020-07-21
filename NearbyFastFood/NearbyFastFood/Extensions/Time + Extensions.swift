//
//  Time + Extensions.swift
//  NearbyFastFood
//
//  Created by Priscilla Ip on 2020-07-21.
//  Copyright © 2020 Priscilla Ip. All rights reserved.
//

import Foundation

extension Double {
    func toDisplayString() -> String {
        let totalSeconds = Int(self)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds / 60) % 60
        let seconds = totalSeconds % 60
        if totalSeconds < 3600 {
            return String(format: "%02d:%02d", minutes, seconds)
        } else {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
    }
}
