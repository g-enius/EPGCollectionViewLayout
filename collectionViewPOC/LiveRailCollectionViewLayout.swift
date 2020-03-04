//
//  LiveRailCollectionViewLayout.swift
//  collectionViewPOC
//
//  Created by Charles on 13/02/20.
//  Copyright © 2020 SKY. All rights reserved.
//

import UIKit

protocol LiveRailCollectionViewDelegateLayout: class {
    func collectionView(_ collectionView: UICollectionView,
                        layout: LiveRailCollectionViewLayout,
                        sizeAtIndexPath indexPath: IndexPath) -> CGSize
    
    func collectionView(_ collectionView: UICollectionView,
                        layout: LiveRailCollectionViewLayout,
                        insetsForItemAtIndexPath: IndexPath) -> UIEdgeInsets
}

class LiveRailCollectionViewLayout: UICollectionViewLayout {

    // 1. cachedAttributes
    /// This is to store the calculated UICollectionViewLayoutAtributes
    private var cachedAttributes: [UICollectionViewLayoutAttributes] = []
    
    weak var delegate: LiveRailCollectionViewDelegateLayout?
    
    // 2. contentWidth
    private var contentHeight: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        
        return (itemSize.height + itemInset.top + itemInset.bottom) * CGFloat(numberOfRows) + collectionView.contentInset.top + collectionView.contentInset.bottom
    }
    
    // 3. This will be calculated in Prepare()
    private var contentWidth: CGFloat = 0
    
    private var itemSize: CGSize {
        // 4. If the delegate is empty, we have a default size of (40, 40)
        guard let collectionView = collectionView else {
            return CGSize(width: 40, height: 40)
        }
        
        let indexPath = IndexPath(row: 0, section: 0)
        return delegate?.collectionView(collectionView, layout: self, sizeAtIndexPath: indexPath) ?? CGSize(width: 40, height: 40)
    }
    
    
    private var itemInset: UIEdgeInsets {
        guard let collectionView = collectionView else {
            return UIEdgeInsets.zero
        }
        
        // 5. item insets
        let indexPath = IndexPath(row: 0, section: 0)
        return delegate?.collectionView(collectionView, layout: self, insetsForItemAtIndexPath: indexPath) ?? UIEdgeInsets.zero
    }
    // 4. ContentSize of collectionView
    // we just return the size that compirses of contentHeight and contentWidth
    // this property will be called after Prepare()
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        // We don't need to call super
        
        guard let collectionView = collectionView else {
            return
        }
        
        // 1. Clear the Cache
        cachedAttributes.removeAll()
        
        // 2. Set the origin
        var xOrigin: CGFloat = collectionView.contentInset.left
        var yOrigin: CGFloat = collectionView.contentInset.top
        
        // 3. Here, we assume that we have only one section
        // you can handle multiple section like
        // for section in 0..< collectionView.numberOfSections {}
        
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)

            // 6. If adding another row will be exceeding the height of the collectionView's content, we go right to a new column
            if yOrigin + itemSize.height + itemInset.bottom > contentHeight {
                yOrigin = collectionView.contentInset.top
                xOrigin += itemSize.width + itemInset.left + itemInset.right
            }
            
            let frame = CGRect(x: xOrigin + itemInset.left, y: yOrigin + itemInset.top, width: itemSize.width, height: itemSize.height)
            
            // 7. After creating a new frame, we update the new origin
            yOrigin += itemSize.height + itemInset.top + itemInset.bottom
            
            // 8. We create the UICollectionViewLayoutAttributes and set its frame
            let attributes = UICollectionViewLayoutAttributes.init(forCellWith: indexPath)
            attributes.frame = frame
            
            // 9. Store the attributes in cache
            cachedAttributes.append(attributes)
            
            // 10. update the contentWidth
            contentWidth = max(contentWidth, xOrigin + itemSize.width + collectionView.contentInset.right)
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cachedAttributes
    }
}
