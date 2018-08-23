//
//  ViewController.swift
//  SASlideDrawerDemo
//
//  Created by Stefan Arambasich on 4/20/2015.
//  Copyright (c) 2015 Stefan Arambasich. All rights reserved.
//

import SASlideDrawer

class ViewController: UIViewController {

    // MARK: -

    @IBOutlet private weak var label: UILabel?

    // MARK: -

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let c = AppDelegate.currentAppDelegate.drawerController
        c?.drawerDidPan = { pct in
            self.label?.text = "\(pct)"
            self.view.backgroundColor = UIColor(hue: pct, saturation: pct, brightness: pct, alpha: 1.0)
        }
    }

    // MARK: -

    @IBAction func didSelectDrawerButton(_ sender: UIButton) {
        _ = AppDelegate.currentAppDelegate.drawerController.toggleDrawerState()
    }

    @IBAction func didSelectShowStateButton(_ sender: UIButton) {
        guard let c = AppDelegate.currentAppDelegate.drawerController else { return }
        print(c.drawerState)
    }

}
