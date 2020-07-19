//
//  ViewController.swift
//  NearbyFastFood
//
//  Created by Priscilla Ip on 2020-07-17.
//  Copyright © 2020 Priscilla Ip. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire

class ViewController: UIViewController {
    
    deinit {
        print("ViewController memory being reclaimed...")
    }
    
    var businesses = [Business]()
    
    private let defaults = UserDefaults.standard
    private let locationManager = CLLocationManager()
    private let initialSpanInMeters: Double = 1000
    
    let segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Map", "List"])
        sc.backgroundColor = #colorLiteral(red: 0.8784313725, green: 0.8823529412, blue: 0.8862745098, alpha: 1)
        sc.selectedSegmentTintColor = #colorLiteral(red: 0.2509803922, green: 0, blue: 0.5098039216, alpha: 1)
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.1176470588, green: 0.1529411765, blue: 0.1803921569, alpha: 1)], for: UIControl.State.normal)
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.9450980392, green: 0.9058823529, blue: 0.7137254902, alpha: 1)], for: UIControl.State.selected)
        sc.selectedSegmentIndex = 0 // UserDefaults Preference
        sc.addTarget(self, action: #selector(handleSegmentChange), for: .valueChanged)
        return sc
    }()
    
    let mapView: MKMapView = {
        let map = MKMapView()
        return map
    }()
    
    let tableView: UITableView = {
        let table = UITableView()
        return table
    }()
    
    @objc func handleSegmentChange() {
        
        if segmentedControl.selectedSegmentIndex == 0 {
            mapView.alpha = 1
            tableView.alpha = 0
        } else {
            mapView.alpha = 0
            tableView.alpha = 1
        }
        
        saveSelectedSegmentIndex(segmentedControl.selectedSegmentIndex)
    }
    
    //MARK: - UserDefaults
    
    private func saveSelectedSegmentIndex(_ index: Int) {
        defaults.set(index, forKey: K.UserDefaults.selectedSegmentIndex)
    }
    
    private func loadLastSelectedSegmentIndex() {
        segmentedControl.selectedSegmentIndex = defaults.integer(forKey: K.UserDefaults.selectedSegmentIndex)
        handleSegmentChange()
    }
    
    //MARK: - Lifecycles

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        setupViews()
        setupTableView()
        
        
        loadLastSelectedSegmentIndex()
        checkLocationServices()
    }
    
    //MARK: - Setup
    
    private func setupViews() {
        view.backgroundColor = .white
        navigationItem.title = "Fast Food Places"
        
        //[redView, blueView].forEach { view.addSubview($0) }
        view.addSubview(segmentedControl)
        view.insertSubview(mapView, belowSubview: segmentedControl)
        view.insertSubview(tableView, belowSubview: mapView)
        setupLayouts()
    }
    
    private func setupLayouts() {
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24).isActive = true        
        segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 72).isActive = true
        segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -72).isActive = true
        
        mapView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        tableView.anchor(top: segmentedControl.bottomAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 24, left: 0, bottom: 0, right: 0))
    }
    
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.register(RestaurantCell.nib, forCellReuseIdentifier: RestaurantCell.reuseIdentifier)
        
        // Separator
        tableView.separatorColor = #colorLiteral(red: 0.8784313725, green: 0.8823529412, blue: 0.8862745098, alpha: 1)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        // + separator height: 2 points
    }
}







// MARK: - TableView Delegate and Datasource

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RestaurantCell.reuseIdentifier, for: indexPath) as? RestaurantCell else { fatalError() }
//        cell.business = self.podcasts[indexPath.row]
        return cell
        
    }
    
    
    

    
    
    
    
}


// MARK: - CLLocationManagerDelegate

extension ViewController: CLLocationManagerDelegate {
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            /// - ALERT: "Turn on Location Services"
            AlertService.showLocationServicesOffAlert(on: self)
        }
    }
    
    private func centerViewOnDefaultLocation() {
        let defaultLocation = CLLocationCoordinate2D(latitude: 40.758896, longitude: -73.985130)
        let region = MKCoordinateRegion.init(center: defaultLocation, latitudinalMeters: initialSpanInMeters, longitudinalMeters: initialSpanInMeters)
        mapView.setRegion(region, animated: true)
    }
    
    private func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: initialSpanInMeters, longitudinalMeters: initialSpanInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    private func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            
            mapView.showsUserLocation = true
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
            
            
            
            
            
            
            
            
            
            guard let location = locationManager.location?.coordinate else { return }
            let lat = location.latitude
            let lon = location.longitude
            
            APIService.shared.fetchBusinesses(latitude: lat, longitude: lon, radius: initialSpanInMeters, sortBy: "distance", categories: "burgers,pizza,mexican,chinese") { (businesses) in
                self.businesses = businesses
                self.tableView.reloadData()
            }
            
            
            
            
            
            
            
            
            
            
            

            
            
        case .notDetermined:
            /// Request permission to use location services
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            /// - ALERT: "Turn on Location Services"
            AlertService.showLocationServicesOffAlert(on: self)
            centerViewOnDefaultLocation()
        @unknown default:
            fatalError("CLAuthorizationStatus is unknown.")
        }
    }

    //MARK: - Delegate Methods
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: initialSpanInMeters, longitudinalMeters: initialSpanInMeters)
        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
}

//MARK: - MKMapViewDelegate

extension ViewController: MKMapViewDelegate {
}
    

