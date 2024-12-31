//
//  ChannelsResponse.swift
//  DomruTV
//
//  Created by Svetoslav Karasev on 02/09/2018.
//  Copyright © 2018 Svetoslav Karasev. All rights reserved.
//

import Foundation

struct ChannelsResponse: Decodable {
    struct Channel: Decodable {
        var id: Int
        var title: String
        var resources: [Resource]
        var logoURL: URL? {
            guard let id = resources.first(where: { $0.type == .posterChannelGridBlueprint })?.id else { return nil }

            return URL(string: "http://er-cdn.ertelecom.ru/content/public/r\(id)/358x239:crop")
        }

        struct Resource: Decodable {
            var id: Int
            var type: ResourceType
            enum ResourceType: String, Decodable {
                case hls = "hls"
                case posterBlueprint = "poster_blueprint"
                case backgroundBlueprint = "background_blueprint"
                case mcast = "mcast"
                case posterChannelGridBlueprint = "poster_channel_grid_blueprint"
                case catchup = "catchup"
                case mcastLocal = "hls_mcast_local"
                case smartTvBanner = "3_smarttv_asset_poster_banner_showcase_blueprint"
                case videoSlider = "video_library_slider_image"
                case newDesignChannelLogoBlueprint = "newdesign_channel_logo_blueprint"
                case newDesignPackagePosterBlueprint = "newdesign_package_poster_blueprint"
            }
        }
    }

    struct List: Decodable {
        var total: Int
        var items: [Channel]
    }
    var data: List
}
