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
        viewController.data = ChannelsViewController.Data(channels: getChannels)
        viewController.actions = ChannelsViewController.Actions { [unowned viewController] in
            self.showChannel(channels: $0, startIndex: $1, presenter: viewController)
        }
        return viewController
    }

    private func createPlayerViewController(channels: [ChannelsResponse.Channel], startIndex: Int) -> ChannelsPlayerViewController {
        let viewController = ChannelsPlayerViewController()
        viewController.data = ChannelsPlayerViewController.Data(channels: channels, currentChannelIndex: startIndex)
        viewController.actions = ChannelsPlayerViewController.Actions(getChannelURL: getChannelURL)
        return viewController
    }

    private func showChannel(channels: [ChannelsResponse.Channel], startIndex: Int, presenter: UIViewController) {
        presenter.present(createPlayerViewController(channels: channels, startIndex: startIndex), animated: true, completion: nil)
    }

    private func getChannels(pageSize: Int, page: Int, completion: @escaping ([ChannelsResponse.Channel], Int) -> Void) {
        channelsService.getChannelsList(pageSize: pageSize, page: page) { result in
            switch result {
                case .success(let data):
                    completion(data.items, data.total)
                case .error(let error):
                    // TODO: Show alert in VC
                    print(error)
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
