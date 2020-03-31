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
        var channels: (_ count: Int, _ page: Int, @escaping ([ChannelsResponse.Channel], Int) -> Void) -> Void
    }

    struct Actions {
        var showChannel: (_ channels: [ChannelsResponse.Channel], _ startIndex: Int) -> Void
    }

    var data: Data!
    var actions: Actions!
    private var channels: [ChannelsResponse.Channel] = []
    private let pageSize = 50
    private var currentPage = 1
    private var total: Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        activityIndicator.isHidden = true
        loadData()
    }

    private func loadData() {
        guard currentPage <= ((total ?? pageSize) / pageSize) + 1, activityIndicator.isHidden else { return }

        activityIndicator.isHidden = false

        data.channels(pageSize, currentPage) { [weak self] channels, total in
            self?.channels.append(contentsOf: channels)
            self?.total = total
            self?.currentPage += 1
            self?.collectionView.reloadData()
            self?.activityIndicator.isHidden = true
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        channels.count
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == channels.count - 1 {
            loadData()
        }
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
        actions.showChannel(channels, indexPath.item)
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
