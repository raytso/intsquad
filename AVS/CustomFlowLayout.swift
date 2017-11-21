//
//  CustomFlowLayout.swift
//  NoMoreParking
//
//  Created by Ray Tso on 3/3/17.
//  Copyright © 2017 Ray Tso. All rights reserved.
//

import UIKit

class CustomFlowLayout: UICollectionViewFlowLayout, UIScrollViewDelegate {
    private var pageWidth: CGFloat {
        return self.itemSize.width + self.minimumLineSpacing
    }
    
    private var imageCellCenterInset: CGFloat {
        return (UIScreen.main.bounds.width - (self.itemSize.width)) / 2
    }
    
    private let flickVelocity: CGFloat = 0.3
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let rawPageValue = self.collectionView!.contentOffset.x / self.pageWidth
        let currentPage = (velocity.x > 0.0) ? floor(rawPageValue) : ceil(rawPageValue)
        let nextPage = (velocity.x > 0.0) ? ceil(rawPageValue) : floor(rawPageValue)
        
        let pannedLessThanAPage = (fabs(1 + currentPage - rawPageValue) > 0.5)
        let flicked = (fabs(velocity.x) > flickVelocity)
        let proposedContentOffsetXValue = ((pannedLessThanAPage && flicked) ? nextPage : round(rawPageValue)) * pageWidth
        return CGPoint(x: proposedContentOffsetXValue, y: proposedContentOffset.y)
    }
    
    override func awakeFromNib() {
//        super.awakeFromNib()
        let customWidth = self.collectionView!.bounds.width * (0.7)
        let customHeight = customWidth * 1.6
        self.itemSize = CGSize(width: customWidth, height: customHeight)
        self.minimumInteritemSpacing = 10.0
        self.minimumLineSpacing = 24.0
        self.scrollDirection = UICollectionViewScrollDirection.horizontal
        self.sectionInset = UIEdgeInsetsMake(0.0, imageCellCenterInset, 0.0, imageCellCenterInset);        
    }
}
