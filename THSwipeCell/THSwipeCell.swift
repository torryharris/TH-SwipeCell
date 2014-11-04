//
//  THSwipeCell.swift
//  THSwipeCell
//
//  Created by Torry Harris on 03/11/14.
//  Copyright (c) 2014 Torry Harris Business Soutions Pvt. Ltd. All rights reserved.
//

import Foundation
import UIKit

/*
    @protocol THSwipeCellDelegate delegate to ViewController for open & close actions and touch up inside action of buttons.
*/
protocol THSwipeCellDelegate {
    func didTappedButton(button:UIButton, forCell swipeableCell:THSwipeCell)
    func didOpenSwipeCell(cell:THSwipeCell)
    func didCloseSwipeCell(cell:THSwipeCell)
}

/*
    @class THSwipeableCell is a base class for swipe and reveal the action objects.

*/
class THSwipeCell: UITableViewCell, UIGestureRecognizerDelegate {
    
    var bounceValue:CGFloat = 20.0
    var buttonOptions: [UIButton] = []
    private var revealedOptions = false
    var cellOpened: Bool { return revealedOptions }
    var tapToOpen: Bool = false
    
    // This is a container for the cell components including three action buttons.
    var cellContainerView: UIView!
    
    // Left and Right constraints of cell container view
    var cellContainerViewRightConstraint: NSLayoutConstraint!
    var cellContainerViewLeftConstraint: NSLayoutConstraint!
    
    var delegate: THSwipeCellDelegate?
    var panGesture : UIPanGestureRecognizer!
    var panStartPoint: CGPoint!
    var startingRightLayoutConstraintConstant: CGFloat = 0
    // @property totalButtonsWidth is a computed property of CGFloat to find the total width of the options
    var totalButtonsWidth: CGFloat {
        var total: CGFloat = 0
        for button in buttonOptions {
            total = total + button.frame.size.width
        }
        return total
    }
    // @property panEnable is a computed property of Bool to find panGesture is enabled or not.
    var panEnable: Bool {
        set {
            panGesture.enabled = newValue
        }
        get {
            return panGesture.enabled
        }
    }
    
    // MARK: Override Methods of UITableViewCell
    override func awakeFromNib() {
        super.awakeFromNib()
        panGesture = UIPanGestureRecognizer(target: self, action: Selector("panThisCell:"))
        panGesture.delegate = self
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetConstraintContstantsToZeroWithAnimation(false, notifyDelegateDidClose: false)
    }
    
    //MARK: Gesture Recognizer Delegate
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //MARK: Button Action
    /*
        @method buttonAction is used to handle the action of touch up inside.
        @param sender is a UIButton component.
    */
    func buttonAction(sender: UIButton) {
        delegate?.didTappedButton(sender, forCell: self)
    }
    
    //MARK: Pan Gesture Action
    /*
        @method panThisCell is used to handle the pan gesture
        @param panGesture is a object of UIPanGestureRecognizer.
    */
    func panThisCell(panGesture:UIPanGestureRecognizer) {
        
        switch panGesture.state {
        case .Began:
            panStartPoint = panGesture.translationInView(cellContainerView)
            startingRightLayoutConstraintConstant = cellContainerViewRightConstraint.constant + totalButtonsWidth
        case .Changed:
            let currentPoint = panGesture.translationInView(cellContainerView)
            let deltaX = currentPoint.x - panStartPoint.x
            var panningLeft = false
            if deltaX < 0 {
                panningLeft = true
            }
            
            if self.startingRightLayoutConstraintConstant == 0 {
                
                if panningLeft {
                    
                    let constant = min(-deltaX, totalButtonsWidth)
                    if constant == totalButtonsWidth {
                        setConstraintsToShowAllButtonsWithAnimation(true, notifyDelegateDidOpen: false)
                    } else {
                        self.cellContainerViewRightConstraint.constant = constant - totalButtonsWidth
                    }
                    
                } else {
                    let constant = max(-deltaX, 0)
                    if constant == 0 {
                        resetConstraintContstantsToZeroWithAnimation(true, notifyDelegateDidClose: false)
                    } else {
                        self.cellContainerViewRightConstraint.constant = constant - totalButtonsWidth
                    }
                }
            } else {
                let adjustment = startingRightLayoutConstraintConstant - deltaX
                let constant = min(adjustment, totalButtonsWidth)
                
                if panningLeft {
                    if constant == totalButtonsWidth {
                        setConstraintsToShowAllButtonsWithAnimation(true, notifyDelegateDidOpen: false)
                    } else {
                        cellContainerViewRightConstraint.constant = -totalButtonsWidth + constant
                    }
                } else {
                    if constant <= 0 {
                        resetConstraintContstantsToZeroWithAnimation(true, notifyDelegateDidClose: false)
                    } else {
                        cellContainerViewRightConstraint.constant = -totalButtonsWidth + constant
                    }
                }
            }
            self.cellContainerViewLeftConstraint.constant = -totalButtonsWidth - cellContainerViewRightConstraint.constant
            
        case .Ended:
            var halfTotal = totalButtonsWidth/2
            if cellContainerViewRightConstraint.constant >= halfTotal - totalButtonsWidth {
                setConstraintsToShowAllButtonsWithAnimation(true, notifyDelegateDidOpen: true)
            } else {
                resetConstraintContstantsToZeroWithAnimation(true, notifyDelegateDidClose: true)
            }
            
        case .Cancelled:
            var halfTotal = totalButtonsWidth/2
            if startingRightLayoutConstraintConstant == 0 && panEnable{
                resetConstraintContstantsToZeroWithAnimation(true, notifyDelegateDidClose: true)
            } else {
                if cellContainerViewRightConstraint.constant >= halfTotal - totalButtonsWidth {
                    setConstraintsToShowAllButtonsWithAnimation(true, notifyDelegateDidOpen: true)
                } else {
                    resetConstraintContstantsToZeroWithAnimation(true, notifyDelegateDidClose: true)
                }
            }
        default:
            break
        }
    }
    
    
    //MARK: Helper Methods
    
