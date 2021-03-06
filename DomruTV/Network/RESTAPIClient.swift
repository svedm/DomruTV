//
//  DomruAPIClient.swift
//  DomruTV
//
//  Created by Svetoslav Karasev on 02/09/2018.
//  Copyright © 2018 Svetoslav Karasev. All rights reserved.
//

import Foundation
import Alamofire

class RESTAPIClient: APIClient {
    private var sessionManager: Session
    private var deviceId: String
    private var jsonDecoder: JSONDecoder
    var authToken: String?

    private class DomruServerTrustPolicyManager: ServerTrustManager {
        override func serverTrustEvaluator(forHost host: String) throws -> ServerTrustEvaluating? {
            DisabledTrustEvaluator()
        }
    }

    private struct Endpoint {
        static let iosAPI = URL.fromRequired(string: "https://discovery-ios-23.ertelecom.ru")
        static let channelsAPI = URL.fromRequired(string: "https://discovery-stb3.ertelecom.ru")
    }

    init(deviceId: String, authToken: String? = nil) {
        self.deviceId = deviceId
        self.authToken = authToken
        var defaultHeaders = URLSessionConfiguration.af.default.headers.dictionary
        defaultHeaders["X-Device-Info"] = deviceId
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = defaultHeaders
        sessionManager = Session(
            configuration: configuration,
            serverTrustManager: DomruServerTrustPolicyManager(evaluators: [:])
        )
        jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    func getUnboundedToken(_ completion: @escaping (Result<DeviceTokenResponse, DomruTVError>) -> Void) {
        let params = [
            "client_id": "er_ios_device",
            "device_id": deviceId,
            "os_version": "11.3.1",
            "screen_height": "568",
            "screen_width": "320",
            "timestamp": String(Int(Date().timeIntervalSince1970))
        ]

        request(Endpoint.iosAPI.appendingPathComponent("/token/device"), method: .get, parameters: params, completion: completion)
    }

    func auth(login: String, password: String, completion: @escaping (Result<AuthResponse, DomruTVError>) -> Void) {
        let params = [
            "password": password,
            "region": "spb",
            "username": login
        ]

        request(Endpoint.iosAPI.appendingPathComponent("/er/ssoauth/auth"), method: .post, parameters: params, completion: completion)
    }

    func getBoundedToken(sso: String, completion: @escaping (Result<DeviceTokenResponse, DomruTVError>) -> Void) {
        let params = [
            "sso_key": sso,
            "sso_system": "er"
        ]

        request(Endpoint.iosAPI.appendingPathComponent("/token/subscriber_device/by_sso"), method: .get, parameters: params,
            completion: completion)
    }

    func getChannelsList(pageSize: Int, page: Int, completion: @escaping (Result<ChannelsResponse, DomruTVError>) -> Void) {
        let params: [String: Any] = [
            "adult": "not-adult,adult",
            "limit": pageSize,
            "offset": 0,
            "page": page
        ]
        let headers: HTTPHeaders = ["View": "stb3"]
        request(
            Endpoint.channelsAPI.appendingPathComponent("/api/v3/showcases/channels-menu/all-channels"),
            method: .get,
            parameters: params,
            completion: completion,
            headers: headers
        )
    }

    func getResourceURL(channelId: Int, resourceId: Int, completion: @escaping (Result<ResourceURL, DomruTVError>) -> Void) {
        let url = Endpoint.iosAPI
            .appendingPathComponent("resource/get_url/")
            .appendingPathComponent("\(channelId)")
            .appendingPathComponent("\(resourceId)")
        request(
            url,
            method: .get,
            parameters: [:],
            completion: completion
        )
    }

    private func request<T: Decodable>(
        _ url: URL,
        method: HTTPMethod,
        parameters: Parameters,
        completion: @escaping (Result<T, DomruTVError>) -> Void,
        headers: HTTPHeaders? = nil
    ) {
        var headers = headers ?? HTTPHeaders()
        if let authToken = authToken {
            headers["X-Auth-Token"] = authToken
        }

        sessionManager.request(
            url,
            method: method,
            parameters: parameters,
            headers: headers
        ).responseDecodable(decoder: jsonDecoder) { (response: DataResponse<T, AFError>) in
            guard let data = response.value else {
                response.error.map { completion(.error(.network($0))) }
                return
            }

            completion(.success(data))
        }
    }
}
