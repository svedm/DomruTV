//
//  NetworkChannelsService.swift
//  DomruTV
//
//  Created by Svetoslav Karasev on 22/09/2018.
//  Copyright © 2018 Svetoslav Karasev. All rights reserved.
//

import Foundation

class NetworkChannelsService: ChannelsService {
    private let apiClient: APIClient

    init(apiClient: APIClient, settingsService: SettingsService) {
        self.apiClient = apiClient
        self.apiClient.authToken = settingsService.authToken
    }

    func getChannelsList(pageSize: Int, page: Int, completion: @escaping (Result<ChannelsResponse.List, DomruTVError>) -> Void) {
        apiClient.getChannelsList(pageSize: pageSize, page: page) { result in
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
