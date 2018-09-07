//
//  AppDelegate.swift
//  Drunken Calculator
//
//  Created by Michael Bernat on 08/03/2018.
//  Copyright © 2018 Michael Bernat. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?)
        -> Bool {
        self.window = self.window ?? UIWindow()
        self.window?.backgroundColor = .white
        self.window?.rootViewController = CalculatorContainerController()
        self.window?.makeKeyAndVisible()
        return true
    }

}

