//
//  SelectedImagesCollectionViewCell.swift
//  NoMoreParking
//
//  Created by Ray Tso on 3/10/17.
//  Copyright © 2017 Ray Tso. All rights reserved.
//

import UIKit

class SelectedImagesCollectionViewCell: UICollectionViewCell {
    
    var image: UIImage? {
        didSet {
            updateUI()
        }
    }
    
    @IBOutlet weak var cellImage: UIImageView!
    
    private func updateUI() {
        cellImage.image = image
    }
    
}
