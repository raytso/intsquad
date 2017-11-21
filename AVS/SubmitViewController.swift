//
//  SubmitViewController.swift
//  NoMoreParking
//
//  Created by Ray Tso on 3/6/17.
//  Copyright © 2017 Ray Tso. All rights reserved.
//

import UIKit
import MapKit

struct ScreenConstants {
    static let Width = UIScreen.main.bounds.width
    static let Height = UIScreen.main.bounds.height
}

struct AlertConstants {
    struct ErrorConst {
        static let Carplate = "\n車牌號碼有誤"
        static let Location = "\n地址錯誤"
        static let Ending = "\n\n請更正之後再重新送出！\n"
    }
}

//protocol SubmitViewControllerDelegate: class {
//    func userDidRecieveSuccessfulData(data: CaseStructure!)
//}

class SubmitViewController: UIViewController, UIGestureRecognizerDelegate, MKMapViewDelegate, VPSAAnnotationDataSource, AddressClassDatasource, ViolationFormMetadataDataSource {
    
    //MARK: - Outlets
    @IBOutlet weak var tableViewContainerView: UIView! {
        didSet { tableViewContainerView.translatesAutoresizingMaskIntoConstraints = true }
    }
    
    @IBOutlet weak var mapViewMask: UIView! {
        didSet { mapViewMask.alpha = 0.0 }
    }
    
    @IBOutlet weak var mapView: UserLocationMapView! {
        didSet {
            mapView.delegate = self
            mapView.mapType = .standard
            mapView.isPitchEnabled = false
            mapView.showsCompass = true
            guard AppDelegate.gpsInstance!.currentGPSLocation != nil else {
                // Do sth
                return
            }
            mapView.region = .init(center: AppDelegate.gpsInstance!.currentGPSLocation!.coordinate,
                                   span: .init(latitudeDelta: CLLocationDegrees.abs(0.002),
                                               longitudeDelta: CLLocationDegrees.abs(0.002)))
            mapView.showsUserLocation = true
            mapView.userPinnedAnnotation = userLocationAnnotation
        }
    }
    
    @IBOutlet weak var sendFormButton: UIButton! {
        didSet {
            sendFormButton.layer.cornerRadius = 6.0
            addShadow(layer: sendFormButton.layer)
            sendFormButton.isHidden = true
        }
    }
    @IBAction func userPressesSendFormButton(_ sender: Any) {
        let color = UIColor(colorLiteralRed: 0.34, green: 0.62, blue: 0.17, alpha: 1.0)
        sendFormButton.layer.backgroundColor = color.cgColor
    }
    @IBAction func userReleasesSendFormButton(_ sender: Any) {
        let (isReady, missingFields) = prepareToPost()
        guard isReady else {
            // UIAlert here
            // show missing fields
            var message = ""
            for field in missingFields! {
                message += field
            }
            submitCheckAlert.message = message + AlertConstants.ErrorConst.Ending
            present(submitCheckAlert, animated: true, completion: nil)
            let color = #colorLiteral(red: 0.007642803248, green: 0.7857376933, blue: 0.01051853877, alpha: 1)
            sendFormButton.layer.backgroundColor = color.cgColor
            return
        }
        post()
        let color = #colorLiteral(red: 0.007642803248, green: 0.7857376933, blue: 0.01051853877, alpha: 1)
        sendFormButton.layer.backgroundColor = color.cgColor
        performSegue(withIdentifier: SegueIdentifiers.ResponseView, sender: nil)
    }
    
