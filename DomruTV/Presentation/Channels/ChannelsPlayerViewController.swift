//
//  ChannelsPlayerViewController.swift
//  DomruTV
//
//  Created by Svetoslav Karasev on 23/09/2018.
//  Copyright © 2018 Svetoslav Karasev. All rights reserved.
//

import UIKit
import AVKit

class ChannelsPlayerViewController: AVPlayerViewController, AVPlayerViewControllerDelegate {
    struct Data {
        var channels: [ChannelsResponse.Channel]
        var currentChannelIndex: Int
    }

    struct Actions {
        var getChannelURL: (_ channelId: Int, _ resourceId: Int, _ completion: @escaping (Result<URL, Error>) -> Void) -> Void
    }

    var data: Data!
    var actions: Actions!

    override func viewDidLoad() {
        super.viewDidLoad()

        skippingBehavior = .skipItem
        isSkipBackwardEnabled = true
        isSkipForwardEnabled = true
        videoGravity = AVLayerVideoGravity.resizeAspectFill.rawValue
        delegate = self
        player = AVPlayer()
        loadAndPlay()
    }

    private func loadAndPlay() {
        let channel = data.channels[data.currentChannelIndex]
        guard let resourceId = channel.resources.first(where: { $0.type == .hls })?.id else { return }

        actions.getChannelURL(channel.id, resourceId) { result in
            switch result {
                case .success(let url):
                    self.player?.replaceCurrentItem(with: AVPlayerItem(url: url))
                    self.player?.play()
                case .error:
                    print("Error")
            }
        }
    }

    func skipToNextItem(for playerViewController: AVPlayerViewController) {
        var nextIndex = data.currentChannelIndex + 1
        if nextIndex >= data.channels.count {
            nextIndex = 0
        }

        data.currentChannelIndex = nextIndex
        loadAndPlay()
    }

    func skipToPreviousItem(for playerViewController: AVPlayerViewController) {
        var prevIndex = data.currentChannelIndex - 1
        if prevIndex < 0 {
            prevIndex = data.channels.count - 1
        }

        data.currentChannelIndex = prevIndex
        loadAndPlay()
    }
}
