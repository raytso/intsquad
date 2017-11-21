//
//  Form.swift
//  NoMoreParking
//
//  Created by Ray Tso on 12/28/16.
//  Copyright © 2016 Ray Tso. All rights reserved.
//

import Foundation

protocol ViolationFormMetadataDataSource: class {
    func filesToUploadForViolationForm(sender: ViolationForm) -> [UploadFile]?
}

struct Captcha {
    static var value: String = "jabcx"
}

class ViolationForm {
    private var address: Address?
    private var time: Time?
    private var inputCarPlateNumber: String?
    private var userInfo: UserInformation?
    weak var dataSource: ViolationFormMetadataDataSource?
    private var files: [UploadFile]?
    private var violationType: ViolationOptions.Options
    private var carPlateNumber: [String]? {
        return inputCarPlateNumber?.components(separatedBy: "-")
    }
    
    // MARK: - Userinfo parameters

    private var privacyType: Privacy
    
    init(desiredPrivacy: Privacy, carPlate: String, violationTime: Time, violationAddress: Address, violationType: ViolationOptions.Options) {
        switch desiredPrivacy {
        case .Public:
            self.privacyType = .Public
        case .Mixed:
            self.privacyType = .Mixed
        default:
            self.privacyType = .Default
            self.userInfo = UserInformation()
        }
        self.inputCarPlateNumber = carPlate
        self.time = violationTime
        self.address = violationAddress
        self.violationType = violationType
    }
    
    
    func createSubmitForm() -> PostPackage? {
        var postData = Data()
        let contentType = "multipart/form-data; charset=UTF-8; boundary=" + Boundary.const
        var contentDistributionString: String?
        var contentTypeString: String?
        var valueString: String?
        let parameterNames = FormConstants.FormParametersNames.AllParameters
        
        for parameter in parameterNames {
            contentDistributionString = getContentDispostitionString(name: parameter)
            valueString = getValueString(name: parameter)
            guard contentDistributionString != nil && valueString != nil else { return nil }
            postData.append(stringToDataConversionUsingUTF8(input: Boundary.start))
            postData.append(stringToDataConversionUsingUTF8(input: contentDistributionString!))
            postData.append(stringToDataConversionUsingUTF8(input: valueString!))
        }
        
        // Adding image data
        var index = 0
        files = dataSource?.filesToUploadForViolationForm(sender: self)
        for file in files! {
            // file
            contentDistributionString = getContentDispostitionStringForFilename(index: index, filename: file.fileName!)
            contentTypeString = getContentTypeString(fileType: file.fileType!)
            postData.append(stringToDataConversionUsingUTF8(input: Boundary.start))
            postData.append(stringToDataConversionUsingUTF8(input: contentDistributionString!))
            postData.append(stringToDataConversionUsingUTF8(input: contentTypeString!))
            postData.append(file.content!)
            postData.append(stringToDataConversionUsingUTF8(input: FormConstants.EndLine))
            
            // description
            contentDistributionString = getContentDispostitionStringForDescription(index: index)
            valueString = file.fileName! + FormConstants.EndLine
            postData.append(stringToDataConversionUsingUTF8(input: Boundary.start))
            postData.append(stringToDataConversionUsingUTF8(input: contentDistributionString!))
            postData.append(stringToDataConversionUsingUTF8(input: valueString!))
            
            // increment
            index += 1
        }
        
        // Ghost filename
        contentDistributionString = getContentDispostitionStringForFilename(index: index, filename: "")
        contentTypeString = getContentTypeString(fileType: .GhostFile)
        postData.append(stringToDataConversionUsingUTF8(input: Boundary.start))
        postData.append(stringToDataConversionUsingUTF8(input: contentTypeString!))
        postData.append(stringToDataConversionUsingUTF8(input: FormConstants.EndLine))
        
        // Ending form
        contentDistributionString = getContentDispostitionString(name: .ConfirmSubmit)
        valueString = getValueString(name: .ConfirmSubmit)
        postData.append(stringToDataConversionUsingUTF8(input: Boundary.start))
        postData.append(stringToDataConversionUsingUTF8(input: contentDistributionString!))
        postData.append(stringToDataConversionUsingUTF8(input: valueString!))
        
        // End
        postData.append(stringToDataConversionUsingUTF8(input: Boundary.end))

        return PostPackage(body: postData, contentType: contentType)
    }
    
    struct Boundary {
        static let const = "----ParkingViolationFormBoundaryRT17TwTpePolFrmSbmt"
        static let start = "------ParkingViolationFormBoundaryRT17TwTpePolFrmSbmt\r\n"
        static let end   = "------ParkingViolationFormBoundaryRT17TwTpePolFrmSbmt--\r\n"
    }
    
