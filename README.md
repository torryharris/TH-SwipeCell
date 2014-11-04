THSwipeCell
===========

A swift file provides custom swipe table view cell. 

![alt text](https://raw.githubusercontent.com/torryharris/THSwipeCell/master/THSwipeCellDemo.gif "THSwipeCellDemo")

##How to use:

1. Copy [THSwipeCell.swift](https://github.com/torryharris/THSwipeCell/blob/master/THSwipeCell/THSwipeCell.swift) file on your project.
2. Subclass THSwipeCell.
3. Override awakeFromNib and add a subview to cell contentView for the whole boundary and assign it to cellContainerView property, then append buttons(tag as Identifier) to property buttonOptions array list.
4. Add UI components to cellContainerView.
5. Implement THSwipeCellDelegate protocol and confirm the protocol for the custom cell on cellForRowAtIndex method.

### Optional for tap to open buttons

5. Use THSwipeCellTable as your table.
6. Implement didSelectRowAtIndexPath delegate method and call respective method of THSwipeCellTable.

### Optional for disable the multi selection cell

7. Implement scrollViewWillBeginDragging, scrollViewDidScroll and scrollViewDidEndDragging Delegate methods of UIScrollView and call the respective methods in THSwipeCellTable.
8. Call didOpenCell method of THSwipeCellTable inside the didOpenSwipeCell of THSwipeCellDelegate.

##License
THSwipeCell is licensed under the terms of the MIT License. Please see the [License](https://github.com/torryharris/THSwipeCell/blob/master/License) file for full details.
