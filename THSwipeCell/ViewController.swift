//
//  ViewController.swift
//  THSwipeCell
//
//  Created by Torry Harris on 03/11/14.
//  Copyright (c) 2014 Torry Harris Business Soutions Pvt. Ltd. All rights reserved.
//

import UIKit

/*
    @class DemoSwipeCell is a custom cell for Demo swipeCellTable.
    @superclass THSwipeCell.
    It has the feature to swipe and reveal the option.
*/
class DemoSwipeCell: THSwipeCell {
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellName: UILabel!
    
    // For container view
    @IBOutlet weak var cellOutletContainerView: UIView!
    
    // Left and Right constraints of cell container view
    @IBOutlet weak var cellOutletContainerViewRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cellOutletContainerViewLeftConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // set true for the variable tapToOpen if the cell wants to reveal the options when tap on the cell.
        tapToOpen = true
        
        cellContainerView = cellOutletContainerView
        cellContainerView.addGestureRecognizer(panGesture)
        self.backgroundColor = UIColor.clearColor()
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
        cellContainerViewRightConstraint = cellOutletContainerViewRightConstraint
        cellContainerViewLeftConstraint = cellOutletContainerViewLeftConstraint
        
        /*  Custom buttons
            Here we can add buttons through code.
            Note:   1) Buttons are added from right to left
                    2) Button width only taken care and remining constraints are added dynamically.
                    3) Use the button tag numbers for identification.
        */
        let deleteButton = UIButton(frame: CGRectMake(0, 0, 60, 40))
        deleteButton.backgroundColor = UIColor.redColor()
        deleteButton.tag = 101
        deleteButton.addTarget(self, action: Selector("buttonAction:"), forControlEvents: UIControlEvents.TouchUpInside)
        deleteButton.setImage(UIImage(named: "Delete.png"), forState: UIControlState.Normal)
        deleteButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        deleteButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Highlighted)
        addButton(deleteButton)
        
        let insertBelowButton = UIButton(frame: CGRectMake(0, 0, 70, 40))
        insertBelowButton.backgroundColor = UIColor.greenColor()
        insertBelowButton.tag = 102
        insertBelowButton.addTarget(self, action: Selector("buttonAction:"), forControlEvents: UIControlEvents.TouchUpInside)
        insertBelowButton.setTitle("INSERT", forState: UIControlState.Normal)
        insertBelowButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
        insertBelowButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        insertBelowButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Highlighted)
        addButton(insertBelowButton)
        
        let closeButton = UIButton(frame: CGRectMake(0, 0, 60, 40))
        closeButton.backgroundColor = UIColor.lightGrayColor()
        closeButton.tag = 103
        closeButton.addTarget(self, action: Selector("buttonAction:"), forControlEvents: UIControlEvents.TouchUpInside)
        closeButton.setTitle("CLOSE", forState: UIControlState.Normal)
        closeButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
        closeButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        closeButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Highlighted)
        addButton(closeButton)
        
        // We can add more buttons.
        
    }
    
}

/*
    This is a  @ViewController to demo the swipe cell with the use of UITableView.

*/
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, THSwipeCellDelegate {

    /* 
        If tableView requires to disable multiple swipe, It should be subclass of THSwipeCellTable.
        And also implement some of the delegate methods of scroll view : check below implemented scrollView methods.
    */
    @IBOutlet weak var swipeCellTable: THSwipeCellTable!
    
    // MARK: ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        swipeCellTable.delegate = self
        swipeCellTable.dataSource = self
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: TableView DataSource Methods
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let swipeCellIdentifier = "SwipeCell"
        var swipeCell = swipeCellTable.dequeueReusableCellWithIdentifier(swipeCellIdentifier, forIndexPath: indexPath) as DemoSwipeCell
        // confirm the THSwipeCellDelegate
        swipeCell.delegate = self
        // Override the content
        swipeCell.cellName.text = "Row number = \(indexPath.row+1)"
        return swipeCell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 25;
    }
    
    // MARK: TableView Delegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        swipeCellTable.tableView(tableView, didSelectRowAtIndexPath: indexPath)
    }
    
    // MARK: THSwipeCellDelegate Methods
    func didTappedButton(button:UIButton, forCell swipeableCell:THSwipeCell) {
        let indexPath = swipeCellTable.indexPathForCell(swipeableCell)
        switch button.tag {
        case 101:
            println("Delete button tapped on Row No \(indexPath!.row + 1)")
        case 102:
            println("Insert button tapped on Row No \(indexPath!.row + 1)")
        case 103:
            swipeableCell.resetConstraintContstantsToZeroWithAnimation(true, notifyDelegateDidClose: true)
        default:
            println("Default(Unknown) button tapped")
        }
    }
    func didOpenSwipeCell(cell:THSwipeCell) {
        swipeCellTable.didOpenCell(cell)
    }
    func didCloseSwipeCell(cell:THSwipeCell) {
        
    }
    
    // MARK: ScrollView Delegate methods
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        swipeCellTable.scrollViewWillBeginDragging(scrollView)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        swipeCellTable.scrollViewDidScroll(scrollView)
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        swipeCellTable.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
    }
    
    
}

