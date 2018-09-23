//
//  ChannelCollectionViewCell.swift
//  DomruTV
//
//  Created by Svetoslav Karasev on 02/09/2018.
//  Copyright © 2018 Svetoslav Karasev. All rights reserved.
//

import UIKit
import AlamofireImage

class ChannelCollectionViewCell: UICollectionViewCell {
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var label: UILabel!

    static let reuseId = "ChannelCollectionViewCell"

    func configure(title: String, imageURL: URL?) {
        label.text = title
        imageURL.map { imageView.af_setImage(withURL: $0) }
        backgroundColor = .white
        selectedBackgroundView?.backgroundColor = .lightGray
        layer.cornerRadius = 15
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        label.text = nil
        imageView.image = nil
    }
}
