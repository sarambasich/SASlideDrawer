//
//  SASlideDrawerViewController.swift
//  SASlideDrawer
//
//  Created by Stefan Arambasich on 4/12/2015.
//  Copyright (c) 2015 Stefan Arambasich. All rights reserved.
//

import UIKit

/**
    Names of events posted to `NSNotificationCenter` in response to menu
    status changes.
*/
public struct Events {
    /// Event posted when the drawer will open
    public static let DrawerWillOpen = "DrawerWillOpen"
    /// Event posted when the drawer did open
    public static let DrawerDidOpen = "DrawerDidOpen"
    /// Event posted when the drawer will close
    public static let DrawerWillClose = "DrawerWillClose"
    /// Event posted when the drawer did close
    public static let DrawerDidClose = "DrawerDidClose"
}


/**
    Describes the direction from which the drawer appears.
*/
public enum SASlideDrawerDirection: Int {
    /// The drawer appears from the top and slides down
    case Top
    /// The drawer appears from the bottom and slides up
    case Bottom
    /// The drawer appears from the left and slides right
    case Left
    /// The drawer appears from the right and slides left
    case Right
}

/**
    The current state of the drawer.
*/
public enum SASlideDrawerState: Int {
    /// The drawer is opened
    case Open
    /// The drawer is closed
    case Closed
}


/**
    Describes a view controller that contains a sliding drawer from one direction.

    Example uses:
        - Side / navigation menu
        - Detail views
        - Pull down / out views
*/
public class SASlideDrawerViewController: UIViewController {
    /// The default size of the drawer
    public static let DefaultDrawerSize: CGFloat = 220.0
    /// The default slide duration of the drawer
    public static let DefaultSlideDuration: NSTimeInterval = 0.35
    
    /// The content view controller - the view controller that is the main focus
    public var contentViewController: UIViewController {
        willSet(vc) {
            swapContentViewController(vc)
        }
    }
    /// The drawer view controller - the view that slides out and provides extra info
    public var drawerViewController: UIViewController
    /// The preferred width or height for the drawer
    public var drawerSize: CGFloat = DefaultDrawerSize {
        didSet {
            configureDrawerConstraints()
        }
    }
    /// The duration it takes for the drawer to open / close when triggered
    public var slideDuration = DefaultSlideDuration
    
    /// The direction the drawer slides from
    public private(set) var slideDirection: SASlideDrawerDirection
    /// Whether the user can swipe to reveal the drawer
    public var canPanToDrawer: Bool = true {
        didSet {
            configureGestureRecognizers()
        }
    }
    /// A pan gesture recognizer used to recognize when a user swipes to the view. Non-nil if `canSwipeToDrawer` is true.
    public private(set) var panGestureRecognizer: UIPanGestureRecognizer?
    /// The constraint associated with the sliding action. The 'action' constraint if you will.
    private var slideConstraint: NSLayoutConstraint!
    /// If provided, specifies where the gesture recognizer should determine open/close state as a multiplier (e.g. 0.5 
    /// is halfway. Defaults to 0.5.
    private var showHideThresholdRatio: CGFloat = 0.5
    /// Where the drawer starts. Defaults to 0.0.
    private var slideStartConstant: CGFloat = 0.0
    /// Where the drawer ends
    private var slideEndConstant: CGFloat {
        let end: CGFloat
        
        if slideDirection == .Right || slideDirection == .Bottom {
            end = slideStartConstant - drawerSize
        } else {
            end = slideStartConstant + drawerSize
        }
        
        return end
    }
    /// The current state of the drawer view
    public var drawerState: SASlideDrawerState {
        return slideConstraint.constant == slideStartConstant ? .Closed : .Open
    }
    /// The content view controller's view
    private var content: UIView {
        return contentViewController.view
    }
    /// The drawer view controller's view
    private var drawer: UIView {
        return drawerViewController.view
    }
    
