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

    struct Data {
        var channels: (@escaping ([ChannelsResponse.Channel]) -> Void) -> Void
    }

    struct Actions {
        var getChannelURL: (_ channelId: Int, _ resourceId: Int, _ completion: @escaping (Result<URL, Error>) -> Void) -> Void
    }

    var data: Data!
    var actions: Actions!
    private var channels: [ChannelsResponse.Channel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        loadData()
    }

    private func loadData() {
        activityIndicator.isHidden = false

        data.channels { [weak self] channels in
            self?.activityIndicator.isHidden = true
            self?.channels = channels
            self?.collectionView.reloadData()
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
        return channels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChannelCollectionViewCell.reuseId, for: indexPath)

        if let channelCell = cell as? ChannelCollectionViewCell {
            let channel = channels[indexPath.item]
            channelCell.configure(title: channel.title, imageURL: channel.logoURL)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let channel = channels[indexPath.item]
        guard let resourceId = channel.resources.first(where: { $0.type == .hls })?.id else { return }

        activityIndicator.isHidden = false
        actions.getChannelURL(channel.id, resourceId) { [weak self] result in
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