    @IBAction func unwindToSubmitForm(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func userCancelForm(_ sender: Any) {
        present(discardDataAlert, animated: true, completion: nil)
    }
    
    // MARK: - Properties
    
    var filesToUpload: [UploadFile]?
    
    var convertedSelectedImages: [UIImage]?
    
    var dataTableViewController: SubmitViewDataTableViewController?
    
    var responseViewController: ResponseViewController?
    
    var submitForm: ViolationForm?
    
    var session: FormRequestSessionWithAlamofire?
    
    var panningGesture: UIPanGestureRecognizer?
    
    var obtainedResults: [String : String]? { didSet { debugPrint(obtainedResults!) } }
    
    var userPinnedLocationAddress: Address?
    
    var isTableViewScrolledToTop: Bool = true
    
    let userPosition = AppDelegate.gpsInstance?.currentGPSLocation?.coordinate
    
    let userLocationAnnotation: MKPointAnnotation = {
        let annotation = MKPointAnnotation()
        annotation.title = " "
        return annotation
    }()
    
    private let systemTriggeredPan = UIPanGestureRecognizer()
    
    private var discardDataAlert: UIAlertController = {
        let alert = UIAlertController.init(title: "確定要退出？", message: "\n您會失去已經拍攝的影像及輸入的資料。", preferredStyle: .alert)
        return alert
    }()
    
    private var submitCheckAlert: UIAlertController = {
        let alert = UIAlertController(title: "糟糕！", message: nil, preferredStyle: .alert)
        return alert
    }()
    
    private var noGPSDiscardAlert: UIAlertController = {
        let alert = UIAlertController.init(title: "錯誤", message: "\n很抱歉！由於您沒有提供GPS授權，故程式將會跳回首頁。", preferredStyle: .alert)
        return alert
    }()
    
    private var scrolledAmount: CGFloat = 0.0
    
    private var detailedCallout: VPSAAnnotationCalloutView?
    
    private var userPinnedCLLocation: CLLocation?
    
    private var placemark: CLPlacemark?
    
    private var userPinnedLocation: CLLocationCoordinate2D? {
        didSet {
            guard userPinnedLocation != nil else { return }
            userPinnedCLLocation = CLLocation(latitude: userPinnedLocation!.latitude, longitude: userPinnedLocation!.longitude)
            userPinnedLocationAddress?.requestGeocoder()
        }
    }
    
    enum TableViewPosition {
        case Top
        case Bottom
    }
    
    // MARK: - UDFs
    
    private func backToCamera() {
        self.performSegue(withIdentifier: SegueIdentifiers.Unwind, sender: nil)
    }
    
    private func setupAlertAction(alert: UIAlertController) {
        switch alert {
        case discardDataAlert:
            let proceed = UIAlertAction.init(title: "確認", style: .destructive) { [unowned self] (_) in
                self.backToCamera()
            }
            let cancel = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
            alert.addAction(cancel)
            alert.addAction(proceed)
        case submitCheckAlert:
            let proceed = UIAlertAction.init(title: "確認", style: .default, handler: nil)
            alert.addAction(proceed)
        case noGPSDiscardAlert:
            let proceed = UIAlertAction.init(title: "確認", style: .default, handler: { [unowned self] (_) in
                self.performSegue(withIdentifier: SegueIdentifiers.Unwind, sender: nil)
            })
            alert.addAction(proceed)
        default: break
        }
    }
    
    private func prepareToPost() -> (Bool, [String]?) {
        let (check, fields) = checkAllFieldsFilled()
        guard check else { return (false, fields) }
        submitForm = ViolationForm.init(desiredPrivacy: .Default,
                                        carPlate: dataTableViewController!.carplateNumber!,
                                        violationTime: dataTableViewController!.time!,
                                        violationAddress: dataTableViewController!.address!,
                                        violationType: dataTableViewController!.userSelectedOption ?? ViolationOptions.Options.OverStopLine)
        session = FormRequestSessionWithAlamofire(formData: submitForm!, files: filesToUpload!)
        session?.delegate = self
        return (true, nil)
    }
    
    private func isFormReady() -> Bool {
        guard submitForm != nil && session != nil else { return false }
        return true
    }
    
    func checkAllFieldsFilled() -> (Bool, [String]?) {
        var missingFields: [String] = []
        // check all fields
        // even whether user selected location is valid
        if !dataTableViewController!.checkCarPlate() {
            missingFields.append(AlertConstants.ErrorConst.Carplate)
        }
        if !dataTableViewController!.checkAddress() {
            missingFields.append(AlertConstants.ErrorConst.Location)
        }
        
        return missingFields.isEmpty ? (true, nil) : (false, missingFields)
    }
    
    private func post() {
        let url = AppData.supportedCities[userPinnedLocationAddress!.city!]!.postURL
        session!.postViolationFormData(postUrl: url)
    }
    
    func detailViewNeedsUpdate(succeeded: Bool) {
        detailedCallout?.updateAddressTextField(succeeded: succeeded)
    }
    
    func setTableViewFrame() {
        let newY = SubmitViewConstants.TableViewStartY
        let rect = CGRect(x: 0.0, y: newY,
                          width: ScreenConstants.Width, height: ScreenConstants.Height - SubmitViewConstants.TableViewTopPosition)
        tableViewContainerView.frame = rect
    }
    
    func snapTableViewToPosition(position: CGFloat) {
        var centerCoordinate: CLLocationCoordinate2D?
        if position == SubmitViewConstants.TableViewTopPosition {
            let mapViewYInset: CGFloat = ((ScreenConstants.Height - SubmitViewConstants.TableViewInitialOriginY) / 2) * 0.5
            centerCoordinate = mapView.userPinnedAnnotation?.coordinate
            var viewPoint = mapView.convert(centerCoordinate!, toPointTo: mapView)
            viewPoint = CGPoint(x: viewPoint.x, y: viewPoint.y + mapViewYInset)
            centerCoordinate = mapView.convert(viewPoint, toCoordinateFrom: mapView)
        }
        UIView.animate(withDuration: 0.2, animations: {
            let frame = self.tableViewContainerView.frame
            self.mapViewMask.alpha = self.mapViewMaskValue(position: position)
            if centerCoordinate != nil {
                self.mapView.setCenter(centerCoordinate!, animated: true)
            }
            self.tableViewContainerView.frame = CGRect(x: 0.0, y: position, width: frame.width, height: frame.height)
        }) { _ in
            self.dataTableViewController?.tableView.isScrollEnabled = (position == SubmitViewConstants.TableViewTopPosition) ? true : false
        }
    }
    
    func mapViewMaskValue(position: CGFloat) -> CGFloat {
        var alpha: CGFloat?
        if position == SubmitViewConstants.TableViewTopPosition {
            alpha = 0.8
            UIApplication.shared.statusBarStyle = .lightContent
        } else {
            alpha = 0.0
            UIApplication.shared.statusBarStyle = .default
        }
        return alpha!
    }
    
    func scrollVertically(recognizer: UIPanGestureRecognizer) {
        self.dataTableViewController?.tableView.endEditing(true)
        let translation = recognizer.translation(in: self.view)
        let tableContainerViewYPosition = tableViewContainerView.frame.minY
        var isSnapToTop = true

        if (tableContainerViewYPosition == SubmitViewConstants.TableViewTopPosition) {
            // check if tableView is scrolled to top
            if isTableViewScrolledToTop {
                if translation.y > 0 {
                    self.dataTableViewController?.tableView.isScrollEnabled = false
                } else {
                    isTableViewScrolledToTop = false
                    recognizer.setTranslation(CGPoint.zero, in: self.view)
                    return
                }
            } else {
                // normal scrolling no panning
                self.dataTableViewController?.tableView.isScrollEnabled = true
                recognizer.setTranslation(CGPoint.zero, in: self.view)
                return
            }
        }
        else if tableContainerViewYPosition < SubmitViewConstants.TableViewTopPosition {
            UIView.animate(withDuration: 0.15, animations: {
                self.tableViewContainerView.frame.origin = CGPoint(x: 0.0, y: SubmitViewConstants.TableViewTopPosition)
            })
            self.scrolledAmount = 0.0
            self.dataTableViewController?.tableView.isScrollEnabled = true
            isSnapToTop = true
            return
        }
        
        if recognizer.state == .ended {
            var target: CGFloat
            let startingPosition = tableContainerViewYPosition - scrolledAmount
            if startingPosition == SubmitViewConstants.TableViewTopPosition {
                if abs(scrolledAmount) > SubmitViewConstants.TableViewSnapThreshold && scrolledAmount > 0 {
                    isSnapToTop = false
                }
            } else {
                // Bottom
                if (abs(scrolledAmount) > SubmitViewConstants.TableViewSnapThreshold && scrolledAmount < 0) {
                    isSnapToTop = true
                } else {
                    isSnapToTop = false
                }
            }
            target = isSnapToTop ? SubmitViewConstants.TableViewTopPosition : SubmitViewConstants.TableViewInitialOriginY
            
            scrolledAmount = 0.0
            snapTableViewToPosition(position: target)
        } else {
            scrolledAmount += translation.y
            tableViewContainerView.frame.origin = CGPoint(x: 0.0, y: tableContainerViewYPosition + translation.y)
        }
        recognizer.setTranslation(CGPoint.zero, in: self.view)
    }
    
    func updatePinAddressLocation(annotation: MKAnnotation) {
        userPinnedLocation = annotation.coordinate
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - MapView Delegates
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation { return nil }
        
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: SubmitViewConstants.AnnotationViewReuseIdentifier)
        
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: SubmitViewConstants.AnnotationViewReuseIdentifier)
            view?.canShowCallout = true
        } else {
            view?.annotation = annotation
        }
        userPinnedLocation = annotation.coordinate
        view?.detailCalloutAccessoryView = detailedCallout
        
        view?.isDraggable = true
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        switch newState {
        case .ending:
            view.dragState = .none
            updatePinAddressLocation(annotation: view.annotation!)
        default: break
        }
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        let blueDot = mapView.view(for: mapView.userLocation)
        blueDot?.isEnabled = false
        guard self.userPinnedLocation != nil else { return }
        self.mapView.prepareToShowAnnotationView(annotation: self.mapView.userPinnedAnnotation!)
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        AppDelegate.gpsInstance?.stopGPS()
        guard self.userPinnedLocation != nil else { return }
        self.mapView.prepareToShowAnnotationView(annotation: self.mapView.userPinnedAnnotation!)
    }
    
    // MARK: - ViolationFormMetadata DataSource
    
    func filesToUploadForViolationForm(sender: ViolationForm) -> [UploadFile]? {
        return filesToUpload
    }
    
    // MARK: - VPSAAnnotaiton Datasource
    
    var addressText: String? {
        return userPinnedLocationAddress?.getAnnotationCalloutText()
    }
    
    // MARK: - Address Class Datasource
    
    func locationDataForAddressClass(sender: Address) -> CLLocation? {
        return userPinnedCLLocation
    }
    
    // MARK: - Application Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.dataTableViewController?.tableView.isScrollEnabled = true
        // Do any additional setup after loading the view.
        panningGesture = UIPanGestureRecognizer.init(target: self, action: #selector(self.scrollVertically))
        tableViewContainerView.addGestureRecognizer(panningGesture!)
        panningGesture!.delegate = self
        
        self.navigationItem.hidesBackButton = true
        
        // initial position
        setTableViewFrame()
        
        detailedCallout = VPSAAnnotationCalloutView.init(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0))
        userPinnedLocationAddress = Address()
        
        detailedCallout?.annotationDataSource = self
        detailedCallout?.annotationDelegate = self
        userPinnedLocationAddress?.dataSource = self
        userPinnedLocationAddress?.delegate = self
        
        // Alerts
        setupAlertAction(alert: discardDataAlert)
        setupAlertAction(alert: submitCheckAlert)
        setupAlertAction(alert: noGPSDiscardAlert)
        
        UIApplication.shared.statusBarStyle = .default
        
        // Set map initial location
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard userPosition != nil else {
            present(noGPSDiscardAlert, animated: true, completion: nil)
            return
        }
        userLocationAnnotation.coordinate = userPosition!
    }
    
    private func addShadow(layer: CALayer) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.7
        layer.shadowRadius = 3.4
        layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
    }
    
    // MARK: - Navigation
    
    struct SegueIdentifiers {
        static let ResponseView = "ResponseViewPresentIdentifier"
        static let Unwind = "unwindToCameraView"
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let controller = segue.destination as? SubmitViewDataTableViewController {
            dataTableViewController = controller
            dataTableViewController?.automaticallyAdjustsScrollViewInsets = false
            dataTableViewController?.filesToUpload = filesToUpload
            dataTableViewController?.convertedSelectedImages = convertedSelectedImages
            dataTableViewController?.tableViewScrollDelegate = self
            dataTableViewController?.allFieldsFilledDelegate = self
            dataTableViewController?.automaticallyAdjustsScrollViewInsets = false
        } else if let controller = segue.destination as? ResponseViewController {
            responseViewController = controller
            responseViewController?.delegate = self
        } else if segue.identifier == SegueIdentifiers.Unwind {
            responseViewController = nil
            dataTableViewController?.embeddedViewController = nil
            dataTableViewController?.userInfoViewController = nil
            dataTableViewController?.imageCollectionViewController = nil
            dataTableViewController = nil
        }
    }
}

