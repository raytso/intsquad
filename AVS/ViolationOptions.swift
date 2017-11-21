//
//  ViolationOptions.swift
//  NoMoreParking
//
//  Created by Ray Tso on 3/8/17.
//  Copyright © 2017 Ray Tso. All rights reserved.
//

import Foundation

class ViolationOptions: NSObject {
    
    private var currentSelectedOption: Options?
    
    enum Options: String {
        case TempParking = "違規臨時停車"
        case NoParking = "違規停車"
        case BlockingWaitingBlock = "紅燈時佔用機車停等區"
        case OverStopLine = "紅燈越線"
    }
    
    func selectOption(option: Options) {
        currentSelectedOption = option
    }
    
    func getCurrentSelectedOption() -> Options {
        return currentSelectedOption ?? .TempParking
    }
}
