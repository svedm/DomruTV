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
        var showChannel: (_ id: Int, _ resourceId: Int, _ completion: @escaping (Result<Void, Error>) -> Void) -> Void
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

        actions.showChannel(channel.id, resourceId) { _ in
            self.activityIndicator.isHidden = true
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
