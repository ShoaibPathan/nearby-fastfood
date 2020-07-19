//
//  Business.swift
//  NearbyFastFood
//
//  Created by Priscilla Ip on 2020-07-17.
//  Copyright © 2020 Priscilla Ip. All rights reserved.
//

import Foundation

struct Business: Codable, Identifiable {
    let id: String?
    let name: String?
    let distance: Double?
    let imageUrl: String?
    let categories: [Categories]?
}

struct Categories: Codable {
    let alias: String?
    let title: String?
}
    
    
    
//    private enum CodingKeys: String, CodingKey {
//        case imageURL = "image_url"
//        case id, name, distance
//    }
    
