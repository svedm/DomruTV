//
//  ChannelsViewController.swift
//  DomruTV
//
//  Created by Svetoslav Karasev on 29/08/2018.
//  Copyright © 2018 Svetoslav Karasev. All rights reserved.
//

import UIKit
import AVKit

class ChannelsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var collectionView: UICollectionView!
    private var channelsService: NetworkChannelsService!
    private var data: [ChannelsResponse.Channel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let settingsService = UserDefaultsSettingsService()
        let apiClient = RESTAPIClient(deviceId: AppConstants.deviceId, authToken: settingsService.authToken)
        let authService = NetworkAuthService(apiClient: apiClient, settingService: settingsService)
        channelsService = NetworkChannelsService(apiClient: apiClient)

        if !authService.isAuthorized {
            activityIndicator.isHidden = false
            authService.login { [weak self] result in
                self?.activityIndicator.isHidden = true
                switch result {
                    case .success:
                        self?.loadData()
                    case .error(let error):
                        print(error.localizedDescription)
                }
            }
        } else {
            loadData()
        }

        collectionView.delegate = self
        collectionView.dataSource = self
    }

    private func loadData() {
        activityIndicator.isHidden = false
        channelsService.getChannelsList { [weak self] result in
            self?.activityIndicator.isHidden = true
            switch result {
                case .success(let data):
                    self?.data = data.items
                    self?.collectionView.reloadData()
                case .error(let error):
                    print(error.localizedDescription)
            }
        }
    }

    private func showChannel(url: URL) {
        let player = AVPlayer(url: url)
        let controller = AVPlayerViewController()
        controller.player = player
        present(controller, animated: true) {
            player.play()
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChannelCollectionViewCell.reuseId, for: indexPath)

        if let channelCell = cell as? ChannelCollectionViewCell {
            let channel = data[indexPath.item]
            channelCell.configure(title: channel.title, imageURL: channel.logoURL)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let channel = data[indexPath.item]
        guard let resourceId = channel.resources.first(where: { $0.type == .hls })?.id else { return }

        activityIndicator.isHidden = false
        channelsService.getChannelURL(channelId: channel.id, resourceId: resourceId) { [weak self] result in
            self?.activityIndicator.isHidden = true
            switch result {
                case .success(let url):
                    self?.showChannel(url: url)
                case .error(let error):
                    print(error.localizedDescription)
            }
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didUpdateFocusIn context: UICollectionViewFocusUpdateContext,
        with coordinator: UIFocusAnimationCoordinator
    ) {
        if let previousIndexPath = context.previouslyFocusedIndexPath, let cell = collectionView.cellForItem(at: previousIndexPath) {
            cell.backgroundColor = .white
        }
        if let indexPath = context.nextFocusedIndexPath, let cell = collectionView.cellForItem(at: indexPath) {
            cell.backgroundColor = .lightGray
        }
    }
}
