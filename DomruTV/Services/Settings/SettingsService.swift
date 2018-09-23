//
//  SettingsService.swift
//  DomruTV
//
//  Created by Svetoslav Karasev on 22/09/2018.
//  Copyright © 2018 Svetoslav Karasev. All rights reserved.
//

import Foundation

protocol SettingsService {
    var authToken: String? { get }
    func setAuthToken(_ token: String)
    var deviceId: String { get }
}
