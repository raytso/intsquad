//
//  ConfirmPopoverViewController.swift
//  NoMoreParking
//
//  Created by Ray Tso on 9/20/16.
//  Copyright © 2016 Ray Tso. All rights reserved.
//

import UIKit

protocol CapturedImageDataSource: class {
    func getCapturedImageDataSets() -> [Data]?
    func releaseCapturedImages()
}

protocol ConfirmPopoverViewControllerDelegate: class {
    func userFinishedSelecting()
    func userAccessCamera(indicies: [Bool])
}

class ConfirmPopoverViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    // MARK: - Properties
    
    let promtUserSelectAlert: UIAlertController = {
        let alert = UIAlertController(title: "很抱歉！", message: "請至少選擇一張照片。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確認", style: .default, handler: nil))
        return alert
    }()

    var filesToUpload: [UploadFile]? = []
    
    var cameraFeed: CameraFeed?
    
    var imageCellCenterInset: CGFloat {
        return (imageCollectionView.bounds.width - 300.0) / 2
    }
    
    weak var delegate: ConfirmPopoverViewControllerDelegate?
    
    var blurEffectView: UIVisualEffectView?
    
    var blurEffect: UIBlurEffect?
    
    var userSelectedIndicies: [Bool]?
    
    var numberOfOldImages: Int = 0
    
    private var selectedUIImageSets: [UIImage] = []
    
    private var capturedImageDataSets: [Data]? {
        didSet {
            guard capturedImageDataSets != nil else { return }
            for imageData in capturedImageDataSets! {
                capturedImageUIImageSets!.append(UIImage(data: imageData)!)
            }
            setUserSelectedIndicies()
        }
    }
    
    private var capturedImageUIImageSets: [UIImage]? = []
    
    // MARK: - Outlets
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var returnButton: UIButton!
    
    @IBOutlet weak var selectAllButton: UIButton! {
        didSet {
            selectAllButton.setBackgroundImage(#imageLiteral(resourceName: "check_icon"), for: UIControlState.normal)
            selectAllButton.setBackgroundImage(#imageLiteral(resourceName: "Ring"), for: UIControlState.selected)
        }
    }
    
    @IBOutlet weak var imageCollectionView: UICollectionView! {
        didSet {
            self.imageCollectionView.delegate = self
            self.imageCollectionView.dataSource = self
        }
    }
    
    // MARK: Actions
    
    @IBAction func returnToCamera(_ sender: Any) {
        delegate?.userAccessCamera(indicies: userSelectedIndicies!)
        performSegue(withIdentifier: SegueIdentifiers.BackToCamera, sender: nil)
    }
    
    @IBAction func selectAll() {
        userSelectedIndicies = Array(repeating: selectAllButton.isSelected ? true : false, count: userSelectedIndicies!.count)
        selectAllButton.isSelected = !selectAllButton.isSelected
        updateUI()
    }
    
    // MARK: - CollectionView DataSource
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ConfirmPictureImageSelectionCollecterViewCell
        cell.image = capturedImageUIImageSets?[indexPath.item]
        let isImageSelected = userSelectedIndicies![indexPath.item]
        (cell.checkMask.isHidden, cell.imageSelectedMask.isHidden) = isImageSelected ? (false, true) : (true, false)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return capturedImageDataSets?.count ?? 0
    }
    
    // MARK: - CollectionView Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ConfirmPictureImageSelectionCollecterViewCell
        if (userSelectedIndicies![indexPath.item]) {
            cell.checkMask.setViewIsToHide(hidden: true)
            cell.imageSelectedMask.setViewIsToHide(hidden: false)
            userSelectedIndicies![indexPath.item] = false
        } else {
            cell.checkMask.setViewIsToHide(hidden: false)
            cell.imageSelectedMask.setViewIsToHide(hidden: true)
            userSelectedIndicies![indexPath.item] = true
        }
    }
    
    // MARK: - UDFs
    private func updateUI() {
        self.imageCollectionView.reloadData()
    }
    
    private func setUserSelectedIndicies() {
        guard !capturedImageDataSets!.isEmpty else { return }
        guard userSelectedIndicies == nil else {
            userSelectedIndicies! += Array(repeating: true, count: ((capturedImageDataSets?.count)! - numberOfOldImages))
            return
        }
        userSelectedIndicies = Array(repeating: true, count: capturedImageDataSets!.count)
    }
    
    private func creatingFilesToUpload() {
        for state in userSelectedIndicies!.enumerated() {
            guard state.element else { continue }
            var file = UploadFile()
            file.content = capturedImageDataSets![state.offset]
            file.fileName = "image\(state.offset).jpg"
            file.fileType = UploadFileTypes.Image
            filesToUpload?.append(file)
            selectedUIImageSets.append(capturedImageUIImageSets![state.offset])
        }
    }
    
    private func checkShouldPerformSegue() -> Bool {
        if userDidNotSelectAny() {
            // show alert
            present(promtUserSelectAlert, animated: true, completion: nil)
            return false
        } else {
            creatingFilesToUpload()
            return true
        }
    }
    
    private func userDidNotSelectAny() -> Bool {
        for selectState in userSelectedIndicies! {
            guard !selectState else { return false }
        }
        return true
    }
    
    private func backgroundBlur(effect: UIBlurEffect) {
        blurEffectView?.effect = effect
    }

    
    // MARK: - Application Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // Blur Effect
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            self.view.backgroundColor = UIColor.clear
            blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView?.frame = self.view.bounds
            blurEffectView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.view.insertSubview(blurEffectView!, at: 0)
        } else {
            self.view.backgroundColor = UIColor.black
        }
        
        capturedImageDataSets = cameraFeed?.getCapturedImageDataSets()
        imageCollectionView.contentInset = UIEdgeInsetsMake(-20.0, 0.0, 0.0, 0.0)
        self.automaticallyAdjustsScrollViewInsets = false
        self.imageCollectionView.decelerationRate = UIScrollViewDecelerationRateFast
        
        // Navigation bar
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        navBar.isTranslucent = true
        navBar.backgroundColor = UIColor.clear
//        self.navigationController?.view.backgroundColor = UIColor.clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        filesToUpload = []
        let effect = UIBlurEffect(style: .dark)
        UIView.animate(withDuration: 0.5) {
            self.backgroundBlur(effect: effect)
        }
        updateUI()
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    struct SegueIdentifiers {
        static let SubmitView = "submitViewSegueIdentifier"
        static let BackToCamera = "unwindToCamera"
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == SegueIdentifiers.SubmitView {
            if let controller = segue.destination as? SubmitViewController {
                controller.filesToUpload = filesToUpload
                controller.convertedSelectedImages = selectedUIImageSets
                cameraFeed?.releaseCapturedImages()
                delegate?.userFinishedSelecting()
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == SegueIdentifiers.SubmitView {
            return checkShouldPerformSegue() ? true : false
        } else {
            return true
        }
    }
}



















