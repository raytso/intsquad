//
//  SubmitViewDataTableViewController.swift
//  NoMoreParking
//
//  Created by Ray Tso on 3/5/17.
//  Copyright © 2017 Ray Tso. All rights reserved.
//

import UIKit

protocol ViolationTitleDataSource: class {
    func getSelectedOption(sender: SubmitViewDataTableViewController) -> String
}

protocol SubmitViewAllFieldsFilledDelegate: class {
    func allFieldsAreFilled()
}

protocol SubmitViewTableViewScrollDelegate: class {
    func tableViewScrolledToTop(sender: SubmitViewDataTableViewController)
    func scrollToMapView()
    func scrollUpTableView()
}

class SubmitViewDataTableViewController: UITableViewController, UITextFieldDelegate {
    
    // MARK: - Outlets

    @IBOutlet weak var toggleBar: UITableViewCell!
    
    @IBOutlet weak var carPlateTitle: UITableViewCell! {
        didSet { addShadow(layer: carPlateTitle.layer, height: .Top, isTitle: true) }
    }
    
    @IBOutlet weak var carPlateTableViewCell: UITableViewCell! {
        didSet {
            addShadow(layer: carPlateTableViewCell.layer, height: .Bottom, isTitle: false)
            carPlateTableViewCell.selectionStyle = .none
        }
    }
    
    @IBOutlet weak var userInputFrontCarPlateTextField: UITextField! {
        didSet {
            userInputFrontCarPlateTextField.adjustsFontSizeToFitWidth = true
            userInputFrontCarPlateTextField.delegate = self
        }
    }
    
    @IBOutlet weak var userInputBackCarPlateTextField: UITextField! {
        didSet {
            userInputBackCarPlateTextField.adjustsFontSizeToFitWidth = true
            userInputBackCarPlateTextField.delegate = self
        }
    }
    
    @IBOutlet weak var violationTitle: UITableViewCell!

    @IBOutlet weak var violationTableViewCell: UITableViewCell! {
        didSet { addShadow(layer: violationTableViewCell.layer, height: .Bottom, isTitle: false) }
    }
    
    @IBOutlet weak var violationTableViewCellLabel: UILabel!
    
    @IBOutlet weak var violationOptionsContainerView: UIView!
    
    var violationOptionsContainerViewVisible: Bool = false
    
    @IBOutlet weak var imagesTitle: UITableViewCell!
    
    @IBOutlet weak var selectedImagesTableViewCell: UITableViewCell! {
        didSet { selectedImagesTableViewCell.selectionStyle = .none }
    }
    
    @IBOutlet weak var otherTitle: UITableViewCell! {
        didSet { addShadow(layer: otherTitle.layer, height: .Top, isTitle: true) }
    }
    @IBOutlet weak var otherUserTableViewCell: UITableViewCell! {
        didSet {
            otherUserTableViewCell.layer.zPosition = 2.0
            otherUserTableViewCell.accessoryType = .disclosureIndicator
        }
    }
    
    var userInfoContainerViewVisible: Bool = false {
        didSet { userInfoContainerViewAddShadow = userInfoContainerViewVisible ? true : false }
    }
    
    @IBOutlet weak var userInfoContainerView: UIView!
    
    private var userInfoContainerViewAddShadow: Bool = false {
        didSet {
            if userInfoContainerViewAddShadow {
                addShadow(layer: otherUserTableViewCell.layer, height: .Bottom, isTitle: false)
                addShadow(layer: otherDateTableViewCell.layer, height: .Top, isTitle: true)
            } else {
                removeShadow(layer: otherUserTableViewCell.layer)
                removeShadow(layer: otherDateTableViewCell.layer)
            }
        }
    }
    
    @IBOutlet weak var otherDateTableViewCell: UITableViewCell!
    @IBOutlet weak var otherDateLabel: UILabel!
    @IBOutlet weak var otherDateIcon: UIImageView!
    
    @IBOutlet weak var otherTimeTableViewCell: UITableViewCell!
    @IBOutlet weak var otherTimeLabel: UILabel!
    @IBOutlet weak var otherTimeIcon: UIImageView!
    
