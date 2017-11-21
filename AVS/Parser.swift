//
//  Parser.swift
//  NoMoreParking
//
//  Created by Ray Tso on 3/19/17.
//  Copyright © 2017 Ray Tso. All rights reserved.
//

import Foundation
import Kanna

class Parser {
    
    private var parsingType: SupportedDataTypes?
    
    private func parse(html: String) -> [String : String]? {
        self.parsingType = .HTML
        if let doc = Kanna.HTML(html: html, encoding: .utf8) {
            if let body = doc.body {
                if let table = body.at_xpath("//p[@class=\"word_title01\"]") {
                    let nodes = table.parent?.xpath("p")
                    if let message = nodes?[1].text {
                        return parseMessageString(message: message)
                    }
                }
            }
        }
        return nil
    }
    
    private func parseMessageString(message: String) -> [String : String]? {
        var dict: [String : String]? = [:]
        var newText: String? {
            didSet {
                if let text = newText?.components(separatedBy: ["（", "）"])[1].components(separatedBy: " ") {
                    dict?[ResponseDictKeys.CaseID] = text[1]
                    dict?[ResponseDictKeys.SerialNumaber] = text[3]
                }
            }
        }
        newText = message
        return dict!.isEmpty ? nil : dict!
    }
    
    private func parse(json: [String : Any]) -> [String : String]? {
        guard json["supported"] != nil else { self.parsingType = nil; return nil }
        self.parsingType = .JSON
        
        let supported = json["supported"] as! [String: Any]
        if let cities = supported["city"] as? [[String: String]] {
            for dict in cities {
                let name = dict[JSONKey.Name]
                let purl = dict[JSONKey.Post]
                let surl = dict[JSONKey.Search]
                let urlData = ViolationURLs.init(postURL: purl!, searchURL: surl)
                AppData.supportedCities[name!] = urlData
            }
        }
        // for now
        return nil
    }
    
    func parse(data: Any, dataType: SupportedDataTypes) -> [String : String]? {
        var result: [String : String]?
        switch dataType {
        case .HTML:
            result = parse(html: data as! String)
        case .JSON:
            result = parse(json: data as! [String: Any])
        }
        return result
    }
    
    enum SupportedDataTypes {
        case HTML
        case JSON
    }
    
    struct JSONKey {
        static let Name = "name"
        static let Post = "postURL"
        static let Search = "searchURL"
    }
}

struct ResponseDictKeys {
    static let CaseID = "caseID"
    static let SerialNumaber = "serialNumber"
}

struct ViolationURLs {
    var postURL: String
    var searchURL: String?
}


