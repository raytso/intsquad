//
//  GPS.swift
//  NoMoreParking
//
//  Created by Ray Tso on 2/6/17.
//  Copyright © 2017 Ray Tso. All rights reserved.
//

import Foundation
import CoreLocation

class GPSManager: NSObject, CLLocationManagerDelegate
{
    private var locationManager = CLLocationManager()
    
    private var signalStrengthThreshold: GPSSignalStrength
    
    var isGPSRunning: Bool = false
    
    var signalStrength: GPSSignalStrength? {
        guard myLocation != nil else { return nil }
        if myLocation!.horizontalAccuracy.binade > 200.0 { return GPSSignalStrength.Low }
        else if myLocation!.horizontalAccuracy > 80.0 { return GPSSignalStrength.Moderate }
        else { return GPSSignalStrength.Strong }
    }

    private var myLocation: CLLocation?
    
    var currentGPSLocation: CLLocation? {
        get { return myLocation }
    }
    
    init(desiredSignalStrength: GPSSignalStrength) {
        self.signalStrengthThreshold = desiredSignalStrength
    }
    
    func startGPS() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        isGPSRunning = true
    }
    
    func stopGPS() {
        locationManager.stopUpdatingLocation()
        isGPSRunning = false
    }
    
    // MARK: - CLLocationManager Delegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let latestLocation = locations[locations.count - 1]
        myLocation = latestLocation
    }
}

enum GPSSignalStrength {
    case Low
    case Moderate
    case Strong
}