    struct FormConstants {
        static let ContentDisposition = "Content-Disposition: form-data; name="
        static let ContentType = "Content-Type: "
        static let DoubleEndLine = "\r\n\r\n"
        static let EndLine = "\r\n"
        
        enum FormParametersNames: String {
            case rdoCarnum = "rdoCarnum"
            case PlateNumber1 = "carnum1"
            case PlateNumber2 = "carnum2"
            case PlateNumberFull = "traffic_info_carnum"
            case ViolationDate = "traffic_info_date"
            case ViolationTime = "traffic_info_time"
            case ViolationTimeHour = "time_hour"
            case ViolationTimeMin = "time_min"
            case LocationCity = "city"
            case LocationDistrict = "traffic_info_unit"
            case LocationStreet = "street"
            case LocationStreet2 = "stree2"
            case LocationFull = "traffic_info_location"
            case ViolationType = "violation"
            case ViolationTypeContent = "traffic_info_content"
            case SMSBool = "issms"
            case UserName = "username"
            case UserAddress = "address_1"
            case UserPhone = "phone_1"
            case UserEmail = "email"
            case Captcha = "captcha"
            case ConfirmSubmit = "postFlag"
            static let AllParameters = [rdoCarnum,
                                        PlateNumber1,
                                        PlateNumber2,
                                        PlateNumberFull,
                                        ViolationDate,
                                        ViolationTime,
                                        ViolationTimeHour,
                                        ViolationTimeMin,
                                        LocationCity,
                                        LocationDistrict,
                                        LocationStreet,
                                        LocationStreet2,
                                        LocationFull,
                                        ViolationType,
                                        ViolationTypeContent,
                                        SMSBool,
                                        UserName,
                                        UserAddress,
                                        UserPhone,
                                        UserEmail,
                                        Captcha]
        }
    }
    
    private func getContentDispostitionString(name: FormConstants.FormParametersNames) -> String? {
        return FormConstants.ContentDisposition + "\"\(name.rawValue)\"" + FormConstants.DoubleEndLine
    }
    
    private func getContentDispostitionStringForFilename(index: Int, filename: String) -> String {
        return FormConstants.ContentDisposition + "\"FileName[\(index)]\";" + "filename=\"\(filename)\"" + FormConstants.EndLine
    }
    
    private func getContentTypeString(fileType: UploadFileTypes) -> String {
        return FormConstants.ContentType + fileType.rawValue + FormConstants.DoubleEndLine
    }
    
    private func getContentDispostitionStringForDescription(index: Int) -> String {
        return FormConstants.ContentDisposition +  "\"descript[\(index)]\"" + FormConstants.DoubleEndLine
    }
    
    private func stringToDataConversionUsingUTF8(input: String) -> Data {
        return input.data(using: .utf8, allowLossyConversion: false)!
    }
    
    func getValueString(name: FormConstants.FormParametersNames) -> String? {
        var valueString: String?
        switch name {
        case .rdoCarnum:
            valueString = "0"
        case .PlateNumber1:
            valueString = carPlateNumber?[0]
        case .PlateNumber2:
            valueString = carPlateNumber?[1]
        case .PlateNumberFull:
            valueString = inputCarPlateNumber!
        case .ViolationDate:
            valueString = time?.getFullDate()
        case .ViolationTime:
            valueString = time?.getFullTime()
        case .ViolationTimeHour:
            valueString = time?.hour
        case .ViolationTimeMin:
            valueString = time?.minute
        case .LocationCity:
            valueString = "0"
        case .LocationDistrict:
            valueString = address?.districtNumber
        case .LocationStreet:
            valueString = "0"
        case .LocationStreet2:
            valueString = address?.details ?? " "
        case .LocationFull:
            valueString = address?.getFullAddress()
        case .ViolationType:
            valueString = violationType.rawValue
        case .ViolationTypeContent:
            valueString = violationType.rawValue
        case .SMSBool:
            valueString = "0"
        case .UserName:
            valueString = userInfo?.name
        case .UserEmail:
            valueString = userInfo?.email
        case .UserPhone:
            valueString = userInfo?.phone
        case .UserAddress:
            valueString = userInfo?.address
        case .ConfirmSubmit:
            valueString = "1"
        case .Captcha:
            valueString = "\(Captcha.value)"
        }
        guard valueString != nil else { return nil }
        return valueString
    }
}

struct UploadFile {
    var fileType: UploadFileTypes?
    var fileName: String?
    var content: Data?
}

enum UploadFileTypes: String {
    case Image = "image/jpeg"
    case Video = "video"
    case GhostFile = "application/octet-stream"
}

struct PostPackage {
    var body: Data
    var contentType: String
}

enum Privacy {
    case Default
    case Public
    case Mixed
}
