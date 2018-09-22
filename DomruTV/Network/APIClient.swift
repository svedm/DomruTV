//
//  APIClient.swift
//  DomruTV
//
//  Created by Svetoslav Karasev on 22/09/2018.
//  Copyright © 2018 Svetoslav Karasev. All rights reserved.
//

import Foundation

protocol APIClient: class {
    var authToken: String? { get set }
    func getUnboundedToken(_ completion: @escaping (Result<DeviceTokenResponse, DomruTVError>) -> Void)
    func auth(login: String, password: String, completion: @escaping (Result<AuthResponse, DomruTVError>) -> Void)
    func getBoundedToken(sso: String, completion: @escaping (Result<DeviceTokenResponse, DomruTVError>) -> Void)
    func getChannelsList(completion: @escaping (Result<ChannelsResponse, DomruTVError>) -> Void)
    func getResourceURL(channelId: Int, resourceId: Int, completion: @escaping (Result<ResourceURL, DomruTVError>) -> Void)
}
