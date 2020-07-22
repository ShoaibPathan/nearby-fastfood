//
//  LoadingView.swift
//  NearbyFastFood
//
//  Created by Priscilla Ip on 2020-07-22.
//  Copyright © 2020 Priscilla Ip. All rights reserved.
//

import UIKit

class LoadingView: UIView {
    
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .white
        self.addSubview(activityIndicator)
        activityIndicator.center(to: self, xAnchor: true, yAnchor: true)
        activityIndicator.startAnimating()
    }

}
