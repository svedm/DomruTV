//
//  ChannelsCoordinator.swift
//  DomruTV
//
//  Created by Svetoslav Karasev on 22/09/2018.
//  Copyright © 2018 Svetoslav Karasev. All rights reserved.
//

import UIKit
import Swinject

class ChannelsCoordinator {
    private let channelsService: ChannelsService

    init(channelsService: ChannelsService) {
        self.channelsService = channelsService
    }

    func start(window: UIWindow) {
        window.rootViewController = createChannelsViewController()
    }

    private func createChannelsViewController() -> ChannelsViewController {
        let viewController: ChannelsViewController = Storyboard.channels.instantiate()
        viewController.actions = ChannelsViewController.Actions(getChannelURL: getChannelURL)
        viewController.data = ChannelsViewController.Data(channels: getChannels)
        return viewController
    }

    private func getChannels(completion: @escaping ([ChannelsResponse.Channel]) -> Void) {
        channelsService.getChannelsList { result in
            switch result {
                case .success(let data):
                    completion(data.items)
                case .error:
                    completion([])
            }
        }
    }

    private func getChannelURL(channelId: Int, resourceId: Int, completion: @escaping (Result<URL, Error>) -> Void) {
        channelsService.getChannelURL(channelId: channelId, resourceId: resourceId) { result in
            switch result {
                case .success(let data):
                    completion(.success(data))
                case .error(let error):
                    completion(.error(error))
            }
        }
    }
}
