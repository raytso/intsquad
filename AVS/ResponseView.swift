//
//  ResponseView.swift
//  
//
//  Created by Ray Tso on 3/20/17.
//
//

import UIKit

protocol ResponseViewDelegate: class {
    func userDismissedView()
}

class ResponseView: UIView {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var statusImageView: UIImageView!
    
    @IBOutlet weak var statusTextLabel: UILabel!
    
    @IBOutlet weak var statusDetailsTextLabel: UILabel!
    
    @IBOutlet weak var cancelButton: UIButton! {
        didSet { cancelButton.isHidden = true }
    }
    
    @IBOutlet weak var spinningIndicator: UIActivityIndicatorView! {
        didSet {
            spinningIndicator.hidesWhenStopped = true
            spinningIndicator.startAnimating()
        }
    }
    
    @IBAction func returnToSubmitForm(_ sender: UIButton) {
        delegate?.userDismissedView()
    }
    
    // MARK: - Properties
    
    var contentView: UIView?
    
    var blurEffectView: UIVisualEffectView?
    
    var blurEffect: UIBlurEffect?
    
    weak var delegate: ResponseViewDelegate?
    
    // MARK - UDFs
    
    func updateView(text: String, detailsText: String, image: UIImage) {
        statusTextLabel.text = text
        statusDetailsTextLabel.text = detailsText
        statusImageView.image = image
    }
    
    func hideButton(toHide: Bool) {
        cancelButton.isHidden = toHide
    }
    
    // MARK - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // Add blur effect
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            self.backgroundColor = UIColor.clear
            blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView?.frame = self.bounds
            blurEffectView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.insertSubview(blurEffectView!, at: 0)
        }
        setupView()
    }
    
    private func loadViewFromXib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "ResponseView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    private func setupView() {
        contentView = loadViewFromXib()
        contentView!.frame = bounds
        contentView!.autoresizingMask = [UIViewAutoresizing.flexibleWidth,
                                         UIViewAutoresizing.flexibleHeight]
        addSubview(contentView!)
    }
    
    func backgroundBlur(effect: UIBlurEffect) {
        blurEffectView?.effect = effect
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
