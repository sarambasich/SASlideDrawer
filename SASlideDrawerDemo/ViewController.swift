//
//  ViewController.swift
//  SASlideDrawerDemo
//
//  Created by Stefan Arambasich on 4/20/2015.
//  Copyright (c) 2015 Stefan Arambasich. All rights reserved.
//

import SASlideDrawer

class ViewController: UIViewController {
    @IBAction func didSelectButton(sender: AnyObject!) {
        AppDelegate.currentAppDelegate.drawerContainer.toggleDrawerState()
    }
    
    @IBAction func didSelectShowStateButton(sender: AnyObject!) {
        let c = AppDelegate.currentAppDelegate.drawerContainer
        println(c.drawerState.rawValue)
    }
}
