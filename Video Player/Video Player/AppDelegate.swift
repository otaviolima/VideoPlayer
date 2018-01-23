//
//  AppDelegate.swift
//  Video Player
//
//  Created by Otávio Lima on 23/01/18.
//  Copyright © 2018 Francisco Otavio Silva de Lima. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = ViewController()
        window.makeKeyAndVisible()

        self.window = window

        return true
    }

}

