//
//  ChannelsService.swift
//  DomruTV
//
//  Created by Svetoslav Karasev on 02/09/2018.
//  Copyright © 2018 Svetoslav Karasev. All rights reserved.
//

import Foundation

class ChannelsService {
    private let apiClient: DomruAPIClient

    init(apiClient: DomruAPIClient) {
        self.apiClient = apiClient
    }

    func getChannelsList(completion: @escaping (Result<ChannelsResponse.List, DomruTVError>) -> Void) {
        apiClient.getChannelsList { result in
            switch result {
                case .success(let response):
                    completion(.success(response.data))
                case .error(let error):
                    completion(.error(error))
            }
        }
    }

    func getChannelURL(channelId: Int, resourceId: Int, completion: @escaping (Result<URL, DomruTVError>) -> Void) {
        apiClient.getResourceURL(channelId: channelId, resourceId: resourceId) { result in
            switch result {
                case .success(let response):
                    completion(.success(response.url))
                case .error(let error):
                    completion(.error(error))
            }
        }
    }
}
