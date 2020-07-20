//
//  DetailsController.swift
//  NearbyFastFood
//
//  Created by Priscilla Ip on 2020-07-19.
//  Copyright © 2020 Priscilla Ip. All rights reserved.
//

import UIKit
import MapKit

class DetailsController: UIViewController {
    
    deinit { print("DetailsController memory being reclaimed...") }
    
    var business: Business! {
        didSet {
            guard let url = URL(string: business.imageUrl ?? "") else { return }
            restaurantImageView.load(url: url)
            nameLabel.text = business?.name
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupNavigationBarButtons()
    }
    
    let restaurantImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = #colorLiteral(red: 0.8784313725, green: 0.8823529412, blue: 0.8862745098, alpha: 1)
        imageView.clipsToBounds = true
        return imageView
    }()

    let nameLabel: UILabel = {
        let label = InsetsLabel(withInsets: 12, 16, 12, 16)
        label.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.85) // 85% black
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.init(descriptor: .preferredFontDescriptor(withTextStyle: .title3), size: 0)
        return label
    }()
    
    let mapView: MKMapView = {
        let map = MKMapView()
        map.layer.cornerRadius = 12.0
        return map
    }()
    
    let callButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 6.0
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Call Business", for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.2509803922, green: 0, blue: 0.5098039216, alpha: 1)
        return button
    }()
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = NSLayoutConstraint.Axis.vertical
        stackView.alignment = UIStackView.Alignment.center
        stackView.spacing = 24
        return stackView
    }()

    private func setupViews() {
        view.backgroundColor = .white
        navigationItem.title = "Details"
        [mapView, callButton].forEach { stackView.addArrangedSubview($0) }
        [restaurantImageView, nameLabel, stackView].forEach { view.addSubview($0) }
        setupLayouts()
    }
    
    private func setupLayouts() {
        restaurantImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: stackView.topAnchor, trailing: view.trailingAnchor)
        restaurantImageView.heightAnchor.constraint(equalTo: restaurantImageView.widthAnchor, multiplier: 9/16).isActive = true
        nameLabel.anchor(top: nil, leading: view.leadingAnchor, bottom: restaurantImageView.bottomAnchor, trailing: view.trailingAnchor)
        stackView.anchor(top: restaurantImageView.bottomAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
        mapView.anchor(top: stackView.topAnchor, leading: stackView.leadingAnchor, bottom: nil, trailing: stackView.trailingAnchor, padding: .init(top: 16, left: 16, bottom: 0, right: 16))
        callButton.anchor(top: nil, leading: stackView.leadingAnchor, bottom: stackView.bottomAnchor, trailing: stackView.trailingAnchor, padding: .init(top: 0, left: 16, bottom: 16, right: 16), size: .init(width: 0, height: 48.0))
    }
    


//Map style:
//Directions line color and width: blu cepheus, 4 points
//Map should show driving directions from user’s location to place location using MapKit API
    

    //Share button style:
//Image name: “share”
//Should open default iOS Share sheet with business’s Yelp page URL


    
    
    
    
    
    
    
    
    fileprivate func setupNavigationBarButtons() {
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(handleShareButton))
        ]
    }
    
    @objc func handleShareButton() {
        print("Share!")
    }
    
    
    
    
}
