//
//  EPGViewController.swift
//  SkyConrad
//
//  Created by Charles on 5/03/20.
//  Copyright © 2020 Sky TV. All rights reserved.
//

import UIKit

class EPGViewController: UIViewController {
    @IBOutlet weak var gridCollectionView: UICollectionView!
    @IBOutlet weak var channelCollectionView: UICollectionView!
    
    private var channels: [Int]!
    private var numberOfRows: Int!
    private var dataSource: [Int]!
    private var currentBaseIndex: Int!
    private let itemWidth = CGFloat(246)
    private let itemHeight = CGFloat(100)
    
    @IBOutlet weak var channelCollectionViewWidthConstraint: NSLayoutConstraint!
        
    private var initialContentOffset = CGPoint.zero
    private var indexOfCellBeforeDragging = 0
    
    @objc static func storyboardInstance() -> EPGViewController? {
       let storyboard = UIStoryboard(name:
           "EPGViewController", bundle: nil)
       let vc = storyboard.instantiateViewController(withIdentifier: "EPGViewController") as? EPGViewController
       return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //mock data
        numberOfRows = 51
        channels = []
        for i in 0..<numberOfRows {
            channels.append(i)
        }
        
        currentBaseIndex = 1
        
        dataSource = []
        for i in 0..<numberOfRows * 10 {
            dataSource.append(i)
        }

        gridCollectionView.dataSource = self
        gridCollectionView.delegate = self
        (gridCollectionView.collectionViewLayout as! EPGCollectionViewLayout).delegate = self
        (gridCollectionView.collectionViewLayout as! EPGCollectionViewLayout).numberOfRows = numberOfRows
        gridCollectionView.isDirectionalLockEnabled = true
        gridCollectionView.isPagingEnabled = false
        let inset = (UIScreen.main.bounds.width - itemWidth) / 2
        // must set before view will appear as will be called when layout collectionView
        initialContentOffset = CGPoint(x: -inset, y: 0)
        
        gridCollectionView.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        
        channelCollectionView.dataSource = self
        channelCollectionView.delegate = self
        let flowLayoutForChannelCollectionView = (channelCollectionView.collectionViewLayout as! UICollectionViewFlowLayout)
        //without this size will be default 50
        flowLayoutForChannelCollectionView.itemSize = CGSize(width: channelCollectionViewWidthConstraint.constant, height: channelCollectionViewWidthConstraint.constant)
        flowLayoutForChannelCollectionView.minimumInteritemSpacing = 0
        let channelCollectionViewCenterOffset = itemHeight / 2 - channelCollectionViewWidthConstraint.constant / 2
        flowLayoutForChannelCollectionView.minimumLineSpacing = channelCollectionViewCenterOffset * 2
        
        channelCollectionView.showsVerticalScrollIndicator = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        gridCollectionView.scrollToItem(at: IndexPath(row: currentBaseIndex * numberOfRows, section: 0), at: .centeredHorizontally, animated: animated)
    }
}

extension EPGViewController: UICollectionViewDataSource {
 
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == channelCollectionView {
            return channels.count
        }
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == channelCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EPGChannelLogoCell", for: indexPath) as! EPGChannelLogoCell
            cell.config(with: channels[indexPath.item])

            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EPGCollectionViewCell", for: indexPath) as! EPGCollectionViewCell
        cell.config(with: dataSource[indexPath.item])
        
        return cell
    }
}

extension EPGViewController: UICollectionViewDelegateFlowLayout {
    //without this size would be 54
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 64, height: 64)
    }
}

extension EPGViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}

extension EPGViewController: EPGCollectionViewDelegateLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout: EPGCollectionViewLayout,
                        sizeAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemWidth, height: itemHeight)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout: EPGCollectionViewLayout,
                        insetsForItemAtIndexPath: IndexPath) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
}

