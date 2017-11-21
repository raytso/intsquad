//
//  HistoryViewModel.swift
//  NoMoreParking
//
//  Created by Ray Tso on 3/23/17.
//  Copyright © 2017 Ray Tso. All rights reserved.
//


import UIKit
import CoreData

class HistoryViewModel {
    
    // MARK: - Proerties
    
    private var dataArray: [HistoryDataStructure]? = []
    
    private let context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // MARK: - UDFs
    
    init() {
        dataArray = fetchCoreData()
    }
    
    func addSingleData(file: CaseStructure) {
        let newData = HistoryDataStructure(context: context)
        newData.carplateNumber = file.carplateNumber
        newData.caseID = file.caseID
        newData.serialNumber = file.serialNumber
        newData.state = file.state
        newData.caseType = file.caseType
        let timeText = file.capturedDate.timeStamp! + " +0800"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        let newDate = formatter.date(from: timeText)
        newData.capturedDate = newDate as NSDate!
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    func deleteData(target: HistoryDataStructure) {
        context.delete(target)
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    func fetchCoreData() -> [HistoryDataStructure]? {
        do {
            dataArray = try context.fetch(HistoryDataStructure.fetchRequest())
            return dataArray?.reversed()
        } catch {
            debugPrint(error)
            return nil
        }
    }
}

struct NotificationConstants {
    static let NewData = Notification.Name("NewDataUploaded")
}

enum CaseStatus: Int {
    case Pending = 0
    case Accepted = 1
    case Failed = 2
    case Closed = 3
}

struct CaseStatusConstants {
    static let Pending = "審核中"
    static let Accepted = "已受理"
    static let Failed = "未受理"
    static let Closed = "已結案"
}
