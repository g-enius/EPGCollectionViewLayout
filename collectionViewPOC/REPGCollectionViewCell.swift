//
//  EPGCollectionViewCell.swift
//  SkyConrad
//
//  Created by Charles on 6/03/20.
//  Copyright © 2020 Sky TV. All rights reserved.
//

import UIKit

class EPGCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    func config(with event: Int) {
        let maskPath = UIBezierPath.init(roundedRect: self.bounds,
                                         byRoundingCorners:.allCorners,
                                         cornerRadii: .init(width: 15, height: 15))
        titleLabel.text = "Event \(event)"
        let shape = CAShapeLayer.init()
        shape.path = maskPath.cgPath
        self.layer.mask = shape // must be self rather than self.contentView
        
    }
}
