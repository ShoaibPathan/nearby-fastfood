//
//  LoadingView.swift
//  NearbyFastFood
//
//  Created by Priscilla Ip on 2020-07-22.
//  Copyright © 2020 Priscilla Ip. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {
    
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        view.addSubview(activityIndicator)
        activityIndicator.center(in: view, xAnchor: true, yAnchor: true)
        activityIndicator.startAnimating()
    }

}
