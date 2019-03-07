//
//  Coordinate.swift
//  Weather Today
//
//  Created by Sebastián  Lara on 5/8/17.
//  Copyright © 2017 Sebastián  Lara. All rights reserved.
//

import Foundation
import CoreLocation

struct Coordinate {
    var latitude: Double
    var longitude: Double
    
    static var sharedInstance = Coordinate(latitude: 0.0, longitude: 0.0)
    static let locationManager = CLLocationManager()
    
    typealias CheckLocationPermissionsCompletionHandler = (Bool) -> Void
    static func checkForGrantedLocationPermissions(completionHandler completion: @escaping CheckLocationPermissionsCompletionHandler) {
        let locationPermissionsStatusGranted = CLLocationManager.authorizationStatus() == .authorizedWhenInUse
        
        if locationPermissionsStatusGranted {
            if let currentLocation = locationManager.location {
                Coordinate.sharedInstance.latitude = currentLocation.coordinate.latitude
                Coordinate.sharedInstance.longitude = currentLocation.coordinate.longitude
            }
        }
        
        completion(locationPermissionsStatusGranted)
    }
}
