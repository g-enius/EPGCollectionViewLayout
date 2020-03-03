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
    
    private var initialContentOffset = CGPoint.zero
    private var indexOfCellBeforeDragging = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        (self.collectionView.collectionViewLayout as! LiveRailCollectionViewLayout).delegate = self
//        (self.collectionView.collectionViewLayout as! YourCollectionLayoutSubclass).scrollDirection = .horizontal

        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        self.collectionView.isDirectionalLockEnabled = true
        
        self.collectionView.isPagingEnabled = false
        
//        self.collectionView.alwaysBounceHorizontal = false
//        self.collectionView.alwaysBounceVertical = false
//        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        self.collectionView.contentOffset = CGPoint.init(x: 260, y: 0)
    }
    


    private func indexOfMajorCell() -> Int {
        let itemWidth = CGFloat(300)
        print("collectionView.contentOffset.x = \(collectionView.contentOffset.x)")
        let proportionalOffset = collectionView.contentOffset.x / itemWidth
        let index = Int(round(proportionalOffset))
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        let safeIndex = max(0, min(numberOfItems - 1, index))
        return safeIndex
    }
}



extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath)
        cell.layer.borderColor = UIColor.red.cgColor
        cell.layer.borderWidth = 1
        
        var label = cell.viewWithTag(1005) as! UILabel?
        if label == nil {
            label = UILabel(frame: CGRect.init(x: 10, y: 10, width: 30, height: 30))
            label!.tag = 1005
            cell.addSubview(label!)
        }
        
        label!.text = "\(indexPath.item)"
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 150
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 300, height: 100)
    }
}

extension ViewController: LiveRailCollectionViewDelegateLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout: LiveRailCollectionViewLayout,
                        sizeAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: 300, height: 100)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout: LiveRailCollectionViewLayout,
                        insetsForItemAtIndexPath: IndexPath) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }

}

extension ViewController: UIScrollViewDelegate {
   
    enum ScrollDirection : Int {
        case none
        case diagonal
        case left
        case right
        case up
        case down
        case horizontal
        case vertical
    }
    
    func determineScrollDirection(_ scrollView: UIScrollView) -> ScrollDirection {
        var scrollDirection: ScrollDirection

        // If the scrolling direction is changed on both X and Y it means the
        // scrolling started in one corner and goes diagonal. This will be
        // called ScrollDirectionCrazy

        if initialContentOffset.x != scrollView.contentOffset.x && initialContentOffset.y != scrollView.contentOffset.y {
            scrollDirection = .diagonal
        } else {
            if initialContentOffset.x > (scrollView.contentOffset.x) {
                scrollDirection = .left
            } else if initialContentOffset.x < (scrollView.contentOffset.x) {
                scrollDirection = .right
            } else if initialContentOffset.y > (scrollView.contentOffset.y) {
                scrollDirection = .up
            } else if initialContentOffset.y < (scrollView.contentOffset.y) {
                scrollDirection = .down
            } else {
                scrollDirection = .none
            }
        }

        return scrollDirection
    }

    func determineScrollDirectionAxis(_ scrollView: UIScrollView) -> ScrollDirection {
        let scrollDirection = determineScrollDirection(scrollView)

        switch scrollDirection {
        case .left, .right:
            return .horizontal
        case .up, .down:
            return .vertical
        default:
            return .none
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        initialContentOffset = scrollView.contentOffset
        
        indexOfCellBeforeDragging = indexOfMajorCell()

    }
       
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

    }


    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        print("*** scrollViewDidScroll called")
//        let scrollDirection = determineScrollDirectionAxis(scrollView)
//
//        if scrollDirection == .vertical {
////            print("Scrolling direction: vertical")
//        } else if scrollDirection == .horizontal {
////            print("Scrolling direction: horizontal")
//

            // Stop scrollView sliding:
            targetContentOffset.pointee = scrollView.contentOffset

            // calculate where scrollView should snap to:
            let indexOfMajorCell = self.indexOfMajorCell()

            // calculate conditions:
            let dataSourceCount = collectionView(collectionView!, numberOfItemsInSection: 0)
            let swipeVelocityThreshold: CGFloat = 0.5 // after some trail and error
            let hasEnoughVelocityToSlideToTheNextCell = indexOfCellBeforeDragging + 1 < dataSourceCount && velocity.x > swipeVelocityThreshold
            let hasEnoughVelocityToSlideToThePreviousCell = indexOfCellBeforeDragging - 1 >= 0 && velocity.x < -swipeVelocityThreshold
            let majorCellIsTheCellBeforeDragging = indexOfMajorCell == indexOfCellBeforeDragging
            let didUseSwipeToSkipCell = majorCellIsTheCellBeforeDragging && (hasEnoughVelocityToSlideToTheNextCell || hasEnoughVelocityToSlideToThePreviousCell)

            if didUseSwipeToSkipCell {

                let snapToIndex = indexOfCellBeforeDragging + (hasEnoughVelocityToSlideToTheNextCell ? 1 : -1)
                let toValue = CGFloat(300) * CGFloat(snapToIndex)

                // Damping equal 1 => no oscillations => decay animation:
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: velocity.x, options: .allowUserInteraction, animations: {
                    scrollView.contentOffset = CGPoint(x: toValue, y: 0)
                    scrollView.layoutIfNeeded()
                }, completion: nil)

            } else {
                // This is a much better way to scroll to a cell:
                let indexPath = IndexPath(row: indexOfMajorCell, section: 0)
                collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            }
            
            
            
//        } else {
//            var newOffset: CGPoint = CGPoint.zero
//            if abs(scrollView.contentOffset.x) > abs(scrollView.contentOffset.y) {
//                newOffset = CGPoint.init(x: scrollView.contentOffset.x, y: initialContentOffset.y)
//
//            } else {
//                newOffset = CGPoint.init(x: initialContentOffset.x, y: scrollView.contentOffset.y)
//            }
            
            // Setting the new offset to the scrollView makes it behave like a proper
            // directional lock, that allows you to scroll in only one direction at any given time
//            scrollView.contentOffset = newOffset
//            print("*** set content offset")
//        }
        
           
       }
}

