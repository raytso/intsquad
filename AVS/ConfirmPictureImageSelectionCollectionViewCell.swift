//
//  ConfirmPictureCollectionViewCell.swift
//  NoMoreParking
//
//  Created by Ray Tso on 2/23/17.
//  Copyright © 2017 Ray Tso. All rights reserved.
//

import UIKit

class ConfirmPictureImageSelectionCollecterViewCell: UICollectionViewCell {
    
    // MARK: - Variables
    
    var image: UIImage! {
        didSet {
            updateUI()
        }
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var capturedImageShots: UIImageView!
    
    @IBOutlet weak var imageSelectedMask: SelectedMaskView!
    
    @IBOutlet weak var checkMask: CheckIconView!
    
    // MARK: - UDFs
    
    private func updateUI() {
        capturedImageShots.image = image
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.7
        self.layer.shadowRadius = 4.0
        self.layer.shadowOffset = CGSize(width: 0.0, height: 8.0)
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
    }
}
