//
//  HistoryViewController.swift
//  NoMoreParking
//
//  Created by Ray Tso on 3/24/17.
//  Copyright © 2017 Ray Tso. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var historyDataTableContainer: UIView!
    
    private var dataTable: HistoryDataTableViewController?
    
    private weak var tab: AppMenuTabBarViewController?
    
    // MARK: - UDFs
    
    private func addShadow(layer: CALayer) {
        layer.masksToBounds = false
        layer.shadowColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 4.0
        layer.shadowOffset = CGSize(width: 0.0, height: 6.0)
        layer.zPosition = 2.0
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // WARNING - Reference to PARENT
        tab = self.tabBarController as? AppMenuTabBarViewController
        dataTable?.model = tab?.database
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        UIApplication.shared.statusBarStyle = .default
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let controller = segue.destination as? HistoryDataTableViewController {
            dataTable = controller
        }
    }
    

}
