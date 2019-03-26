//
//  AppDelegate.swift
//  DomruTV
//
//  Created by Svetoslav Karasev on 29/08/2018.
//  Copyright © 2018 Svetoslav Karasev. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        window.makeKeyAndVisible()

        let configurator = AppConfigurator()
        let coordinator = AppCoordinator()
        coordinator.start(window: window, container: configurator.create())

        return true
    }
}
