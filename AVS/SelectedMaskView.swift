//
//  ImageDidSelectMask.swift
//  NoMoreParking
//
//  Created by Ray Tso on 3/1/17.
//  Copyright © 2017 Ray Tso. All rights reserved.
//

import UIKit

class SelectedMaskView: UIView {
    
    // MARK: - Properties
    
    var contentView: UIView?
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var checkIconImageView: UIImageView!
    
    @IBOutlet weak var backgroundView: UIView!
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setViewIsToHide(hidden: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func loadViewFromXib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "SelectedMaskView", bundle: bundle)
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
}
