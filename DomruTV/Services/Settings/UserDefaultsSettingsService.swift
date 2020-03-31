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
		string(for: .authToken)
    }
    func setAuthToken(_ token: String) {
        set(token, for: .authToken)
    }

    var deviceId: String {
        "7247EE41-5FBE-4C93-A4EF-B910DC57F0B9"
//        return string(for: .deviceId) ?? createDeviceId()
        // TODO: implement bound logic
    }

    private func createDeviceId() -> String {
        let deviceId = UUID().uuidString
        set(deviceId, for: .deviceId)
        return deviceId
    }

    private func string(for key: Setting) -> String? {
        userDefaults.string(forKey: key.rawValue)
    }

    private func set(_ value: Any?, for key: Setting) {
        userDefaults.set(value, forKey: key.rawValue)
        userDefaults.synchronize()
    }
}
