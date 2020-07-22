//
//  UIViewController + Extensions.swift
//  NearbyFastFood
//
//  Created by Priscilla Ip on 2020-07-22.
//  Copyright © 2020 Priscilla Ip. All rights reserved.
//

import UIKit

var storedLoadingView: UIView?

extension UIViewController {
    
    func showLoadingIndicator(on view: UIView) {
        let loadingView = LoadingView()
        loadingView.frame = view.bounds
        DispatchQueue.main.async {
            view.addSubview(loadingView)
        }
        storedLoadingView = loadingView
    }

    func removeLoadingIndicator() {
        DispatchQueue.main.async {
            storedLoadingView?.removeFromSuperview()
            storedLoadingView = nil
        }
    }

    //MARK: - Child View Controllers
    
    func add(_ child: UIViewController) {
        self.addChild(child)
        self.view.addSubview(child.view)
        child.didMove(toParent: self)
        child.view.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
    }
    
    func remove(_ child: UIViewController) {
        // Check if view controller is added to a parent before removing it
        guard parent != nil else { return }
        
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
}
