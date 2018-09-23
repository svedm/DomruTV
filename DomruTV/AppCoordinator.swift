//
//  AppCoordinator.swift
//  DomruTV
//
//  Created by Svetoslav Karasev on 22/09/2018.
//  Copyright © 2018 Svetoslav Karasev. All rights reserved.
//

import UIKit
import Swinject

class AppCoordinator {
    func start(window: UIWindow, container: Container) {
        guard let authService = container.resolve(AuthService.self) else { return }

        if authService.isAuthorized {
            let coordinator = container.resolve(ChannelsCoordinator.self)
            coordinator?.start(window: window)
        } else {
            let coordinator = container.resolve(AuthCoordinator.self)
            coordinator?.start(window: window)
        }
    }
}