    @IBOutlet weak var otherLocationTableViewCell: UITableViewCell! {
        didSet { addShadow(layer: otherLocationTableViewCell.layer, height: .Bottom, isTitle: false) }
    }
    @IBOutlet weak var otherLocationLabel: UILabel! {
        didSet {
            otherLocationLabel.adjustsFontSizeToFitWidth = true
        }
    }
    @IBOutlet weak var otherLocationIcon: UIImageView!

    
    // MARK: - Properties
    //  - Public
    
    var filesToUpload: [UploadFile]?
    var convertedSelectedImages: [UIImage]?
    
    //  - Private
    weak var violationDataSource: ViolationTitleDataSource?
    
    var embeddedViewController: ViolationTitleOptionsTableViewController?
    var userInfoViewController: UserInfoInputTableViewController?
    var imageCollectionViewController: SelectedImagesCollectionViewController?
    
    var carplateNumber: String? {
        if (carplateNumberFront?.isEmpty ?? true || carplateNumberBack?.isEmpty ?? true) {
            return nil
        } else {
            return carplateNumberFront! + "-" + carplateNumberBack!
        }
    }
    
    private var carplateNumberFront: String? {
        didSet {
            guard let _ = carplateNumberFront, !carplateNumberFront!.isEmpty else {
                userInputFrontCarPlateTextField.text = Constants.DefaultCarplateText.Front
                userInputFrontCarPlateTextField.textColor = #colorLiteral(red: 0.8350273967, green: 0.8350273967, blue: 0.8350273967, alpha: 1)
                
                return
            }
        }
    }
    
    private var carplateNumberBack: String? {
        didSet {
            guard let _ = carplateNumberBack, !carplateNumberBack!.isEmpty else {
                userInputBackCarPlateTextField.text = Constants.DefaultCarplateText.Back
                userInputBackCarPlateTextField.textColor = #colorLiteral(red: 0.8350273967, green: 0.8350273967, blue: 0.8350273967, alpha: 1)
                return
            }
        }
    }
    var time: Time? {
        didSet {
            otherDateLabel.text = time?.getAttributedDate()
            otherTimeLabel.text = time?.getAttributedTime()
        }
    }
    
    var address: Address? {
        didSet {
            otherLocationLabel.text = address?.getShortAddress()
        }
    }
    
    private var returnKeyAlreadySavedText = false
    
    private var shouldEndEditing = false
    
    var userSelectedOption: ViolationOptions.Options? {
        didSet {
            violationTableViewCellLabel.text = userSelectedOption?.rawValue
        }
    }
    
    weak var tableViewScrollDelegate: SubmitViewTableViewScrollDelegate?
    
    weak var allFieldsFilledDelegate: SubmitViewAllFieldsFilledDelegate?
    
    // MARK: - UIScrollViewDelegate
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            tableViewScrollDelegate?.tableViewScrolledToTop(sender: self)
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        var checkTarget: String?
        var checkParameter: String?

