//
//  Address.swift
//  NoMoreParking
//
//  Created by Ray Tso on 12/28/16.
//  Copyright © 2016 Ray Tso. All rights reserved.
//

import Foundation
import CoreLocation

protocol AddressClassDatasource: class {
    func locationDataForAddressClass(sender: Address) -> CLLocation?
}

protocol AddressClassDelegate: class {
    func geocodeRecieved(succeeded: Bool)
}

class Address {
    
    // MARK: - Properties
    
    private let taipeiCityDistrictDictionary: [String : String] = [ "100" : "中正區",
                                                                    "103" : "大同區",
                                                                    "104" : "中山區",
                                                                    "105" : "松山區",
                                                                    "106" : "大安區", 
                                                                    "108" : "萬華區", 
                                                                    "110" : "信義區", 
                                                                    "111" : "士林區", 
                                                                    "112" : "北投區", 
                                                                    "114" : "內湖區", 
                                                                    "115" : "南港區", 
                                                                    "116" : "文山區",]
    var city: String? {
        return (placemark?.subAdministrativeArea == nil) ? nil : placemark!.subAdministrativeArea!
    }
    
    var districtName: String? {
        guard districtNumber != nil else { return nil}
        return taipeiCityDistrictDictionary[districtNumber!] ?? placemark?.locality
    }
    
    var districtNumber: String? {
        return (placemark?.postalCode == nil) ? nil : placemark!.postalCode!
    }
    
    var street: String? {
        return (placemark?.thoroughfare == nil) ? nil : placemark!.thoroughfare!
    }
    
    var details: String? {
        return (placemark?.subThoroughfare == nil) ? nil : placemark!.subThoroughfare! + "號"
    }
    
    private var isRequesting: Bool = false
    
    private var placemark: CLPlacemark?
    
    private var location: CLLocation? {
        didSet {
            reverseGeoLocation(latestLocation: location)
        }
    }
    
    weak var dataSource: AddressClassDatasource?
    
    weak var delegate: AddressClassDelegate?
    
    // MARK: - UDFs
    
    func getFullAddress() -> String? {
        guard (districtNumber != nil),
              (city != nil),
              (districtName != nil) else { return nil }
        let street = self.street ?? ""
        let details = self.details ?? ""
        return "\(districtNumber!)" + "\(city!)" + "\(districtName!)" + "\(street)" + "\(details)"
    }
    
    func getAnnotationCalloutText() -> String? {
        guard placemark != nil else { return nil }
        guard (city != nil), (districtName != nil) else { return nil }
        let street = self.street ?? ""
        let details = self.details ?? ""
        let text = "\(city!) \(districtName!)" + "\n" + "\(street)\(details)"
        return text
    }
    
    func getShortAddress() -> String? {
        guard (city != nil), (districtName != nil) else { return nil }
        let street = self.street ?? ""
        let details = self.details ?? ""
        return "\(city!)\(districtName!)\(street)\(details)"
    }
    
    func requestGeocoder() {
        self.location = dataSource?.locationDataForAddressClass(sender: self)
    }
    
    private func reverseGeoLocation(latestLocation: CLLocation?) {
        guard !isRequesting else { return }
        CLGeocoder().reverseGeocodeLocation(latestLocation!, completionHandler: { (placemarks, error) -> Void in
            if error != nil {
                self.delegate?.geocodeRecieved(succeeded: false)
                return
            }
            if (placemarks?.count)! > 0 {
                self.placemark = placemarks![0]
                self.delegate?.geocodeRecieved(succeeded: true)
            } else {
                self.delegate?.geocodeRecieved(succeeded: false)
            }
            self.isRequesting = false
        })
        isRequesting = true
    }
}
