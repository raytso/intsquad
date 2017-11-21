//
//  CameraViewController.swift
//  NoMoreParking
//
//  Created by Ray Tso on 9/9/16.
//  Copyright © 2016 Ray Tso. All rights reserved.
//

import UIKit
import CoreLocation

class CameraViewController: UIViewController {

    // MARK: - IBOutlets / IBActions
    
    @IBOutlet weak var cameraFeedView: UIView!
    
    @IBOutlet weak var captureImageButton: UIButton!
    
    @IBOutlet weak var confirmButton: UIButton!
    
    @IBAction func capturePhoto(_ captureImageButton: UIButton) {
        self.capture.captureImage()
    }
    
    // MARK: Unwind Segue
    
    @IBAction func unwindToCameraView(segue: UIStoryboardSegue) { capture.startCameraSession() }
    
    // MARK: - Properties
    
    let shutterView = UIView(frame: UIScreen.main.bounds)
    
    var numberOfOldImages = 0
    
    fileprivate var userSelectedIndicies: [Bool] = []
    
    fileprivate var capture = CameraFeed()
    
    // MARK: - Application Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Camera setup
        capture.delegate = self
        capture.setupCameraSettings(cameraType: .BackCamera, cameraPreviewFrameSize: UIScreen.main.bounds)
        if let preview = capture.previewLayer {
            self.view.layer.insertSublayer(preview, below: cameraFeedView.layer)
        }
        
        // Shutter view setup
        shutterView.backgroundColor = UIColor.black
        shutterView.alpha = 0.0
        self.cameraFeedView.addSubview(shutterView)
        
        // Start camera
        capture.startCameraSession()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        confirmButton.isHidden = (capture.getCapturedImageDataSets()?.isEmpty ?? true) ? true : false
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    // MARK: - Navigation
    
    struct SegueIdentifiers {
        static let ConfirmView = "confirmViewSegueIdentifier"
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.ConfirmView {
            if let destinaitonController = segue.destination as? ConfirmPopoverViewController {
                destinaitonController.cameraFeed = capture
                destinaitonController.delegate = self
                destinaitonController.numberOfOldImages = numberOfOldImages
                destinaitonController.userSelectedIndicies = userSelectedIndicies.isEmpty ? nil : userSelectedIndicies
            }
        }
    }
}

// MARK: - Extensions

extension CameraViewController: ConfirmPopoverViewControllerDelegate {
    func userFinishedSelecting() {
        confirmButton.isHidden = true
        capture.stopCameraSession()
    }
    
    func userAccessCamera(indicies: [Bool]) {
        userSelectedIndicies = indicies
        numberOfOldImages = userSelectedIndicies.count
    }
}

extension CameraViewController: CameraFeedDelegate {
    func finishedRenderingCapture() {
        self.confirmButton.isHidden = false
    }
    
    func startShutterAnimation() {
        DispatchQueue.main.async {
            self.shutterView.alpha = 1.0
            UIView.animate(withDuration: 0.2, animations: {
                self.shutterView.alpha = 0.0
            })
        }
    }
}