            switch textField {
            case userInputFrontCarPlateTextField:
                checkTarget = carplateNumberFront ?? ""
                checkParameter = carplateNumberBack ?? ""
            case userInputBackCarPlateTextField:
                checkTarget = carplateNumberBack ?? ""
                checkParameter = carplateNumberFront ?? ""
            default: return false
            }
        if checkTarget!.isEmpty {
            textField.text = nil
        }
        textField.textColor = UIColor.black
        setReturnKeyType(otherValue: checkParameter, field: textField)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if !returnKeyAlreadySavedText {
            switch textField {
            case userInputFrontCarPlateTextField:
                if carplateNumberFront?.isEmpty ?? true {
                    carplateNumberFront = textField.text
                } else {
                    checkAllInputFields()
                    return }
            case userInputBackCarPlateTextField:
                if carplateNumberBack?.isEmpty ?? true {
                    carplateNumberBack = textField.text
                } else {
                    checkAllInputFields()
                    return
                }
            default: break
            }
//            returnKeyAlreadySavedText = false
        }
        returnKeyAlreadySavedText = false
        checkAllInputFields()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case userInputFrontCarPlateTextField:
            carplateNumberFront = textField.text
        case userInputBackCarPlateTextField:
            carplateNumberBack = textField.text
        default: break
        }
        returnKeyAlreadySavedText = true
        if (textField.returnKeyType == .done) {
            self.dismissKeyboard()
        }
        return true
    }
    
    
    
    // MARK: - UDFs
    enum ShadowPosition: Double {
        case Top = -1.0
        case Bottom = 4.0
        case Toggle = -4.0
    }
    
    private func checkAllInputFields() {
        if didInputAllTextFields() {
            if didInputLocation() {
                allFieldsFilledDelegate?.allFieldsAreFilled()
            }
        }
    }
    private func didInputLocation() -> Bool {
        return (address != nil) ? true : false
    }
    
    private func didInputAllTextFields() -> Bool {
        return (carplateNumber == nil) ? false : true
    }
    
    private func setReturnKeyType(otherValue: String?, field: UITextField) {
        field.returnKeyType = (otherValue?.isEmpty ?? true) ? .next : .done
        return
    }
    
    private func checkValidInput(input: String) -> Bool{
        return input.isAlphanumerics ? true : false
    }
    
    func checkCarPlate() -> Bool {
        guard carplateNumberFront != nil && carplateNumberBack != nil else { return false }
        let plateNumbers = [carplateNumberFront!, carplateNumberBack!]
        for section in plateNumbers {
            let isValid = checkValidInput(input: section)
            guard isValid else {
                return false
            }
        }
        return true
    }
    
    func checkAddress() -> Bool {
        return (address == nil) ? false : true
    }
    
    func checkSupportedCities() {
        
    }
    
    private func addShadow(layer: CALayer, height: ShadowPosition, isTitle: Bool) {
        layer.masksToBounds = false
        layer.shadowColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 2.4
        layer.shadowOffset = CGSize(width: 0.0, height: height.rawValue)
        layer.zPosition = isTitle ? 1.0 : 2.0
    }
    
    private func removeShadow(layer: CALayer) {
        layer.masksToBounds = true
        layer.shadowColor = UIColor.clear.cgColor
        layer.shadowRadius = 0.0
        layer.shadowOpacity = 0.0
        layer.shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 0, height: 0)).cgPath
    }
    
    func updateAddressCell(newAddress: String, addressClass: Address) {
        DispatchQueue.main.async { [unowned self] in
            self.otherLocationLabel.text = newAddress
            self.otherLocationLabel.textColor = UIColor.black
            self.address = addressClass
            DispatchQueue.global().async { [unowned self] in
                self.checkAllInputFields()
            }
        }
    }
    
    func updateContainerViewVisibility(desired: Visibility, forView: UIView) {
        switch forView {
        case userInfoContainerView:
            userInfoContainerViewVisible = desired == .Visible ? true : false
        case violationOptionsContainerView:
            violationOptionsContainerViewVisible = desired == .Visible ? true : false
        default: break
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
        UIView.animate(withDuration: 0.1,
                       animations: { forView.alpha = desired.rawValue }) { _ in
            forView.isHidden = (desired == .Visible) ? false : true
        }
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func dismissKeyboardByTap() {
        dismissKeyboard()
    }
    
    func scrollToTop() {
        let desiredOffset = CGPoint(x: 0, y: -self.tableView.contentInset.top)
        self.tableView.setContentOffset(desiredOffset, animated: true)
    }
    
    struct Constants {
        static let ScrollViewInsetYValue = CGFloat(8.0 + SubmitViewConstants.TableViewTopPosition)
        struct DefaultCarplateText {
            static let Front = "AAA"
            static let Back = "0000"
        }
    }
    
    // MARK: - Application Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Dismiss keyboard on tap
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboardByTap))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        // Data initialization
        userSelectedOption = ViolationOptions.Options.OverStopLine
        
        time = Time(data: filesToUpload?.first?.content)
        
        
        // Added a UIView layer between table view and table cells, used as "platform" to achieve background color without blocking tableview's background
        // Added offset and longer height to deal with bottom bouncing
        let backLayer = UIView(frame: CGRect(x: 0.0, y: Constants.ScrollViewInsetYValue, width: tableView.bounds.width, height: tableView.bounds.height * 2.5))
        backLayer.backgroundColor = #colorLiteral(red: 0.9373082519, green: 0.9373301864, blue: 0.9373183846, alpha: 1)
        self.tableView.insertSubview(backLayer, at: 0)
        
        // Scrollview settings
        self.automaticallyAdjustsScrollViewInsets = false
        self.tableView.isDirectionalLockEnabled = true
        self.tableView.decelerationRate = UIScrollViewDecelerationRateFast
        self.tableView.scrollsToTop = false
