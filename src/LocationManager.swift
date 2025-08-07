//
//  LocationManager.swift
//  RedDoor
//
//  Created by Quinn Liu on 1/1/25.
//

import Foundation
import CoreLocation

struct Location {
    let title: String
    let coordinates: CLLocationCoordinate2D
}

class LocationManager: NSObject {
    static let shared = LocationManager()
    
    let locationManager = CLLocationManager()
    
    public func findLocations(query: String, completion: @escaping(([Location]) -> Void)) {
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(query) { places, error in
            guard let places = places, error == nil else {
                completion([])
                return
            }
        }
    }
}