    /// The container view that displays the content view
    private lazy var contentContainerView: UIView = {
        let v = UIView(frame: self.view.frame)
        v.translatesAutoresizingMaskIntoConstraints = false
        self.view.insertSubview(v, atIndex: 0)
        v.pinToParentView()
        return v
    }()
    /// The container view that displays
    private lazy var drawerContainerView: UIView = {
        let v = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.drawerSize, height: self.drawerSize))
        v.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(v)
        return v
    }()
    
    /// Drawer constraints added by this code
    private var drawerConstraints = [NSLayoutConstraint]()
    /// Container constraints added by this code
    private var containerConstraints = [NSLayoutConstraint]()
    /// Drawer size constraint
    private var drawerSizeConstraint: NSLayoutConstraint {
        switch slideDirection {
        case .Left:
            fallthrough
        case .Right:
            return drawerConstraints.filter { $0.firstItem === self.drawerContainerView && $0.firstAttribute == .Width }.first!
        case .Top:
            fallthrough
        case .Bottom:
            return drawerConstraints.filter { $0.firstItem === self.drawerContainerView && $0.firstAttribute == .Height }.first!
        }
    }
    
    /// Handle invoked when drawer will open
    public var drawerWillOpen: ((NSTimeInterval) -> Void)?
    /// Handle invoked when the drawer will close
    public var drawerWillClose: ((NSTimeInterval) -> Void)?
    /// Handle invoked when the drawer did open
    public var drawerDidOpen: (() -> Void)?
    /// Handle invoked when the drawer did close
    public var drawerDidClose: (() -> Void)?
    
    /// Handle invoked when drawer slides (argument represents percent shown,
    /// 0% being 0 and 100% being `drawerSize`)
    public var drawerDidPan: ((CGFloat) -> Void)?
    /// Handle invoked when the drawer pan gesture will begin
    public var drawerPanDidBegin: (() -> Void)?
    /// Handle invoked when drawer pan did finish (first argument represnts
    /// the speed at which the drawer will close, second, second represents
    /// whether the drawer will open or not)
    public var drawerPanDidFinish: ((NSTimeInterval, Bool) -> Void)?
    
    // ***
    
    /// The threshold that the drawer should not appear beyond
    private var swipeThreshold: CGFloat {
        if slideDirection == .Right || slideDirection == .Bottom {
            return -drawerSize
        } else {
            return drawerSize
        }
    }
    
    /**
        Creates a new slide drawer container view controller with the given attributes.
    
        - parameter contentViewController: The view controller containing the main content.
        - parameter drawerViewController: The view controller containing the drawer's content.
        - parameter slideDirection: The direction the menu should slide. Defaults to `.Left`.
    */
    public init(contentViewController: UIViewController, drawerViewController: UIViewController, slideDirection: SASlideDrawerDirection = .Left) {
        self.contentViewController = contentViewController
        self.drawerViewController = drawerViewController
        self.slideDirection = slideDirection
        
        canPanToDrawer = true
        
        super.init(nibName: nil, bundle: nil)
        
        configureGestureRecognizers()
        swapContentViewController(contentViewController)
        swapDrawerViewController(drawerViewController)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        contentViewController = UIViewController()
        drawerViewController = UIViewController()
        slideDirection = .Left
        
        super.init(coder: aDecoder)
    }
    
    // ***
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        configureContainerConstraints()
        configureDrawerConstraints()
    }
    
    public override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        let open = drawerState == .Open
        coordinator.animateAlongsideTransition(
            { context in
                self.drawerSizeConstraint.constant = self.drawerSize
                if open {
                    self.openDrawer()
                } else {
                    self.closeDrawer()
                }
            },
            completion: nil
        )
    }
    
    // MARK: - Event handlers
    private var _swipeStartPoint: CGPoint!
    private var _swipeStartDate: NSDate!
    private var _fingerOffset: CGFloat = 0.0
    
    func didPan(gestureRecognizer: UIPanGestureRecognizer) {
        let viewPoint = gestureRecognizer.locationInView(view)
        let drawerPoint = gestureRecognizer.locationInView(drawer)
        
        switch gestureRecognizer.state {
        case .Began:
            _swipeStartDate = NSDate()
            _swipeStartPoint = viewPoint
            switch slideDirection {
            case .Top:
                _fingerOffset = drawerSize - drawerPoint.y
            case .Bottom:
                _fingerOffset = drawerPoint.y
            case .Left:
                _fingerOffset = drawerSize - drawerPoint.x
            case .Right:
                _fingerOffset = drawerPoint.x
            }
            drawerPanDidBegin?()
        case .Ended:
            let swipeEndPoint = gestureRecognizer.locationInView(view)
//            let swipeEndDate = NSDate()
//            let deltaTime = _swipeStartDate.timeIntervalSinceDate(swipeEndDate)
            let drawerEdge = slideConstraint.constant
            let v = gestureRecognizer.velocityInView(view)
            let deltaUnits: CGFloat
            
            let drawerPos: CGFloat
            switch slideDirection {
            case .Top:
                drawerPos = fabs(drawerEdge)
                deltaUnits = swipeEndPoint.y - _swipeStartPoint.y
            case .Bottom:
                drawerPos = view.bounds.size.height - fabs(drawerEdge)
                deltaUnits = _swipeStartPoint.y - swipeEndPoint.y
            case .Left:
                drawerPos = fabs(drawerEdge)
                deltaUnits = swipeEndPoint.x - _swipeStartPoint.x
            case .Right:
                drawerPos = view.bounds.size.width - fabs(drawerEdge)
                deltaUnits = _swipeStartPoint.x - swipeEndPoint.x
            }
            
            let numer = min(fabs(drawerSize - drawerPos), drawerSize)
            let denom = max(fabs(drawerSize - drawerPos), drawerSize)
            
            if fabs(v.x) > 300.0 || fabs(v.y) > 300.0 {
                let dur = Double(drawerSize - deltaUnits) / Double(v.x)
                let flag: Bool
                if deltaUnits > 0 {
                    openDrawer(customDuration: dur)
                    flag = true
                } else {
                    closeDrawer(customDuration: dur)
                    flag = false
                }
                drawerPanDidFinish?(dur, flag)
            } else if numer / denom < showHideThresholdRatio {
                closeDrawer()
                drawerPanDidFinish?(slideDuration, false)
            } else {
                openDrawer()
                drawerPanDidFinish?(slideDuration, true)
            }
        default:
            var constraint: CGFloat
            switch slideDirection {
            case .Top:
                if viewPoint.y + _fingerOffset > swipeThreshold {
                    constraint = swipeThreshold
                } else {
                    constraint = viewPoint.y + _fingerOffset
                }
            case .Bottom:
                if viewPoint.y - _fingerOffset < view.frame.size.height + swipeThreshold {
                    constraint = slideEndConstant
                } else {
                    constraint = slideStartConstant - (view.frame.size.height - viewPoint.y) - _fingerOffset
                }
            case .Left:
                if viewPoint.x + _fingerOffset > swipeThreshold {
                    constraint = 0.0
                } else {
                    constraint = (viewPoint.x - drawerSize) + _fingerOffset
                }
            case .Right:
                if viewPoint.x - _fingerOffset < view.frame.size.width + swipeThreshold {
                    constraint = slideEndConstant
                } else {
                    constraint = slideStartConstant - (view.frame.size.width - viewPoint.x) - _fingerOffset
                }
            }
            
            slideConstraint.constant = constraint
            
            drawerDidPan?(fabs(constraint / drawerSize))
        }
    }
    
    /**
        Toggles the current drawer state. If the drawer is closed, it will open. If     it 
        is opened, it will close.
    
        :return: The new drawer state.
    */
    public func toggleDrawerState() -> SASlideDrawerState {
        if drawerState == .Open {
            closeDrawer()
        } else {
            openDrawer()
        }
        
        return drawerState
    }
    
    /**
     
        Configures the swipe gesture recognizer.
    */
    private func configureGestureRecognizers() {
        var p: UIPanGestureRecognizer?
        
        if let r = panGestureRecognizer {
            view.removeGestureRecognizer(r)
        }
        
        if canPanToDrawer {
            p = UIPanGestureRecognizer(target: self, action: "didPan:")
            view.addGestureRecognizer(p!)
        }
        
        panGestureRecognizer = p
    }
    
    /**
        Opens the drawer (moves the drawer view onto the screen).
    
        - parameter customDuration: An optional custom duration of the animation.
    */
    public func openDrawer(customDuration d: NSTimeInterval = 0.0) {
        let dur = d == 0.0 ? slideDuration : d
        drawerWillOpen?(dur)
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: Events.DrawerWillOpen, object: self))
        UIView.animateWithDuration(dur, animations: {
            self.slideConstraint.constant = self.slideEndConstant
            self.drawerContainerView.layoutIfNeeded()
        }) { _ in
            self.drawerDidOpen?()
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: Events.DrawerDidOpen, object: self))
        }
    }

    /**
        Close the drawer (moves the drawer view off of the screen).
        
        - parameter customDuration: An optional custom duration of the animation.
    */
    public func closeDrawer(customDuration d: NSTimeInterval = 0.0) {
        let dur = d == 0.0 ? slideDuration : d
        drawerWillClose?(dur)
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: Events.DrawerWillClose, object: self))
        UIView.animateWithDuration(dur, animations: {
            self.slideConstraint.constant = self.slideStartConstant
            self.drawerContainerView.layoutIfNeeded()
        }) { _ in
            self.drawerDidClose?()
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: Events.DrawerDidClose, object: self))
        }
    }
    
    /**
        Configures the auto-layout constraints for the container.
    */
    private func configureContainerConstraints() {
        contentContainerView.pinToParentView()
    }
    
    /**
        Swap the content view controller for the new one
    
        :param: vc The view controller to swap the content to.
    */
    private func swapContentViewController(vc: UIViewController) {
        contentViewController.willMoveToParentViewController(nil)
        addChildViewController(vc)
        vc.view.frame = contentContainerView.frame
        for v in contentContainerView.subviews { v.removeFromSuperview() }
        contentContainerView.addSubview(vc.view)
        vc.view.pinToParentView()
        contentViewController.removeFromParentViewController()
        vc.didMoveToParentViewController(self)
    }
    
    /**
        Swap the drawer view controller for the new one
        
        :param: vc The view controller to swap the drawer to.
    */
    private func swapDrawerViewController(vc: UIViewController) {
        drawerViewController.willMoveToParentViewController(nil)
        addChildViewController(vc)
        vc.view.frame = drawerContainerView.frame
        for v in drawerContainerView.subviews { v.removeFromSuperview() }
        drawerContainerView.addSubview(vc.view)
        vc.view.pinToParentView()
        drawerViewController.removeFromParentViewController()
        vc.didMoveToParentViewController(self)
    }
    
    /**
        Configures the auto-layout constraints for the drawer
    */
    private func configureDrawerConstraints() {
        view.removeConstraints(drawerConstraints)
        
        var constraints = [NSLayoutConstraint]()
        switch slideDirection {
        case .Top:
            let c = NSLayoutConstraint(item: drawerContainerView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: slideStartConstant)
            constraints.append(c)
            slideConstraint = c
            constraints.append(NSLayoutConstraint(item: drawerContainerView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0.0))
            constraints.append(NSLayoutConstraint(item: drawerContainerView, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 0.0))
            constraints.append(NSLayoutConstraint(item: drawerContainerView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: drawerSize))
        case .Bottom:
            let c = NSLayoutConstraint(item: drawerContainerView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: slideStartConstant)
            slideConstraint = c
            constraints.append(c)
            constraints.append(NSLayoutConstraint(item: drawerContainerView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0.0))
            constraints.append(NSLayoutConstraint(item: drawerContainerView, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 0.0))
            constraints.append(NSLayoutConstraint(item: drawerContainerView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: drawerSize))
        case .Left:
            slideStartConstant = -drawerSize
            let c = NSLayoutConstraint(item: drawerContainerView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: slideStartConstant)
            slideConstraint = c
            constraints.append(c)
            constraints.append(NSLayoutConstraint(item: drawerContainerView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0.0))
            constraints.append(NSLayoutConstraint(item: drawerContainerView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0))
            constraints.append(NSLayoutConstraint(item: drawerContainerView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: drawerSize))
        case .Right:
            slideStartConstant = drawerSize
            let c = NSLayoutConstraint(item: drawerContainerView, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: slideStartConstant)
            slideConstraint = c
            constraints.append(c)
            constraints.append(NSLayoutConstraint(item: drawerContainerView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0.0))
            constraints.append(NSLayoutConstraint(item: drawerContainerView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0))
            constraints.append(NSLayoutConstraint(item: drawerContainerView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: drawerSize))
        }
        
        view.addConstraints(constraints)
        view.setNeedsDisplay()
        drawerConstraints = constraints
    }
    
    // ***
}
