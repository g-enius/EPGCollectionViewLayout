//
//  ViewController.swift
//  collectionViewPOC
//
//  Created by Charles on 12/02/20.
//  Copyright © 2020 SKY. All rights reserved.
//

import UIKit

// channel count
let numberOfRows = 20

class ViewController: UIViewController {
    
    //let max event count for each channel
    let numberOfColumns = 10
    
    let itemWidth = CGFloat(300)
    let itemHeight = CGFloat(100)
    

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var initialContentOffset = CGPoint.zero
    private var indexOfCellBeforeDragging = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        (self.collectionView.collectionViewLayout as! LiveRailCollectionViewLayout).delegate = self

        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        self.collectionView.isDirectionalLockEnabled = true
        
        self.collectionView.isPagingEnabled = false
        
        let inset = (UIScreen.main.bounds.width - itemWidth) / 4
        // must set before view will appear as will be called when layout collectionView
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
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
        return numberOfRows * numberOfColumns
    }
   
}

extension ViewController: UICollectionViewDelegate {
   func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       print("did click at \(indexPath)")
   }
}

extension ViewController: LiveRailCollectionViewDelegateLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout: LiveRailCollectionViewLayout,
                        sizeAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemWidth, height: itemHeight)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout: LiveRailCollectionViewLayout,
                        insetsForItemAtIndexPath: IndexPath) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
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
 
    private func indexOfMajorCell() -> Int {
       print("collectionView.contentOffset.x = \(collectionView.contentOffset.x)")

       let proportionalOffset = collectionView.contentOffset.x / itemWidth
       let index = Int(round(proportionalOffset))
       
       print("index = \(index)")
       let numberOfItems = collectionView.numberOfItems(inSection: 0)

       let safeIndex = max(0, min(numberOfItems - 1, index * numberOfRows))
       
       print("safeIndex = \(safeIndex)")

       return safeIndex
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        initialContentOffset = scrollView.contentOffset
        let scrollDirection = determineScrollDirectionAxis(scrollView)
        print("*** scrollViewWillBeginDragging called scrollDirection = \(scrollDirection)")

        if scrollDirection == .horizontal || scrollDirection == .none {
            indexOfCellBeforeDragging = indexOfMajorCell()
        }
    }
       
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print("*** scrollViewDidScroll called")
        let scrollDirection = determineScrollDirectionAxis(scrollView)

        if scrollDirection == .vertical {
//            print("Scrolling direction: vertical \(scrollView.contentOffset)")
        } else if scrollDirection == .horizontal {
//            print("Scrolling direction: horizontal \(scrollView.contentOffset)")
        } else {
            print("Scrolling direction: scrollDirection \(scrollDirection) \(scrollView.contentOffset)")

            var newOffset: CGPoint = CGPoint.zero
            if abs(scrollView.contentOffset.x) > abs(scrollView.contentOffset.y) {
                newOffset = CGPoint.init(x: scrollView.contentOffset.x, y: initialContentOffset.y)
            } else {
                newOffset = CGPoint.init(x: initialContentOffset.x, y: scrollView.contentOffset.y)
            }
            
//             Setting the new offset to the scrollView makes it behave like a proper
//             directional lock, that allows you to scroll in only one direction at any given time            
            var scrollBounds = scrollView.bounds
            scrollBounds.origin = newOffset
            scrollView.bounds = scrollBounds;

            print("*** set content offset \(newOffset)")
        }
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let scrollDirection = determineScrollDirectionAxis(scrollView)
        print("*** scrollViewWillEndDragging called scrollDirection = \(scrollDirection)")

        if scrollDirection == .horizontal || scrollDirection == .none {
            // Stop scrollView sliding:
            targetContentOffset.pointee = scrollView.contentOffset

            // calculate where scrollView should snap to:
            let indexOfMajorCell = self.indexOfMajorCell()

            // calculate conditions:
            let dataSourceCount = collectionView(collectionView!, numberOfItemsInSection: 0)
            
            let swipeVelocityThreshold: CGFloat = 0.5 // after some trail and error
            let hasEnoughVelocityToSlideToTheNextCell = indexOfCellBeforeDragging + numberOfRows < dataSourceCount && velocity.x > swipeVelocityThreshold
            let hasEnoughVelocityToSlideToThePreviousCell = indexOfCellBeforeDragging - numberOfRows >= 0 && velocity.x < -swipeVelocityThreshold
            let majorCellIsTheCellBeforeDragging = indexOfMajorCell == indexOfCellBeforeDragging
            let didUseSwipeToSkipCell = majorCellIsTheCellBeforeDragging && (hasEnoughVelocityToSlideToTheNextCell || hasEnoughVelocityToSlideToThePreviousCell)

            if didUseSwipeToSkipCell {
                print("indexOfCellBeforeDragging = \(indexOfCellBeforeDragging)")
                let snapToIndex = indexOfCellBeforeDragging + (hasEnoughVelocityToSlideToTheNextCell ? numberOfRows : -numberOfRows)
                print("snapToIndex = \(snapToIndex)")

                let toValue = itemWidth * CGFloat(snapToIndex/numberOfRows) - collectionView.contentInset.left
                print("toValue = \(toValue)")

                // Damping equal 1 => no oscillations => decay animation:
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: velocity.x, options: .allowUserInteraction, animations: {
                    scrollView.contentOffset = CGPoint(x: toValue, y: 0)
                    scrollView.layoutIfNeeded()
                }, completion: nil)

            } else {
                // This is a much better way to scroll to a cell:
                let indexPath = IndexPath(row: indexOfMajorCell, section: 0)
                print("scrollToItem \(indexPath)")

                collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            }
        }
    }
}

