//
//  HistoryDataTableViewController.swift
//  NoMoreParking
//
//  Created by Ray Tso on 3/23/17.
//  Copyright © 2017 Ray Tso. All rights reserved.
//

import UIKit

struct CaseStructure {
    var caseID: String
    var serialNumber: String
    var carplateNumber: String
    var state: Int16
    var caseType: String
    var capturedDate: Time
}

class HistoryDataTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    var model: HistoryViewModel?
    
    private var historyDatas: [HistoryDataStructure]?
    
    private var historyTableViewCell: HistoryViewTableViewCell?
    
    struct ReuseIdentifiers {
        static let Default = "HistoryDataDefaultIdentifier"
    }
    
    // MARK: - UDFs
    
    func pullToRefresh() {
        historyDatas = model?.fetchCoreData()
        tableView.reloadData()
    }
    
    // MARK: - Application Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // remove empty cells
        self.tableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        pullToRefresh()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            if let array = historyDatas {
                if array.count == 0 {
                    let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0,
                                                                     y: 0,
                                                                     width: tableView.bounds.size.width,
                                                                     height: tableView.bounds.size.height))
                    noDataLabel.text = "目前沒有資料"
                    noDataLabel.textColor = UIColor.darkGray
                    noDataLabel.textAlignment = .center
                    tableView.backgroundView = noDataLabel
                    tableView.separatorStyle = .none
                } else {
                    tableView.backgroundView = UIView()
                    tableView.separatorStyle = .singleLine
                }
            }
            return historyDatas?.count ?? 0
        } else {
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifiers.Default, for: indexPath) as! HistoryViewTableViewCell
        if let data = historyDatas?[indexPath.row] {
            cell.carplateNumber.text = data.carplateNumber
            cell.caseID.text = data.caseID
            cell.serialNumber.text = data.serialNumber
            cell.caseStatusType = CaseStatus(rawValue: Int(data.state))!
            cell.caseType.text = data.caseType
        }
        // Configure the cell...
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
     */
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let caseFile = historyDatas?[indexPath.row]
            model?.deleteData(target: caseFile!)
            historyDatas = model?.fetchCoreData()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
//        else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//extension HistoryDataTableViewController: SubmitViewControllerDelegate {
//    func userDidRecieveSuccessfulData(data: CaseStructure!) {
//        model?.addSingleData(file: data)
//        pullToRefresh()
//    }
//}



