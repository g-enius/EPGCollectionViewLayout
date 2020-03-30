//
//  EPGChannelLogoCell.swift
//  SkyConrad
//
//  Created by Charles on 9/03/20.
//  Copyright © 2020 Sky TV. All rights reserved.
//

import UIKit

class EPGChannelLogoCell: UICollectionViewCell {

    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var channelNumberLabel: UILabel!
    
    func config(with channel: Int) {
        channelNumberLabel.text = "Ch \(channel)"
        layer.cornerRadius = 32
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 4
    }
}
