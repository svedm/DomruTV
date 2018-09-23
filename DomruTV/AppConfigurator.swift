//
//  AppConfigurator.swift
//  DomruTV
//
//  Created by Svetoslav Karasev on 22/09/2018.
//  Copyright © 2018 Svetoslav Karasev. All rights reserved.
//

import Swinject

protocol Configurator {
    func create() -> Container
}

class AppConfigurator: Configurator {
    func create() -> Container {
        let container = Container()

        container.register(Container.self) { [unowned container] _ in container }
        container.register(SettingsService.self) { _ in UserDefaultsSettingsService() }
        container.register(APIClient.self) { resolver in
            guard let deviceId = resolver.resolve(SettingsService.self)?.deviceId else { fatalError("Can't resolve deviceId") }

            return RESTAPIClient(deviceId: deviceId)
        }
        container.register(AuthService.self) { resolver in
            guard
                let apiClient = resolver.resolve(APIClient.self),
                let settingsService = resolver.resolve(SettingsService.self)
            else { fatalError("Can't resolve dependencies") }

            return NetworkAuthService(apiClient: apiClient, settingService: settingsService)
        }
        container.register(ChannelsService.self) { resolver in
            guard
                let apiClient = resolver.resolve(APIClient.self),
                let settingsService = resolver.resolve(SettingsService.self)
            else { fatalError("Can't resolve dependencies") }

            return NetworkChannelsService(apiClient: apiClient, settingsService: settingsService)
        }
        container.register(AuthCoordinator.self) { resolver in
            guard
                let container = resolver.resolve(Container.self),
                let authService = resolver.resolve(AuthService.self)
            else { fatalError("Can't resolve dependencies") }

            return AuthCoordinator(container: container, authService: authService)
        }
        container.register(ChannelsCoordinator.self) { resolver in
            guard let channelsService = resolver.resolve(ChannelsService.self) else { fatalError("Can't resolve dependencies") }

            return ChannelsCoordinator(channelsService: channelsService)
        }

        return container
    }
}
