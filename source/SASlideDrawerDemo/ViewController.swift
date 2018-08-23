//
//  ViewController.swift
//  SASlideDrawerDemo
//
//  Created by Stefan Arambasich on 4/20/2015.
//  Copyright (c) 2015 Stefan Arambasich. All rights reserved.
//

import SASlideDrawer

class ViewController: UIViewController {
    @IBOutlet private weak var label: UILabel!

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        let c = AppDelegate.currentAppDelegate.drawerController
        c.drawerDidPan = { pct in
            self.label.text = "\(pct)"
            self.view.backgroundColor = UIColor(hue: pct, saturation: pct, brightness: pct, alpha: 1.0)
        }
    }

    @IBAction func didSelectButton(sender: AnyObject!) {
        AppDelegate.currentAppDelegate.drawerController.toggleDrawerState()
    }

    @IBAction func didSelectShowStateButton(sender: AnyObject!) {
        let c = AppDelegate.currentAppDelegate.drawerController
        print(c.drawerState.rawValue)
    }
}
