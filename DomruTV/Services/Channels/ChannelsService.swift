//
//  ChannelsService.swift
//  DomruTV
//
//  Created by Svetoslav Karasev on 02/09/2018.
//  Copyright © 2018 Svetoslav Karasev. All rights reserved.
//

import Foundation

protocol ChannelsService {
    func getChannelsList(pageSize: Int, page: Int, completion: @escaping (Result<ChannelsResponse.List, DomruTVError>) -> Void)
    func getChannelURL(channelId: Int, resourceId: Int, completion: @escaping (Result<URL, DomruTVError>) -> Void)
}
