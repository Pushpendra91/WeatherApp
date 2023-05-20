//
//  LocatioManager.swift
//  Wather
//
//  Created by Pushpendra on 20/05/23.
//

import Foundation
import CoreLocation
import Combine

protocol UserLocationManagerDelegate: AnyObject {
    func getUserLocation(lat: Double, lon: Double)
    func getLocationError(error: String)
}

class UserLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    weak var delegate: UserLocationManagerDelegate?

    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        self.locationManager.delegate = self
    }

    func checkIfLocationServicesIsEnabled(){
            DispatchQueue.global().async {
                if CLLocationManager.locationServicesEnabled(){
                    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest/// kCLLocationAccuracyBest is the default
                    self.checkLocationAuthorization()
                }else{
                    // show message: Services desabled!
                }
            }
        }

    func checkLocationAuthorization() {
            var authorizationStatus: CLAuthorizationStatus?

            if #available(iOS 14.0, *) {
                authorizationStatus = locationManager.authorizationStatus
            } else {
                authorizationStatus = CLLocationManager.authorizationStatus()
            }

            switch authorizationStatus ?? .notDetermined {
            case .authorizedAlways, .authorizedWhenInUse: // If authorized
                locationManager.startUpdatingLocation() // request updating location
            case .denied, .restricted: // if denied we are not able to receive location updates
                delegate?.getLocationError(error: "Authentication denied.")
            case .notDetermined: // if not determined we can request authorization
                locationManager.requestWhenInUseAuthorization() // request authorization
            @unknown default:
                debugPrint("Unknown authorization status")
                delegate?.getLocationError(error: "Location error.")
            }
        }

        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            locationManager.stopUpdatingLocation()
            if let location = locations.last {
                delegate?.getUserLocation(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
                locationManager.stopUpdatingLocation()
            }
        }
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            debugPrint("Location error is \(error.localizedDescription)")
            self.delegate?.getLocationError(error: "Location service is dissabled, please enable it from setting.")
            locationManager.stopUpdatingLocation()
        }

        func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            checkLocationAuthorization()
        }
}
