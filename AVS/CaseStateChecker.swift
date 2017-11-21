//
//  CaseStateChecker.swift
//  AVS
//
//  Created by Ray Tso on 4/7/17.
//  Copyright © 2017 Ray Tso. All rights reserved.
//

import Foundation
import Alamofire

class CaseStateChecker {
    
    // MARK: - Properties
    
    private let parser = Parser()
    
    struct CaseDetailResponse {
        var status: String?
        var response: String?
    }
    
    // MARK: - UDFs
    
    func checkCases(cases: [HistoryDataStructure]) -> [HistoryDataStructure]? {
        var batchInfo: [[String: String]] = [[:]]
        for data in cases {
            let caseID = data.caseID
            let serialNumber = data.serialNumber
            guard caseID != nil, serialNumber != nil else { return nil }
            batchInfo.append([caseID! : serialNumber!])
        }
        
        return cases
    }
    
    private func retrieveResponse(batchInfos: [[String : String]]) -> [[String]] {
        
    }
    
    private func connect(url: String) {
        
    }
}
