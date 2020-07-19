//
//  APIService.swift
//  NearbyFastFood
//
//  Created by Priscilla Ip on 2020-07-17.
//  Copyright © 2020 Priscilla Ip. All rights reserved.
//

import Alamofire

struct SearchResults: Codable {
    let total: Int
    let businesses: [Business]
}

public class APIService {
    
    static let shared = APIService()
    
    let baseURL = "https://api.yelp.com/v3/businesses/search"
    let apiKey = "LyUEVmqVePFXd0Vf2iOIpYhjNAh_uqk_T_MzqvgmDpbHHbt6_aVyP6CjsHaCdBdnpholti4sOWTLsbF_DL5wOoEYvkQ7n9Lx7481YZdohGHw_0xSaFQkwaJNVSkRX3Yx"
    let clientID = "Yihufjsobcy6HRR4"
    
    func fetchBusinesses(latitude: Double,
                         longitude: Double,
                         radius: Double,
                         sortBy: String,
                         categories: String,
                         completion: @escaping ([Business]) -> Void) {
        
        let parameters: [String : Any] = [
            "latitude": latitude,
            "longitude": longitude,
            "radius": radius,
            "sort_by": sortBy,
            "categories": categories]
        
        let headers: HTTPHeaders = [.authorization(bearerToken: apiKey)]
        
        AF.request(baseURL, parameters: parameters, headers: headers).validate().responseData { (dataResponse) in
            switch dataResponse.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    
                    let searchResults = try decoder.decode(SearchResults.self, from: data)
                    completion(searchResults.businesses)
                    
                } catch let jsonErr {
                    print("Failed to decode:", jsonErr)
                }
                
                
                
                
                
                
                
                
            case .failure(let error):
                print("Failed to fetch businesses:", error)
            }
        }
        
        

    }
    
    
        
        
        
        
        
        
        
        
//        guard let url = URL(string: baseURL) else { return }
//
//        URLSession.shared.dataTask(with: url) { (data, response, err) in
//            if let err = err {
//                completion(.failure(err))
//                return
//            }
//            if let data = data {
//                do {
//                    let businesses = try JSONDecoder().decode([Business].self, from: data)
//                    completion(.success(businesses))
//                } catch { completion(.failure(error)) }
//            }
//        }.resume()
        
    }