extension EPGViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        initialContentOffset = gridCollectionView.contentOffset
        
        let scrollDirection = determineScrollDirectionAxis(gridCollectionView)
        if scrollDirection == .horizontal || scrollDirection == .none {
            indexOfCellBeforeDragging = indexOfMajorCell()
        }
    }
           
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == gridCollectionView {
            let scrollDirection = determineScrollDirectionAxis(scrollView)

            if scrollDirection == .vertical {
                channelCollectionView.contentOffset = CGPoint(x: channelCollectionView.contentOffset.x, y: scrollView.contentOffset.y)
            } else if scrollDirection == .diagonal {
                var newOffset: CGPoint = CGPoint.zero
                if abs(scrollView.contentOffset.x) > abs(scrollView.contentOffset.y) {
                    newOffset = CGPoint.init(x: scrollView.contentOffset.x, y: initialContentOffset.y)
                } else {
                    newOffset = CGPoint.init(x: initialContentOffset.x, y: scrollView.contentOffset.y)
                }

                scrollView.contentOffset = newOffset
                channelCollectionView.contentOffset = CGPoint(x: channelCollectionView.contentOffset.x, y: newOffset.y)
            }
        } else {
            gridCollectionView.contentOffset = CGPoint(x: gridCollectionView.contentOffset.x, y: scrollView.contentOffset.y)
        }
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard scrollView == gridCollectionView else {
            return
        }
        
        let scrollDirection = determineScrollDirectionAxis(scrollView)
        if scrollDirection == .horizontal || scrollDirection == .none {
            // Stop scrollView sliding:
            targetContentOffset.pointee = scrollView.contentOffset

            // calculate where scrollView should snap to:
            let indexOfMajorCell = self.indexOfMajorCell()

            // calculate conditions:
            let dataSourceCount = collectionView(gridCollectionView!, numberOfItemsInSection: 0)
            
            let swipeVelocityThreshold: CGFloat = 0.5 // after some trail and error
            
            let hasEnoughVelocityToSlideToTheNextCell = indexOfCellBeforeDragging + numberOfRows < dataSourceCount && velocity.x > swipeVelocityThreshold
            let hasEnoughVelocityToSlideToThePreviousCell = indexOfCellBeforeDragging - numberOfRows >= 0 && velocity.x < -swipeVelocityThreshold
            let majorCellIsTheCellBeforeDragging = indexOfMajorCell == indexOfCellBeforeDragging
            let didUseSwipeToSkipCell = majorCellIsTheCellBeforeDragging && (hasEnoughVelocityToSlideToTheNextCell || hasEnoughVelocityToSlideToThePreviousCell)

            if didUseSwipeToSkipCell {
                let snapToIndex = indexOfCellBeforeDragging + (hasEnoughVelocityToSlideToTheNextCell ? numberOfRows : -numberOfRows)
                let toValue = itemWidth * CGFloat(snapToIndex/numberOfRows) - gridCollectionView.contentInset.left

                // Damping equal 1 => no oscillations => decay animation:
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: velocity.x, options: .allowUserInteraction, animations: {
                    scrollView.contentOffset = CGPoint(x: toValue, y: 0)
                    scrollView.layoutIfNeeded()
                }, completion: nil)
            } else {
                // This is a much better way to scroll to a cell:
                let indexPath = IndexPath(row: indexOfMajorCell, section: 0)
                scrollView.isUserInteractionEnabled = false
                self.gridCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                    scrollView.isUserInteractionEnabled = true
                })
            }
        }
    }
    
    private enum ScrollDirection : Int {
        case none
        case diagonal
        case horizontal
        case vertical
    }
    
    private func determineScrollDirectionAxis(_ scrollView: UIScrollView) -> ScrollDirection {
        let threshold = CGFloat(0.5)
        if abs(initialContentOffset.x - scrollView.contentOffset.x) > threshold && abs(initialContentOffset.y - scrollView.contentOffset.y) > threshold {
            return .diagonal
        } else if abs(initialContentOffset.x - scrollView.contentOffset.x) > threshold {
            return .horizontal
        } else if abs(initialContentOffset.y - scrollView.contentOffset.y) > threshold {
            return .vertical
        } else {
            return .none
        }
    }
 
    private func indexOfMajorCell() -> Int {
        let proportionalOffset = gridCollectionView.contentOffset.x / itemWidth
        let index = Int(round(proportionalOffset))
        let numberOfItems = gridCollectionView.numberOfItems(inSection: 0)
        let safeIndex = max(0, min(numberOfItems - 1, index * numberOfRows))
        return safeIndex
    }
}
