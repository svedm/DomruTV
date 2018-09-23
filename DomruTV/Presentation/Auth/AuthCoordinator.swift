//
//  AuthCoordinator.swift
//  DomruTV
//
//  Created by Svetoslav Karasev on 22/09/2018.
//  Copyright © 2018 Svetoslav Karasev. All rights reserved.
//

import UIKit
import Swinject

class AuthCoordinator {
    private let container: Container
    private let authService: AuthService
    private weak var window: UIWindow!

    init(container: Container, authService: AuthService) {
        self.container = container
        self.authService = authService
    }

    func start(window: UIWindow) {
        self.window = window
        window.rootViewController = createAuthViewController()
    }

    private func login(login: String, password: String, failure: @escaping (Error) -> Void) {
        authService.login(login: login, password: password) { result in
            switch result {
                case .success:
                    let coordiantor = self.container.resolve(ChannelsCoordinator.self)
                    coordiantor?.start(window: self.window)
                case .error(let error):
                    failure(error)
            }
        }
    }

    private func createAuthViewController() -> AuthViewController {
        let authViewController: AuthViewController = Storyboard.auth.instantiate()
        authViewController.actions = AuthViewController.Actions(login: login)

        return authViewController
    }
}
