//
//  StartViewController.swift
//  NoMoreParking
//
//  Created by Ray Tso on 3/28/17.
//  Copyright © 2017 Ray Tso. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {
    
    let defaults = UserDefaults.standard
    
    @IBAction func backToStartViewController(sender: UIStoryboardSegue) { }
    
    var agreed: Bool?
    
    struct UserDefaultKeys {
        static let UserAgreement = "UserAgreement"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        defaults.set(["zh_Hant_TW"], forKey: "AppleLanguages")
        agreed = defaults.bool(forKey: UserDefaultKeys.UserAgreement)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        performSegue(withIdentifier: agreed ?? false ? SegueIdentifiers.TabSegue : SegueIdentifiers.AgreementSegue, sender: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation
    struct SegueIdentifiers {
        static let AgreementSegue = "agreementSegueIdentifier"
        static let TabSegue = "tabSegueIdentifier"
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let controller = segue.destination as? AgreementViewController {
            controller.delegate = self
        }
    }
    

}

extension StartViewController: AgreementViewControllerDelegate {
    func userDidAgree() {
        defaults.set(true, forKey: UserDefaultKeys.UserAgreement)
        agreed = true
    }
    
    func viewUnwindingBack() {
        performSegue(withIdentifier: SegueIdentifiers.TabSegue, sender: nil)
    }
}
