//
//  CheckIconView.swift
//  NoMoreParking
//
//  Created by Ray Tso on 3/26/17.
//  Copyright © 2017 Ray Tso. All rights reserved.
//

import UIKit

class CheckIconView: UIView {
    var contentView: UIView?
    
    @IBOutlet weak var checkIconImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    
    private func loadViewFromXib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CheckMask", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    private func setupView() {
        contentView = loadViewFromXib()
        contentView!.frame = bounds
        contentView!.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(contentView!)
    }
    
    func setViewIsToHide(hidden: Bool) {
        UIView.transition(with: self, duration: 0.1, options: .transitionCrossDissolve, animations: {
            self.isHidden = hidden
        }) { (_) in }
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
