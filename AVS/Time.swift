//
//  Time.swift
//  NoMoreParking
//
//  Created by Ray Tso on 1/6/17.
//  Copyright © 2017 Ray Tso. All rights reserved.
//

import Foundation
import ImageIO

class Time {
    
    // MARK: - Properties
    
    var hour: String?
    
    var minute: String?
    
    var year: String?
    
    var month: String?
    
    var day: String?
    
    var timeStamp: String? {
        didSet {
            guard (timeStamp != nil) else { return }
            let array = timeStamp!.components(separatedBy: " ")
            // array[0] is date,  [1] is time
            retrievedDateString = array[0]
            let newDateFormat = getFullDate()
            retrievedTimeString = array[1]
            timeStamp = newDateFormat! + " " + retrievedTimeString!
        }
    }
    
    private var retrievedDateString: String? {
        didSet {
            let components = retrievedDateString!.components(separatedBy: ":")
            self.year = components[0]
            self.month = components[1]
            self.day = components[2]
        }
    }
    private var retrievedTimeString: String? {
        didSet {
            let components = retrievedTimeString!.components(separatedBy: ":")
            self.hour = components[0]
            self.minute = components[1]
        }
    }
    
    // MARK: = UDFs
    
    func getFullTime() -> String? {
        guard (hour != nil && minute != nil) else { return nil }
        let fullTime = "\(hour!)" + ":" + "\(minute!)"
        return fullTime // 23:08
    }
    
    func getFullDate() -> String? {
        guard (year != nil && month != nil && day != nil) else { return nil }
        let fullDate = "\(year!)" + "-" + "\(month!)" + "-" + "\(day!)"
        return fullDate // 2017-01-02
    }
    
    func getAttributedTime() -> String? {
        guard (hour != nil && minute != nil) else { return nil }
        var period: String
        var hourInt = Int(hour!)!
        
        if hourInt < 12 {
            period = "上午 "
        } else {
            period = "下午 "
            hourInt = hourInt - 12
        }
        let timeText = "\(hourInt)" + " : " + "\(minute!)"
        return period + timeText
    }
    
    func getAttributedDate() -> String? {
        guard (year != nil && month != nil && day != nil) else { return nil }
        return "\(year!)" + " 年 " + "\(month!)" + " 月 " + "\(day!)" + " 日 "
    }
    
    private func retriveTimeDataValueFromImageDataSource(dataSourceToRetrieve: Data?) {
        guard dataSourceToRetrieve != nil else { return }
        let cgData = CGImageSourceCreateWithData(dataSourceToRetrieve as! CFData, nil)
        guard cgData != nil else { return }
        if let imgProperties = CGImageSourceCopyPropertiesAtIndex(cgData!, 0, nil) as? Dictionary<String, AnyObject> {
            let exif = imgProperties["{Exif}"] as? Dictionary<String, AnyObject>
            timeStamp = exif?["DateTimeOriginal"] as? String
        }
    }
    
    // MARK: - Initializaiton
    
    init(data: Data?) {
        retriveTimeDataValueFromImageDataSource(dataSourceToRetrieve: data)
    }
    
    
}


