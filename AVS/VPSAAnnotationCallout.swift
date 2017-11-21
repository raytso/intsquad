//
//  VPSAAnnotationCallout.swift
//  NoMoreParking
//
//  Created by Ray Tso on 3/15/17.
//  Copyright © 2017 Ray Tso. All rights reserved.
//

import UIKit
import MapKit

protocol VPSAAnnotationDelegate: class {
    func userDidVerify(selected: Bool)
}

protocol VPSAAnnotationDataSource: class {
    var addressText: String? { get }
}

class VPSAAnnotationCalloutView: UIView {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var confirmButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var addressTextView: UITextView!
    
    // MARK: IBActions
    
    @IBAction func userPressingNo(_ sender: Any) {
        cancelButton.backgroundColor = #colorLiteral(red: 0.9476388097, green: 0.1501389742, blue: 0, alpha: 0.08)
    }
    
    @IBAction func userPressingYes(_ sender: Any) {
        confirmButton.backgroundColor = #colorLiteral(red: 0.02278895304, green: 0.8872261047, blue: 0.02181173675, alpha: 0.08)
    }
    
    @IBAction func clickedYes(_ sender: Any) {
        UIView.animate(withDuration: 0.05, animations: {
            self.confirmButton.backgroundColor = UIColor.clear
        }) { _ in
            self.userChose(button: self.confirmButton)
        }
    }
    
    @IBAction func clickedNo(_ sender: Any) {
        UIView.animate(withDuration: 0.05, animations: {
            self.cancelButton.backgroundColor = UIColor.clear
        }) { _ in
            self.userChose(button: self.cancelButton)
        }
    }
    
    // MARK: - UDFs
    
    private func userChose(button: UIButton) {
        if button == confirmButton {
            annotationDelegate?.userDidVerify(selected: true)
        } else {
            annotationDelegate?.userDidVerify(selected: false)
        }
    }
    
    func updateAddressTextField(succeeded: Bool) {
        if let address = annotationDataSource?.addressText {
            addressTextView.text = succeeded ? address : Constants.Error
        }
        else {
            addressTextView.text = Constants.Waiting
        }
    }
    
    // MARK: - Properties
    
    private var initialSize: CGSize?
    
    private var yesIconView: UIImageView?
    
    private var noIconView: UIImageView?
    
    weak var annotationDelegate: VPSAAnnotationDelegate?
    
    weak var annotationDataSource: VPSAAnnotationDataSource?
    
    struct Constants {
        static let Waiting = "等候網路..."
        static let Error = "司服器錯誤，請稍候再試"
    }
    
    // MARK: - Initialization
    
    private var contentView: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        initialSize = frame.size
        addressTextView.text = Constants.Waiting
        yesIconView = UIImageView(image: #imageLiteral(resourceName: "yes"))
        noIconView = UIImageView(image: #imageLiteral(resourceName: "no"))
        let width = confirmButton.frame.size.width
        let height = confirmButton.frame.size.height
        let length = height * 0.8
        let originX = (width - height) / 2
        let originY = CGFloat(4.0)
        yesIconView?.frame = CGRect(origin: CGPoint(x: originX,
                                                    y: originY),
                                    size: CGSize(width: length,
                                                 height: length))
        noIconView?.frame = CGRect(origin: CGPoint(x: originX,
                                                   y: originY),
                                   size: CGSize(width: length,
                                                height: length))
        confirmButton.insertSubview(yesIconView!, at: 0)
        cancelButton.insertSubview(noIconView!, at: 0)
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func loadViewFromXib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "VPSAAnnotationCalloutView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    private func setupView() {
        contentView = loadViewFromXib()
        guard contentView != nil else { return }
        self.frame.size = contentView!.frame.size
        contentView!.frame.origin = bounds.origin
        contentView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView!)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
