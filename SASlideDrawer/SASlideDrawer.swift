//
//  SASlideDrawer.swift
//  SASlideDrawer
//
//  Created by Stefan Arambasich on 4/20/2015.
//  Copyright (c) 2015 Stefan Arambasich. All rights reserved.
//

import UIKit

extension UIView {
    /**
        Sets the leading, top, trailing, and bottom constraints with the given amounts
        of this view to its parent view, effectively "pinning" it into its parent.
        Custom offsets are optional; their values default to 0.0.

        Makes calls to `layoutIfNeeded` and `updateConstraints` after adding the constraints.

        :param: leading Leading space (optional).
        :param: top Top space (optional).
        :param: trailing Trailing space (optional).
        :param: bottom Bottom space (optional).
    */
    func pinToParentView(leading: CGFloat = 0.0, top: CGFloat = 0.0, trailing: CGFloat = 0.0, bottom: CGFloat = 0.0) {
        var constraints = [NSLayoutConstraint]()

        constraints.append(NSLayoutConstraint(item: self, attribute: .Top, relatedBy: .Equal, toItem: self.superview, attribute: .Top, multiplier: 1.0, constant: top))
        constraints.append(NSLayoutConstraint(item: self, attribute: .Leading, relatedBy: .Equal, toItem: self.superview, attribute: .Leading, multiplier: 1.0, constant: leading))
        constraints.append(NSLayoutConstraint(item: self, attribute: .Bottom, relatedBy: .Equal, toItem: self.superview, attribute: .Bottom, multiplier: 1.0, constant: bottom))
        constraints.append(NSLayoutConstraint(item: self, attribute: .Trailing, relatedBy: .Equal, toItem: self.superview, attribute: .Trailing, multiplier: 1.0, constant: trailing))

        self.superview?.addConstraints(constraints)
        self.superview?.setNeedsDisplay()
    }
}