    /*
        @method addButton is used to add action button with constraints at the end of the cell container view.
        @param button is a UIButton component.
    */
    func addButton(button:UIButton) {
        
        buttonOptions.append(button)
        cellContainerView.addSubview(button)
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        cellContainerViewRightConstraint.constant = cellContainerViewRightConstraint.constant - button.frame.size.width
        
        let topConstraint = NSLayoutConstraint(item: cellContainerView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: button, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: cellContainerView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: button, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: cellContainerView, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: button, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0 + totalButtonsWidth)
        let widthConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: button.frame.size.width)
        
        cellContainerView.addConstraints([topConstraint, bottomConstraint, trailingConstraint, widthConstraint])
        cellContainerView.layoutIfNeeded()
        
    }
    
    /*
        @method resetConstraintContstantsToZeroWithAnimation is used to reset the cell to closed state.
        @param animate is a Bool value to animate the closing action.
        @param notifyDelegateDidClose is a Bool value to notify the delegate.
    */
    func resetConstraintContstantsToZeroWithAnimation(animate:Bool, notifyDelegateDidClose:Bool) {
        revealedOptions = false
        if notifyDelegateDidClose {
            delegate?.didCloseSwipeCell(self)
        }
        
        if startingRightLayoutConstraintConstant == 0 && cellContainerViewRightConstraint.constant == -totalButtonsWidth {
            return
        }
        
        cellContainerViewRightConstraint.constant = -bounceValue - totalButtonsWidth
        cellContainerViewLeftConstraint.constant = bounceValue
        
        self.updateConstraintsIfNeededWithAnimation(animate, completionHandler: { (finished) -> () in
            self.cellContainerViewRightConstraint.constant = -self.totalButtonsWidth
            self.cellContainerViewLeftConstraint.constant = 0
            
            self.updateConstraintsIfNeededWithAnimation(animate, completionHandler: { (finished) -> () in
                self.startingRightLayoutConstraintConstant = 0
            })
            
        })
    }
    
    /*
        @method setConstraintsToShowAllButtonsWithAnimation is used to open the cell options.
        @param animate is a Bool value to animate the closing action.
        @param notifyDelegateDidOpen is a Bool value to notify the delegate.
    */
    func setConstraintsToShowAllButtonsWithAnimation(animate:Bool, notifyDelegateDidOpen:Bool) {
        revealedOptions = true
        if notifyDelegateDidOpen {
            delegate?.didOpenSwipeCell(self)
        }
        
        if startingRightLayoutConstraintConstant == totalButtonsWidth && cellContainerViewRightConstraint.constant == 0 {
            return
        }
        
        self.cellContainerViewLeftConstraint.constant = -totalButtonsWidth - bounceValue
        self.cellContainerViewRightConstraint.constant = bounceValue
        
        self.updateConstraintsIfNeededWithAnimation(animate, completionHandler: { (finished) -> () in
            self.cellContainerViewLeftConstraint.constant = -self.totalButtonsWidth
            self.cellContainerViewRightConstraint.constant = 0
            
            self.updateConstraintsIfNeededWithAnimation(animate, completionHandler: { (finished) -> () in
                self.startingRightLayoutConstraintConstant = self.totalButtonsWidth
            })
            
        })
        
    }
    
    /*
        @method updateConstraintsIfNeededWithAnimation is used to update the constrains for cell container view.
        @param animation is a Bool value to animate the layout action.
        @param completionHandler is a closure.
    */
    func updateConstraintsIfNeededWithAnimation(animation:Bool, completionHandler: (Bool) -> ()) {
        var duration: Double = 0
        if animation {
            duration = 0.1
        }
        UIView.animateWithDuration(duration, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut , animations: { () -> Void in
            self.layoutIfNeeded()
            }, completion: completionHandler)
    }
    
}

/*
    @class THSwipeCellTable is a base class for swipeCellTable to controll multi cell swipe
    @superClass UITableView

*/
class THSwipeCellTable: UITableView {
    var gestureCancelledCell : THSwipeCell?
    var openedCell: THSwipeCell?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if scrollView === self {
            gestureCancelledCell?.resetConstraintContstantsToZeroWithAnimation(true, notifyDelegateDidClose: false)
            gestureCancelledCell = nil
            openedCell?.resetConstraintContstantsToZeroWithAnimation(true, notifyDelegateDidClose: false)
            openedCell = nil
            let startPoint = scrollView.panGestureRecognizer.locationInView(scrollView)
            let indexPath = self.indexPathForRowAtPoint(startPoint)
            if indexPath != nil {
                let cell = self.cellForRowAtIndexPath(indexPath!) as THSwipeCell
                cell.panEnable = false
                gestureCancelledCell = cell
            }
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView === self {
            gestureCancelledCell?.panEnable = true
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView === self {
            gestureCancelledCell?.panEnable = true
        }
    }
    
    func didOpenCell(swipeCell:THSwipeCell) {
        if swipeCell === openedCell {
            
        } else {
            openedCell?.resetConstraintContstantsToZeroWithAnimation(true, notifyDelegateDidClose: false)
            openedCell = swipeCell
        }
    }
}