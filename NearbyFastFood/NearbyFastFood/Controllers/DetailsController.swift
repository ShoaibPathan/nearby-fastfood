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
    
    let mapViewModel = MapViewModel()
    var directionsArray: [MKDirections] = []
    
    var business: Business! {
        didSet {
            guard let url = URL(string: business.imageUrl ?? "") else { return }
            restaurantImageView.load(url: url)
            nameLabel.text = business?.name
            mapViewModel.createAnnotation(on: self.mapView, business: self.business)
        }
    }
    var businessLocation: CLLocationCoordinate2D! {
        return mapViewModel.createLocation(business: business)
    }
    var expectedTravelTime: TimeInterval? {
        didSet {
            expectedTravelTimeLabel.text = expectedTravelTime?.toDisplayString()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupNavigationBarButtons()
        setupMapView()
        setupLocationService()
        getDirections()
    }
    
    // MARK: - Subviews
    
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
        button.addTarget(self, action: #selector(handleCall), for: .touchUpInside)
        return button
    }()
    
    @objc func handleCall() {
        guard let number = business.phone else { return }
        guard let url = URL(string: "tel://\(number)"), UIApplication.shared.canOpenURL(url) else { return }
        if #available(iOS 10, *) {
            UIApplication.shared.open(url)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = NSLayoutConstraint.Axis.vertical
        stackView.alignment = UIStackView.Alignment.center
        stackView.spacing = 24
        return stackView
    }()
    
    let expectedTravelTimeLabel: UILabel = {
        let label = InsetsLabel(withInsets: 6, 8, 6, 8)
        label.backgroundColor = #colorLiteral(red: 0.8431372549, green: 0.2196078431, blue: 0.368627451, alpha: 0.85) // 85%
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 12.0)
        label.layer.cornerRadius = label.intrinsicContentSize.height / 2
        return label
    }()
    
    // MARK: - Setup
    
    private func setupLocationService() {
        let locationService = LocationService.shared
        locationService.delegate = self
    }

    private func setupViews() {
        view.backgroundColor = .white
        navigationItem.title = "Details"
        [restaurantImageView, nameLabel, stackView].forEach { view.addSubview($0) }
        [mapView, callButton].forEach { stackView.addArrangedSubview($0) }
        view.insertSubview(expectedTravelTimeLabel, aboveSubview: mapView)
        setupLayouts()
    }
    
    private func setupLayouts() {
        restaurantImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor)
        restaurantImageView.heightAnchor.constraint(equalTo: restaurantImageView.widthAnchor, multiplier: 9/16).isActive = true
        nameLabel.anchor(top: nil, leading: view.leadingAnchor, bottom: restaurantImageView.bottomAnchor, trailing: view.trailingAnchor)
        stackView.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor)
        mapView.anchor(top: restaurantImageView.bottomAnchor, leading: stackView.leadingAnchor, bottom: nil, trailing: stackView.trailingAnchor, padding: .init(top: 16, left: 16, bottom: 0, right: 16))
        callButton.anchor(top: nil, leading: stackView.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: stackView.trailingAnchor, padding: .init(top: 0, left: 16, bottom: 16, right: 16), size: .init(width: 0, height: 48.0))
        
        expectedTravelTimeLabel.anchor(top: mapView.topAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 16, left: 0, bottom: 0, right: 0))
        expectedTravelTimeLabel.center(to: view, xAnchor: true, yAnchor: false)
    }
    
    fileprivate func setupNavigationBarButtons() {
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(handleShareButton))
        ]
    }
    
    @objc func handleShareButton() {
        guard let url = business.url else { return }
        if let urlToShare = URL(string: url) {
            let activityViewController = UIActivityViewController(activityItems: [urlToShare], applicationActivities: nil)
            present(activityViewController, animated: true)
        }
    }
    
    private func setupMapView() {
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.pointOfInterestFilter = MKPointOfInterestFilter(excluding: [MKPointOfInterestCategory.restaurant])
        mapView.register(RestaurantAnnotationView.self, forAnnotationViewWithReuseIdentifier: RestaurantAnnotationView.reuseIdentifier)
    }
    
    //class BusinessUrl: UIActivityItemProvider {
    //    let sharingURL: URL
    //    private var semaphore: DispatchSemaphore
    //    init(url: URL) {
    //        self.sharingURL = url
    //        super.init(placeholderItem: url)
    //    }
    //
    //    override var item: Any {
    //    }
    //}
    
    // MARK: - Directions
    
    func getDirections() {
        let location: CLLocationCoordinate2D
        if let userLocation = LocationService.shared.userLocation {
            location = userLocation
        } else { location = LocationService.shared.defaultLocation }
        
        let request = createDirectionsRequest(from: location)
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions)
        
        directions.calculate { [unowned self] (response, error) in
            if error != nil {
                print("Failed to calculate directions")
            } else {
                guard let response = response else {
                    AlertService.showDirectionsNotAavailableAlert(on: self)
                    return
                }
                for route in response.routes {
                    //let steps = route.steps
                    self.expectedTravelTime = route.expectedTravelTime
                    self.mapView.addOverlay(route.polyline)
                    self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                }
            }
        }
    }
    
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request {
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: businessLocation)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        return request
    }
    
    func resetMapView(withNew directions: MKDirections) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map{ $0.cancel() }
        self.directionsArray = []
    }
}

// MARK: - LocationServiceDelegate

extension DetailsController: LocationServiceDelegate {
    func didCheckAuthorizationStatus(status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            mapView.showsUserLocation = true
            getDirections()
        case .denied, .restricted:
            getDirections()
        default: break
        }
    }
    
    func didUpdateLocation(location: CLLocation) { }
    func turnOnLocationServices() {
        AlertService.showLocationServicesAlert(on: self)
    }
    
    func didFailWithError(error: Error) {
        print("Failed to update location:", error)
    }
}


// MARK: - MKMapViewDelegate

extension DetailsController: MKMapViewDelegate {
    private func centreMap(on location: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: location, latitudinalMeters: LocationService.shared.regionInMeters, longitudinalMeters: LocationService.shared.regionInMeters)
        mapView.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = #colorLiteral(red: 0.05882352941, green: 0.737254902, blue: 0.9764705882, alpha: 1)
        renderer.lineWidth = 4.0
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: RestaurantAnnotationView.reuseIdentifier) as? RestaurantAnnotationView else { fatalError() }
        return annotationView
    }
}
