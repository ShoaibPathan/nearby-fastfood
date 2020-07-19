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
    
    deinit { print("ViewController memory being reclaimed...") }
    
    var businesses = [Business]()
    
    private let defaults = UserDefaults.standard
    private let locationManager = CLLocationManager()
    private let initialLocation = CLLocationCoordinate2D(latitude: 40.758896, longitude: -73.985130)
    private var userLocation: CLLocationCoordinate2D {
        get {
            guard let location = locationManager.location?.coordinate else { return initialLocation }
            return location
        }
    }
    private let regionInMeters: Double = 1000
    private let regionChangeThreshold: Double = 200
    private let searchCategories = "burgers,pizza,mexican,chinese"
    private let sortByCriteria = "distance"
    private var previousLocation: CLLocation?
    private var regionIsCenteredOnUserLocation = false
    
    let segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Map", "List"])
        sc.backgroundColor = #colorLiteral(red: 0.8784313725, green: 0.8823529412, blue: 0.8862745098, alpha: 1)
        sc.selectedSegmentTintColor = #colorLiteral(red: 0.2509803922, green: 0, blue: 0.5098039216, alpha: 1)
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.1176470588, green: 0.1529411765, blue: 0.1803921569, alpha: 1)], for: UIControl.State.normal)
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)], for: UIControl.State.selected)
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
        setupMapView()
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
    
    private func setupMapView() {
        mapView.delegate = self
        mapView.pointOfInterestFilter = MKPointOfInterestFilter(excluding: [MKPointOfInterestCategory.restaurant])
        mapView.register(RestaurantAnnotationView.self, forAnnotationViewWithReuseIdentifier: RestaurantAnnotationView.reuseIdentifier)
        mapView.register(RestaurantClusterView.self, forAnnotationViewWithReuseIdentifier: RestaurantClusterView.reuseIdentifier)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(RestaurantCell.nib, forCellReuseIdentifier: RestaurantCell.reuseIdentifier)
        tableView.separatorColor = #colorLiteral(red: 0.8784313725, green: 0.8823529412, blue: 0.8862745098, alpha: 1)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        // + separator height: 2 points
    }
}

















// MARK: - TableView Delegate and Datasource

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        businesses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RestaurantCell.reuseIdentifier, for: indexPath) as? RestaurantCell else { fatalError() }
        cell.business = self.businesses[indexPath.row]
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
    
    private func centreMap(on location: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
    }
    
    private func fetchBusinesses(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        APIService.shared.fetchBusinesses(latitude: latitude, longitude: longitude, radius: regionInMeters, sortBy: sortByCriteria, categories: searchCategories) { [weak self] (businesses) in
            self?.businesses = businesses
            DispatchQueue.main.async {
                self?.addAnnotations()
                self?.tableView.reloadData()
            }
        }
    }
    
    private func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            startTrackingUserLocation()
        case .notDetermined:
            /// Request permission to use location services
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            /// - ALERT: "Turn on Location Services"
            AlertService.showLocationServicesOffAlert(on: self)
            centreMap(on: initialLocation)
            previousLocation = getCenterLocation(for: mapView)
        @unknown default:
            fatalError("CLAuthorizationStatus is unknown.")
        }
    }
    
    private func startTrackingUserLocation() {
        mapView.showsUserLocation = true
        centreMap(on: userLocation)
        locationManager.startUpdatingLocation()
        previousLocation = getCenterLocation(for: mapView)
    }
    
    private func createAnnotation(name: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let annotation = MKPointAnnotation()
        annotation.title = name
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.mapView.addAnnotation(annotation)
    }
    
    private func addAnnotations() {
        removeAnnotations()
        businesses.forEach { (business) in
            if let name = business.name,
                let latitude = business.coordinates?.latitude,
                let longitude = business.coordinates?.longitude {
                createAnnotation(name: name, latitude: latitude, longitude: longitude)
            }
        }
    }
    
    private func removeAnnotations() {
        let annotations = mapView.annotations
        mapView.removeAnnotations(annotations)
    }

    //MARK: - Delegate Methods

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Do not center on user location after the initial update
        if !regionIsCenteredOnUserLocation {
            guard let location = locations.last else { return }
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
            regionIsCenteredOnUserLocation = true
        }
        regionIsCenteredOnUserLocation = true
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager Error:", error.localizedDescription)
    }
    
}

//MARK: - MKMapViewDelegate

extension ViewController: MKMapViewDelegate {
    
    private func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    //MARK: - Delegate Methods
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        // Check if region has changed more than threshold
        let center = getCenterLocation(for: mapView)
        guard let previousLocation = previousLocation else { return }
        guard center.distance(from: previousLocation) > regionChangeThreshold else { return }
        self.previousLocation = center
        
        fetchBusinesses(latitude: latitude, longitude: longitude)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation {
        case is MKUserLocation:
            return nil
        case is MKClusterAnnotation:
            guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: RestaurantClusterView.reuseIdentifier) as? RestaurantClusterView else { fatalError() }
            return annotationView
        default:
            guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: RestaurantAnnotationView.reuseIdentifier) as? RestaurantAnnotationView else { fatalError() }
            return annotationView
        }
    }
    
}


