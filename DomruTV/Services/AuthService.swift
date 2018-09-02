//
//  AuthService.swift
//  DomruTV
//
//  Created by Svetoslav Karasev on 02/09/2018.
//  Copyright © 2018 Svetoslav Karasev. All rights reserved.
//

import Foundation

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
