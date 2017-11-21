
//  FormRequestSessionWithAlamofire.swift
//  NoMoreParking
//
//  Created by Ray Tso on 3/16/17.
//  Copyright © 2017 Ray Tso. All rights reserved.
//

import Foundation
import Alamofire

protocol FRSAlamofireDelegate: class {
    func postedResponseSuccess(response: String)
    func postedResponseFail(error: Error)
}

class FormRequestSessionWithAlamofire {

    let parameterNames = ViolationForm.FormConstants.FormParametersNames.AllParameters
    let customHeaders = ["Origin" : "https://www.tcpd.gov.tw",
                         "Accept-Encoding" : "gzip, deflate, br",
                         "Accept-Language" : "en-US,en;q=0.8,zh-TW;q=0.6,zh;q=0.4,ja;q=0.2,zh-CN;q=0.2",
                         "Upgrade-Insecure-Requests" : "1",
                         "User-Agent" : "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.75 Safari/537.36",
                         "Accept" : "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
                         "Cache-Control" : "max-age=0",
                         "Referer" : "https://www.tcpd.gov.tw/tcpd/cht/index.php?act=traffic&code=add"]
    weak var delegate: FRSAlamofireDelegate?
    var formStruct: ViolationForm?
    var files: [UploadFile]?
    
    init(formData: ViolationForm, files: [UploadFile]) {
        self.formStruct = formData
        self.files = files
    }
    
    func postViolationFormData(postUrl: String) {
        
        let manager = Alamofire.SessionManager()
        
        manager.delegate.sessionDidReceiveChallenge = { session, challenge in
            var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
            var credential: URLCredential?
            
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                disposition = URLSession.AuthChallengeDisposition.useCredential
                credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            } else {
                if challenge.previousFailureCount > 0 {
                    disposition = .cancelAuthenticationChallenge
                } else {
                    credential = manager.session.configuration.urlCredentialStorage?.defaultCredential(for: challenge.protectionSpace)
                    
                    if credential != nil {
                        disposition = .useCredential
                    }
                }
            }
            
            return (disposition, credential)
        }
        
        manager.upload(multipartFormData: { (formData) in
            for parameter in self.parameterNames {
                let value = self.formStruct?.getValueString(name: parameter)!
                let key = parameter.rawValue
                formData.append(value!.data(using: .utf8, allowLossyConversion: false)!, withName: key)
            }
            
            for file in self.files!.enumerated() {
                let index = file.offset
                formData.append(_: file.element.content!,
                                   withName: "FileName[\(index)]",
                    fileName: "image\(index).jpg",
                    mimeType: UploadFileTypes.Image.rawValue)
                formData.append("image\(index).jpg".data(using: .utf8, allowLossyConversion: false)!, withName: "descript[\(index)]")
            }
            
            formData.append(self.formStruct!.getValueString(name: .ConfirmSubmit)!.data(using: .utf8, allowLossyConversion: false)!, withName: ViolationForm.FormConstants.FormParametersNames.ConfirmSubmit.rawValue)
        }, to: postUrl, headers: customHeaders) { (sentResult) in
            switch sentResult {
            case .failure(let encodedError):
                self.delegate?.postedResponseFail(error: encodedError)
            case .success(request: let upload, streamingFromDisk: _, streamFileURL: _):
                upload.responseString(completionHandler: { (response) in
                    switch response.result {
                    case .failure(let error):
                        self.delegate?.postedResponseFail(error: error)
                    case .success(let value):
                        self.delegate?.postedResponseSuccess(response: value)
                    }
                })
            }
        }
    }
}







