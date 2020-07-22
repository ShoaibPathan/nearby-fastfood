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
    
    var previousBusinesses = [Business]()
    var businesses = [Business]() {
        willSet {
            self.previousBusinesses = self.businesses
        }
    }
    private let defaults = UserDefaults.standard
    private let regionChangeThreshold: Double = 200
    private let searchCategories = "burgers,pizza,mexican,chinese"
    private let sortByCriteria = "distance"
    private var previousLocation: CLLocation?
    private var regionIsCenteredOnUserLocation = false
    private var regionChangedBeyondThreshold: Bool {
        get {
            let center = getCenterLocation(for: mapView)
            guard let previousLocation = previousLocation else { return false }
            if center.distance(from: previousLocation) > regionChangeThreshold {
                self.previousLocation = center
                return true
            } else { return false }
        }
    }
    
    var mapViewModel = MapViewModel()
    
    let feedbackGenerator: UIImpactFeedbackGenerator = {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        return generator
    }()
    
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
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                self.mapView.alpha = 1
                self.tableView.alpha = 0
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                self.mapView.alpha = 0
                self.tableView.alpha = 1
            }, completion: nil)
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
    
    override func loadView() {
        super.loadView()
        showLoadingIndicator(on: self.view)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupViews()
        setupTableView()
        loadLastSelectedSegmentIndex()
        setupLocationService()
    }

    //MARK: - Setup
    
    private func setupLocationService() {
        let locationService = LocationService.shared
        locationService.delegate = self
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        navigationItem.title = "Fast Food Places"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
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

// MARK: - Fetch Businesses and Annotations

extension ViewController {
    private func fetchBusinesses(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        APIService.shared.fetchBusinesses(latitude: latitude, longitude: longitude, radius: LocationService.shared.regionInMeters, sortBy: sortByCriteria, categories: searchCategories) { [weak self] (businesses) in
            
            self?.removeLoadingIndicator()
            
            
            
            self?.businesses = businesses
            self?.addAnnotations()
            self?.tableView.reloadData()
        }
    }
    
    private func addAnnotations() {
        let previousAnnotations = mapView.annotations
        businesses.forEach { (business) in
            mapViewModel.createAnnotation(on: self.mapView, business: business)
        }
        self.mapView.removeAnnotations(previousAnnotations)
    }
}

// MARK: - TableView Delegate and Datasource

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let business = self.businesses[indexPath.row]
        let detailsController = DetailsController()
        detailsController.business = business
        navigationController?.pushViewController(detailsController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        businesses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RestaurantCell.reuseIdentifier, for: indexPath) as? RestaurantCell else { fatalError() }
        cell.business = self.businesses[indexPath.row]
        return cell
    }
}

// MARK: - LocationServiceDelegate

extension ViewController: LocationServiceDelegate {
    
    func didCheckAuthorizationStatus(status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            mapView.showsUserLocation = true
            guard let userLocation = LocationService.shared.userLocation else { return }
            centreMap(on: userLocation)
        case .denied, .restricted:
            centreMap(on: LocationService.shared.defaultLocation)
        default: break
        }
    }
    
    func didUpdateLocation(location: CLLocation) {
        // Do not center on user location after the initial update
        if !regionIsCenteredOnUserLocation {
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = createRegion(center: center)
            mapView.setRegion(region, animated: true)
            regionIsCenteredOnUserLocation = true
        }
        regionIsCenteredOnUserLocation = true
    }
    
    func turnOnLocationServices() {
        AlertService.showLocationServicesAlert(on: self)
    }
    
    func didFailWithError(error: Error) {
        print("Failed to update location:", error)
    }
}

//MARK: - MKMapViewDelegate

extension ViewController: MKMapViewDelegate {
    
    private func createRegion(center: CLLocationCoordinate2D) -> MKCoordinateRegion {
        return MKCoordinateRegion(center: center, latitudinalMeters: LocationService.shared.regionInMeters, longitudinalMeters: LocationService.shared.regionInMeters)
    }
    
    private func centreMap(on location: CLLocationCoordinate2D) {
        let region = createRegion(center: location)
        mapView.setRegion(region, animated: true)
        previousLocation = getCenterLocation(for: mapView)
    }
    
    private func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    //MARK: - Delegate Methods
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if #available(iOS 10,*) {
            feedbackGenerator.impactOccurred()
        }
        if view is RestaurantAnnotationView {
            let title = view.annotation?.title
            guard let index = businesses.firstIndex(where: {$0.name == title}) else { return }
            let business = businesses[index]
            
            let detailsController = DetailsController()
            detailsController.business = business
            navigationController?.pushViewController(detailsController, animated: true)
        }
        //        // zoom into cluster
        //        if view is RestaurantClusterView {
        //            guard let annotation = view.annotation else { return }
        //        }
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let lat = mapView.centerCoordinate.latitude
        let lon = mapView.centerCoordinate.longitude
        if regionChangedBeyondThreshold {
            fetchBusinesses(latitude: lat, longitude: lon)
        }
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
