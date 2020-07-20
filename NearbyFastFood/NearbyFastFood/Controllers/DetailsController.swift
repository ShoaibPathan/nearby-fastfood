//
//  DetailsController.swift
//  NearbyFastFood
//
//  Created by Priscilla Ip on 2020-07-19.
//  Copyright © 2020 Priscilla Ip. All rights reserved.
//

import UIKit

class DetailsController: UIViewController {
    
    deinit { print("DetailsController memory being reclaimed...") }
    
    var business: Business?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupNavigationBarButtons()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        navigationItem.title = "Details"
    }
    
    fileprivate func setupNavigationBarButtons() {
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.down"), style: .plain, target: self, action: #selector(handleShareButton))
        ]
    }
    
    @objc func handleShareButton() {
        print("Share!")
    }
    
}
