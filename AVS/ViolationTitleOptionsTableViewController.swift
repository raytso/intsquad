//
//  ViolationTitleOptionsTableViewController.swift
//  NoMoreParking
//
//  Created by Ray Tso on 3/8/17.
//  Copyright © 2017 Ray Tso. All rights reserved.
//

import UIKit

protocol ViolationTitleDelegation: class {
    func userDidSelectOption(sender: ViolationOptions.Options)
}

class ViolationTitleOptionsTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    private var optionsData = ViolationOptions()
    
    private var previousSelectedIndexPath: IndexPath?
    
    weak var didSelectDelegate: ViolationTitleDelegation?
    
    // MARK: - Application Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        previousSelectedIndexPath = tableView.indexPathForSelectedRow
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // check for initial selected state
        guard previousSelectedIndexPath != nil else { return }
        tableView.selectRow(at: previousSelectedIndexPath,
                            animated: true,
                            scrollPosition: .none)
    }
    
    // MARK: - Table view delegation
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = UITableViewCellAccessoryType.checkmark
        
        switch indexPath.row {
        case 0: optionsData.selectOption(option: .TempParking)
        case 1: optionsData.selectOption(option: .NoParking)
        case 2: optionsData.selectOption(option: .BlockingWaitingBlock)
        case 3: optionsData.selectOption(option: .OverStopLine)
        default: break
        }
        didSelectDelegate?.userDidSelectOption(sender: optionsData.getCurrentSelectedOption())
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = UITableViewCellAccessoryType.none
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
