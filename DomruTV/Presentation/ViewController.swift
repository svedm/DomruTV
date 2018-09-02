//
//  ViewController.swift
//  DomruTV
//
//  Created by Svetoslav Karasev on 29/08/2018.
//  Copyright © 2018 Svetoslav Karasev. All rights reserved.
//

import UIKit
import Alamofire

protocol DomruAPIResponse {
    var result: Int { get set }
}

struct ChannelsResponse: Decodable {
    struct Channel: Decodable {
        var id: Int
        var title: String
        var resources: [Resource]

        struct Resource: Decodable {
            var id: Int
            var type: ResourceType
            enum ResourceType: String, Decodable {
                case hls = "hls"
                case posterBlueprint = "poster_blueprint"
                case mcast = "mcast"
                case posterChannelGridBlueprint = "poster_channel_grid_blueprint"
                case catchup = "catchup"
            }
        }
    }

    struct List: Decodable {
        var total: Int
        var items: [Channel]
    }
    var data: List
}

struct DeviceTokenResponse: DomruAPIResponse, Decodable {
    var result: Int
    var token: String
    var isBound: Bool
}

struct AuthResponse: DomruAPIResponse, Decodable {
    var result: Int
    var sso: String
}

enum Result<T, E: Error> {
    case success(T)
    case error(E)
}

enum DomruTVError: Error {
    case network(Error)
    case api(Error)
}

struct ResourceURL: DomruAPIResponse, Decodable {
    var result: Int
    var url: URL
}

class DomruAPIClient {
    private var sessionManager: SessionManager
    private var deviceId: String
    private var jsonDecoder: JSONDecoder
    var authToken: String?

    private class DomruServerTrustPolicyManager: ServerTrustPolicyManager {
        override func serverTrustPolicy(forHost host: String) -> ServerTrustPolicy? {
            return .disableEvaluation
        }
    }

    private struct Endpoint {
        static let iosAPI = URL.fromRequired(string: "https://discovery-ios-23.ertelecom.ru")
        static let channelsAPI = URL.fromRequired(string: "https://discovery-stb3.ertelecom.ru")
    }

    init(deviceId: String, authToken: String? = nil) {
        self.deviceId = deviceId
        self.authToken = authToken
        var defaultHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        defaultHeaders["X-Device-Info"] = deviceId
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = defaultHeaders
        sessionManager = Alamofire.SessionManager(
            configuration: configuration,
            serverTrustPolicyManager: DomruServerTrustPolicyManager(policies: [:])
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

    func getChannelsList(completion: @escaping (Result<ChannelsResponse, DomruTVError>) -> Void) {
        let params = [
            "adult": "not-adult,adult",
            "limit": "100",
            "offset": "0",
            "page": "1"
        ]
        let headers: HTTPHeaders = ["View": "stb3"]
        request(Endpoint.channelsAPI.appendingPathComponent("/api/v3/showcases/library/channels"), method: .get, parameters: params,
            completion: completion, headers: headers)
    }

    func getResourceURL(channelId: Int, resourceId: Int, completion: @escaping (Result<ResourceURL, DomruTVError>) -> Void) {
        request(
            Endpoint.iosAPI.appendingPathComponent("\(channelId)").appendingPathComponent("\(resourceId)"),
            method: .get,
            parameters: [:],
            completion: completion
        )
    }

    private func request<T: Decodable>(_ url: URL, method: HTTPMethod,
            parameters: Parameters, completion: @escaping (Result<T, DomruTVError>) -> Void, headers: HTTPHeaders? = nil) {
        var headers = headers ?? HTTPHeaders()
        if let authToken = authToken {
            headers["X-Auth-Token"] = authToken
        }

        sessionManager.request(
            url,
            method: method,
            parameters: parameters,
            headers: headers
        ).responseDecodable(decoder: jsonDecoder) { (response: DataResponse<T>) in
            guard let data = response.value else {
                response.error.map { completion(.error(.network($0))) }
                return
            }

            completion(.success(data))
        }
    }
}

class SettingsService {
    private var userDefaults: UserDefaults = UserDefaults.standard
    private enum Setting: String {
        case authToken = "authToken"
    }

    var authToken: String? {
        return string(for: .authToken)
    }
    func setAuthToken(_ token: String) {
        set(token, for: .authToken)
    }

    private func string(for key: Setting) -> String? {
        return userDefaults.string(forKey: key.rawValue)
    }

    private func set(_ value: Any?, for key: Setting) {
        userDefaults.set(value, forKey: key.rawValue)
        userDefaults.synchronize()
    }
}

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
}

class AuthService {
    private let apiClient: DomruAPIClient
    private let settingService: SettingsService
    var isAuthorized: Bool {
        return settingService.authToken != nil
    }

    init(apiClient: DomruAPIClient, settingService: SettingsService) {
        self.settingService = settingService
        self.apiClient = apiClient
    }

    func login(completion: @escaping (Result<Void, DomruTVError>) -> Void) {
        apiClient.getUnboundedToken { result in
            switch result {
                case .success(let response):
                    self.apiClient.authToken = response.token
                    self.auth(
                        login: AppConstants.login,
                        password: AppConstants.password
                    ) { result in
                        switch result {
                            case .success(let response):
                                self.apiClient.authToken = response.token
                                self.settingService.setAuthToken(response.token)
                                completion(.success(Void()))
                            case .error(let error):
                                completion(.error(error))
                        }
                    }
                case .error(let error):
                    completion(.error(error))
            }
        }
    }

    private func auth(login: String, password: String, completion: @escaping (Result<DeviceTokenResponse, DomruTVError>) -> Void) {
        apiClient.auth(login: login, password: password) { result in
            switch result {
                case .success(let response):
                    self.apiClient.getBoundedToken(sso: response.sso, completion: completion)
                case .error(let error):
                    completion(.error(.api(error)))
            }
        }
    }
}

class ViewController: UIViewController {
    private var channelsService: ChannelsService!
    private var data: [ChannelsResponse.Channel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let settingsService = SettingsService()
        let apiClient = DomruAPIClient(deviceId: AppConstants.deviceId, authToken: settingsService.authToken)
        let authService = AuthService(apiClient: apiClient, settingService: settingsService)
        channelsService = ChannelsService(apiClient: apiClient)

        if !authService.isAuthorized {
            authService.login { result in
                switch result {
                    case .success:
                        self.loadData()
                    case .error(let error):
                        print(error.localizedDescription)
                }
            }
        } else {
            loadData()
        }
    }

    private func loadData() {
        channelsService.getChannelsList { result in
            switch result {
                case .success(let data):
                    self.data = data.items
                case .error(let error):
                    print(error.localizedDescription)
            }
        }
    }
}
