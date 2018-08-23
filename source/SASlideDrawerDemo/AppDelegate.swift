//
//  AppDelegate.swift
//  SASlideDrawerDemo
//
//  Created by Stefan Arambasich on 4/20/2015.
//  Copyright (c) 2015 Stefan Arambasich. All rights reserved.
//

import UIKit

import SASlideDrawer

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    var drawerController: SASlideDrawerViewController!

    class var currentAppDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        // Override point for customization after application launch.

        let content = ViewController(nibName: "MainView", bundle: nil)
        content.view.translatesAutoresizingMaskIntoConstraints = false
        let drawer = DrawerViewController(nibName: "DrawerView", bundle: nil)
        drawer.view.translatesAutoresizingMaskIntoConstraints = false

//        let container = SASlideDrawerViewController(contentViewController: content, drawerViewController: drawer)
        let container = SASlideDrawerViewController(contentViewController: content, drawerViewController: drawer, slideDirection: SASlideDrawerDirection.left)
        container.view.translatesAutoresizingMaskIntoConstraints = false

        drawerController = container

        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = container
        self.window?.makeKeyAndVisible()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

