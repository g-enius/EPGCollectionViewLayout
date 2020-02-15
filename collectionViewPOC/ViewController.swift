//
//  ViewController.swift
//  collectionViewPOC
//
//  Created by Charles on 12/02/20.
//  Copyright © 2020 SKY. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.dataSource = self
        (self.collectionView.collectionViewLayout as! LiveRailCollectionViewLayout).delegate = self
        
        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.layer.borderColor = UIColor.red.cgColor
        cell.layer.borderWidth = 1
        
        var label = cell.viewWithTag(1005) as! UILabel?
        if label == nil {
            label = UILabel(frame: CGRect.init(x: 43, y: 37, width: 30, height: 30))
            label!.tag = 1005
            cell.addSubview(label!)
        }
        
        label!.text = "\(indexPath.item)"
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 50
    }
}

extension ViewController: LiveRailCollectionViewDelegateLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout: LiveRailCollectionViewLayout,
                        sizeAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout: LiveRailCollectionViewLayout,
                        insetsForItemAtIndexPath: IndexPath) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }

}

