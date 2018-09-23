//
//  SettingsService.swift
//  DomruTV
//
//  Created by Svetoslav Karasev on 02/09/2018.
//  Copyright © 2018 Svetoslav Karasev. All rights reserved.
//

import Foundation

class UserDefaultsSettingsService: SettingsService {
    private var userDefaults: UserDefaults = UserDefaults.standard
    private enum Setting: String {
        case authToken = "authToken"
        case deviceId = "deviceId"
    }

    var authToken: String? {
        return string(for: .authToken)
    }
    func setAuthToken(_ token: String) {
        set(token, for: .authToken)
    }

    var deviceId: String {
        return string(for: .deviceId) ?? createDeviceId()
    }

    private func createDeviceId() -> String {
        let deviceId = UUID().uuidString
        set(deviceId, for: .deviceId)
        return deviceId
    }

    private func string(for key: Setting) -> String? {
        return userDefaults.string(forKey: key.rawValue)
    }

    private func set(_ value: Any?, for key: Setting) {
        userDefaults.set(value, forKey: key.rawValue)
        userDefaults.synchronize()
    }
}