//        self.tableView.showsVerticalScrollIndicator = true
        
        userInputFrontCarPlateTextField.addTarget(userInputBackCarPlateTextField,
                                                  action: #selector(becomeFirstResponder),
                                                  for: .editingDidEndOnExit)

        userInputBackCarPlateTextField.addTarget(userInputFrontCarPlateTextField,
                                                 action: #selector(becomeFirstResponder),
                                                 for: .editingDidEndOnExit)
        
        // Other view settings
        violationOptionsContainerView.translatesAutoresizingMaskIntoConstraints = false
        userInfoContainerView.translatesAutoresizingMaskIntoConstraints = false
        violationOptionsContainerView.isHidden = true
        userInfoContainerView.isHidden = true
    }
    
    // MARK: - Table view delegation
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            var targetView: UIView?
            
            switch cell {
            case violationTableViewCell:
                targetView = violationOptionsContainerView
            case otherUserTableViewCell:
                targetView = userInfoContainerView
            case otherLocationTableViewCell:
                scrollToTop()
                tableViewScrollDelegate?.scrollToMapView()
            case toggleBar:
                tableViewScrollDelegate?.scrollUpTableView()
            default: break
            }
            guard targetView != nil else {
                tableView.deselectRow(at: indexPath, animated: true)
                return
            }
            updateContainerViewVisibility(desired: targetView!.isHidden ? .Visible : .Hidden,
                                          forView: targetView!)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            if indexPath.row == 3 {
                if !violationOptionsContainerViewVisible { return 0.0 }
            }
        }
        else if indexPath.section == 2 {
            if indexPath.row == 2 {
                if !userInfoContainerViewVisible { return 0.0 }
            }
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        if tableView == violationTitleOptionsTableView {
//            return 1
//        }
//    }

//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

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
    
    struct SegueIdentifiers {
        static let ViolationTableViewSegue = "embeddedTableViewController"
        static let UserInfoTableViewSegue = "userInfoTableViewControllerSegue"
    }
    
    enum Visibility: CGFloat {
        case Visible = 1.0
        case Hidden = 0.0
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let controller = segue.destination as? ViolationTitleOptionsTableViewController {
            embeddedViewController = controller
            embeddedViewController!.didSelectDelegate = self
        }
        else if let controller = segue.destination as? UserInfoInputTableViewController {
            userInfoViewController = controller
//            userInfoViewController?.tableView.reloadData()
        }
        else if let controller = segue.destination as? SelectedImagesCollectionViewController {
            imageCollectionViewController = controller
            imageCollectionViewController?.imageSet = convertedSelectedImages
        }
    }
}

private extension String {
    var isAlphanumerics: Bool {
        let alphabets = "abcdefghijklmnopqrstuvwxyz"
        let numbers  = "0123456789"
        let filter = CharacterSet(charactersIn: numbers + alphabets + alphabets.uppercased()).inverted
        let result = self.unicodeScalars.contains {
            filter.contains($0)
        }
        return result ? false : true
    }
}

extension SubmitViewDataTableViewController: ViolationTitleDelegation {
    func userDidSelectOption(sender: ViolationOptions.Options) {
        violationTableViewCellLabel.text = sender.rawValue
        userSelectedOption = sender
        if !violationOptionsContainerView.isHidden {
            violationOptionsContainerViewVisible = false
            updateContainerViewVisibility(desired: .Hidden, forView: violationOptionsContainerView)
        }
    }
}
