//
//  ViewController.swift
//  NearbyFastFood
//
//  Created by Priscilla Ip on 2020-07-17.
//  Copyright © 2020 Priscilla Ip. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Map", "List"])
        
        // Style
        sc.backgroundColor = #colorLiteral(red: 0.8784313725, green: 0.8823529412, blue: 0.8862745098, alpha: 1)
        sc.selectedSegmentTintColor = #colorLiteral(red: 0.2509803922, green: 0, blue: 0.5098039216, alpha: 1)
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.1176470588, green: 0.1529411765, blue: 0.1803921569, alpha: 1)], for: UIControl.State.normal)
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.9450980392, green: 0.9058823529, blue: 0.7137254902, alpha: 1)], for: UIControl.State.selected)
        
        sc.selectedSegmentIndex = 0 // UserDefaults Preference
        return sc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        navigationItem.title = "Fast Food Places"
        
        
        //[redView, blueView].forEach { view.addSubview($0) }
        
        view.addSubview(segmentedControl)
        setupLayouts()
    }
    
    private func setupLayouts() {
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24).isActive = true        
        segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 72).isActive = true
        segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -72).isActive = true
    }


}

