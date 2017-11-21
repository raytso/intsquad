//
//  UserInfoClass.swift
//  NoMoreParking
//
//  Created by Ray Tso on 3/10/17.
//  Copyright © 2017 Ray Tso. All rights reserved.
//

import Foundation

class UserInformation {
    var name: String?
    var address: String?
    var phone: String?
    var email: String?
    
    init() {
        self.name = DefaultUserInfo.Name
        self.address = DefaultUserInfo.Address
        self.phone = DefaultUserInfo.Phone
        self.email = DefaultUserInfo.Email
    }
    
    init(name: String?, address: String?, phone: String?, email: String?) {
        self.name = name ?? DefaultUserInfo.Name
        self.address = address ?? DefaultUserInfo.Address
        self.phone = phone ?? DefaultUserInfo.Phone
        self.email = email ?? DefaultUserInfo.Email
    }
    
    private struct DefaultUserInfo {
        static let Name = "臺北市政府警察局"
        static let Address = "臺北市中正區延平南路96號"
        static let Phone = "(02)2331-3561"
        static let Email = "theavsapp@gmail.com"
    }
}
