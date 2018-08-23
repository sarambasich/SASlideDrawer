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

        constraints.append(NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: self.superview, attribute: .top, multiplier: 1.0, constant: top))
        constraints.append(NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: self.superview, attribute: .leading, multiplier: 1.0, constant: leading))
        constraints.append(NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: self.superview, attribute: .bottom, multiplier: 1.0, constant: bottom))
        constraints.append(NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: self.superview, attribute: .trailing, multiplier: 1.0, constant: trailing))

        self.superview?.addConstraints(constraints)
        self.superview?.setNeedsDisplay()
    }
}
