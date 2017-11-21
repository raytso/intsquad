//
//  AppMenuTabBarViewController.swift
//  NoMoreParking
//
//  Created by Ray Tso on 3/24/17.
//  Copyright © 2017 Ray Tso. All rights reserved.
//

import UIKit

class AppMenuTabBarViewController: UITabBarController {
    
    @IBInspectable var defaultIndex: Int = TabBarControllers.Camera.rawValue
    
    let database = HistoryViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        AppDelegate.gpsInstance?.startGPS()
        selectedIndex = defaultIndex
        // default
        let data = ViolationURLs(postURL: "https://www.tcpd.gov.tw/tcpd/cht/index.php?act=traffic&code=add",
                                 searchURL: "https://www.tcpd.gov.tw/tcpd/cht/index.php?act=traffic&code=search")
        AppData.supportedCities["台北市"] = data
        NotificationCenter.default.addObserver(forName: NotificationConstants.NewData, object: nil, queue: nil) { (notification) in
            if let data = notification.object as? CaseStructure {
                self.database.addSingleData(file: data)
            }
        }
        setupTabBar()
    }
    
    private func setupTabBar() {
        self.tabBar.backgroundImage = UIImage()
        self.tabBar.backgroundColor = UIColor.clear
        self.tabBar.shadowImage = UIImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    enum TabBarControllers: Int {
        case Settings = 0
        case Camera = 1
        case History = 2
    }

}

struct AppData {
    static var supportedCities: [String : ViolationURLs] = [:]
}