struct SubmitViewConstants {
    static let TableViewToggleCellSize = CGFloat(40.0)
    static let TableViewSnapThreshold = ScreenConstants.Height * 0.08
    static let TableViewInitialOriginY = ScreenConstants.Height * 0.75
    static let TableViewStartY = ScreenConstants.Height - SubmitViewConstants.TableViewToggleCellSize
    static let TableViewTopPosition = CGFloat(68.0)
    static let AnnotationViewReuseIdentifier = "location"
}

extension SubmitViewController: SubmitViewAllFieldsFilledDelegate {
    func allFieldsAreFilled() {
        // Show send button with animation
        DispatchQueue.main.async { [unowned self] in
            if self.sendFormButton.isHidden {
                self.sendFormButton.alpha = 0.0
                UIView.animate(withDuration: 0.3) {
                    self.sendFormButton.alpha = 1.0
                    self.sendFormButton.isHidden = false
                }
            }
        }
    }
}

extension SubmitViewController: SubmitViewTableViewScrollDelegate {
    func scrollToMapView() {
        isTableViewScrolledToTop = true
        snapTableViewToPosition(position: SubmitViewConstants.TableViewInitialOriginY)
    }
    
    func scrollUpTableView() {
        snapTableViewToPosition(position: SubmitViewConstants.TableViewTopPosition)
    }

