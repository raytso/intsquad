//
//  SettingsDetailViewController.swift
//  NoMoreParking
//
//  Created by Ray Tso on 3/28/17.
//  Copyright © 2017 Ray Tso. All rights reserved.
//

import UIKit

class SettingsDetailViewController: UIViewController {

    @IBOutlet weak var contentTextField: UITextView!
    
    var contents: String?
    var navBarTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentTextField.text = contents
        self.title = navBarTitle

        // Do any additional setup after loading the view.
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

}
