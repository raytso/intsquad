//
//  StartViewController.swift
//  NoMoreParking
//
//  Created by Ray Tso on 3/27/17.
//  Copyright © 2017 Ray Tso. All rights reserved.
//

import UIKit
import CoreLocation

protocol AgreementViewControllerDelegate: class {
    func userDidAgree()
    func viewUnwindingBack()
}

class AgreementViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var userAgreementTextField: UITextView!
    
    @IBOutlet weak var privacyTextField: UITextView!
    
    @IBAction func agreeButton(_ sender: Any) { checkUserAgreement() }
    
    weak var delegate: AgreementViewControllerDelegate?
    
    private let pingLocation: CLLocation = CLLocation(latitude: 25.037503, longitude: 121.563593)
    
    private var agreedToUserAgreement: Bool = false
    
    private var agreementAlert: UIAlertController?
    
    private var userAgreementText: String = {
        let text = AreaLegalConstants.TaipeiCity.TermsOfUse
        return text
    }()
    
    private var privacyText: String = {
        let text = AreaLegalConstants.TaipeiCity.Privacy
        return text
    }()

    struct SegueIdentifier {
        static let GTG = "proceed"
    }
    
    // MARK: - UDFs
    
    private func checkConnections() {
        if CLLocationManager.locationServicesEnabled() && CLLocationManager.authorizationStatus() != .denied {
            CLGeocoder().reverseGeocodeLocation(pingLocation, completionHandler: { [unowned self] (placemarks, respError) -> Void in
                if respError != nil {
                    let alert = UIAlertController.init(title: "錯誤",
                                                       message: "\n需要網路連線",
                                                       preferredStyle: .alert)
                    alert.addAction(.init(title: "確認", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.delegate?.userDidAgree()
                    self.performSegue(withIdentifier: SegueIdentifiers.BackToStart, sender: nil)
                }
            })
        } else {
            let alert = UIAlertController.init(title: "錯誤",
                                               message: "\n需要您授權GPS定位!\n\n開啟方式：\n設定>隱私權>定位服務",
                                               preferredStyle: .alert)
            alert.addAction(.init(title: "確認", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func checkUserAgreement() {
        self.present(agreementAlert!, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        userAgreementTextField.text = userAgreementText
        privacyTextField.text = privacyText
        
        let alert = UIAlertController.init(title: "使用者條款",
                                           message: "我已閱讀臺北市政府警察局\n【個人資料收集聲明及服務條款】\n暨相關\n【隱私權政策】",
                                           preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "不同意", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction.init(title: "同意", style: .default, handler: { [unowned self] (_) in
            self.agreedToUserAgreement = true
            self.checkConnections()
        }))
        agreementAlert = alert
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        delegate?.viewUnwindingBack()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation
    
    struct SegueIdentifiers {
        static let BackToStart = "backToStartViewController"
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}

struct AreaLegalConstants {
    struct TaipeiCity {
        static let TermsOfUse = "1.  本局(臺北市政府警察局)取得您的個人資料，在個人資料保護法及相關法令之規定下，依本局隱私權保護政策，蒐集、處理及利用您的個人資料。\n\n2.  您可依您的需要提供以下個人資料：姓名、出生年月日、國民身分證統一編號、連絡方式(包括但不限於電話號碼、E-MAIL或居住地址)或其他得以直接或間接識別您個人之資料。\n\n3.  您同意本局以您所提供之個人資料確認您的身分、與您進行連絡、提供您本局相關服務及資訊，以及其他隱私權保護政策規範之使用方式。\n\n4.  您可依個人資料保護法，就您的個人資料向本局(1)請求查詢或閱覽、(2)製給複製本、(3)請求補充或更正、(4)請求停止蒐集、處理及利用或(5)請求刪除。但因本局執行職務或業務所必需者，本局得拒絕之。\n\n5.  您可自由選擇是否提供本局您的個人資料，但若您所提供之個人資料，經檢舉或本局發現不足以確認您的身分真實性或其他個人資料冒用、盜用、資料不實等情形，本局將不予處理。\n\n6.  您瞭解此一同意符合個人資料保護法及相關法規之要求，具有書面同意本局蒐集、處理及利用您的個人資料之效果。"
        static let Privacy = "非常歡迎您光臨 臺北市政府警察局 ( 以下簡稱本網站 )，為了讓您能夠安心的使用本網站的各項服務與資訊，特此向您說明本網站的隱私權保護政策，以保障您的權益，請您詳閱下列內容：\n\n隱私權保護政策的適用範圍 \n\n隱私權保護政策內容，包括本網站如何處理在您使用網站服務時收集到的個人識別資料。\n\n隱私權保護政策不適用於本網站以外的相關連結網站 ，也不適用於非本網站所委託或參與管理的人員。\n\n資料的蒐集與使用方式\n\n為了在本網站上提供您最佳的互動性服務，可能會請您提供相關個人的資料，其範圍如下：\n\n1.  本網站在您使用服務信箱、問卷調查等互動性功能時，會保留您所提供的姓名、電子郵件地址、連絡方式及使用時間等。\n\n2.  於一般瀏覽時，伺服器會自行紀錄相關行徑，包括您使用連線設備的IP位址、使用時間、使用的瀏覽器、瀏覽及點選資料紀錄等，做為我們增進網站服務的參考依據，此紀錄為內部應用，絕不對外公佈\n\n3.  為提供精確的服務，我們會將收集的問卷調查內容進行統計與分析，分析結果將之統計後的數據或說明文字呈現，除供內部研究外，我們會視需要公佈該數據及說明文字，但不涉及特定個人之資料。\n\n4.  除非取得您的同意或其他法令之特別規定，本網站絕不會將您的個人資料揭露於第三人或使用於蒐集目的以外之其他用途。\n\n資料之保護\n\n本網站主機均設有防火牆、防毒系統等相關的各項資訊安全設備及必要的安全防護措施，加以保護網站及您的個人資料。\n\n採用嚴格的保護措施，只由經過授權的人員才能接觸您的個人資料，相關處理人員皆簽有保密合約，如有違反保密協議者，將會受到相關的法律處分。\n\n如因業務需要有必要委託本局相關單位提供服務時，本網站亦會嚴格要求其遵守保密義務，並且採取必要檢查程序以確定其將確實遵守。\n\n網站對外的相關連結\n本網站的網頁提供其他網站的網路連結，您也可經由本網站所提供的連結，點選進入其他網站。但該連結網站中不適用於本網站的隱私權保護政策，您必須參考該連結網站中的隱私權保護政策。\n\nCookie之使用\n為了提供您最佳的服務，本網站會在您的電腦中放置並取用我們的Cookie，若您不願接受Cookie的寫入，您可在您使用的瀏覽器功能項中設定隱私權等級為高，即可拒絕Cookie的寫入，但可能會導至網站某些功能無法正常執行 。\n\n隱私權保護政策之修正\n\n本網站隱私權保護政策將因應需求隨時進行修正，修正後的條款將刊登於網站上。"
    }
}