    func tableViewScrolledToTop(sender: SubmitViewDataTableViewController) {
        isTableViewScrolledToTop = true
    }
}

extension SubmitViewController: AddressClassDelegate {
    func geocodeRecieved(succeeded: Bool) {
        detailViewNeedsUpdate(succeeded: succeeded)
    }
}

extension SubmitViewController: VPSAAnnotationDelegate {
    func userDidVerify(selected: Bool) {
        if selected {
            if let city = userPinnedLocationAddress?.city {
                if AppData.supportedCities[city] != nil {
                    DispatchQueue.global().async { [unowned self] in
                        let newAddress = self.userPinnedLocationAddress!.getShortAddress()
                        self.dataTableViewController?.updateAddressCell(newAddress: newAddress!, addressClass: self.userPinnedLocationAddress!)
                    }
                    snapTableViewToPosition(position: SubmitViewConstants.TableViewTopPosition)
                    if UserDefaults.standard.bool(forKey: "shouldBringKeyboard") {
                        let result = dataTableViewController?.checkCarPlate()
                        if !result! {
                            dataTableViewController?.userInputFrontCarPlateTextField.becomeFirstResponder()
                        }
                    }
                } else {
                    let alert = UIAlertController.init(title: "糟糕", message: "\n很抱歉！本系統目前尚未支援此城市，請等之後版本更新有支援後再使用，謝謝！", preferredStyle: .alert)
                    alert.addAction(UIAlertAction.init(title: "確認", style: .default, handler: nil))
                    present(alert, animated: true, completion: nil)
                }
            }
        }
        mapView.deselectAnnotation(mapView.userPinnedAnnotation, animated: true)
    }
}

extension SubmitViewController: FRSAlamofireDelegate {
    func postedResponseSuccess(response: String) {
        
        // ---Testing purpose----
//        var test = ""
//        let path = Bundle.main.path(forResource: "response", ofType: "txt")
//        do {
//            test = try String.init(contentsOfFile: path!, encoding: .utf8)
//        } catch {
//            debugPrint(error)
//        }
//        if let result = Parser().parse(data: test, dataType: .HTML) {
        // ----------------------
            
        if let result = Parser().parse(data: response, dataType: .HTML) {
            obtainedResults = result
            responseViewController?.state = .Success
        } else {
            // Failed to get key-value pair -> already posted
            responseViewController?.state = .Failed
        }
    }
    
    func postedResponseFail(error: Error) {
        // show error
        responseViewController?.state = .FailedConnection
    }
}

extension SubmitViewController: ResponseViewControllerDelegate {
    func userForcedExit(state: ResponseViewState) {
        switch state {
        case .Success:
            let caseFile = CaseStructure(caseID: obtainedResults![ResponseDictKeys.CaseID]!,
                                         serialNumber: obtainedResults![ResponseDictKeys.SerialNumaber]!,
                                         carplateNumber: dataTableViewController!.carplateNumber!,
                                         state: Int16(0),
                                         caseType: dataTableViewController!.userSelectedOption!.rawValue,
                                         capturedDate: dataTableViewController!.time!)
            NotificationCenter.default.post(name: NotificationConstants.NewData, object: caseFile)
            performSegue(withIdentifier: SegueIdentifiers.Unwind, sender: nil)
        case .FailedConnection:
            // release
            responseViewController = nil
            break
        case .Failed:
            // release
            performSegue(withIdentifier: SegueIdentifiers.Unwind, sender: nil)
        default:
            break
        }
        
    }
}









