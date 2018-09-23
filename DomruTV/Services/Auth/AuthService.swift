//
//  AuthService.swift
//  DomruTV
//
//  Created by Svetoslav Karasev on 02/09/2018.
//  Copyright © 2018 Svetoslav Karasev. All rights reserved.
//

import Foundation

protocol AuthService {
    var isAuthorized: Bool { get }
    func login(login: String, password: String, completion: @escaping (Result<Void, DomruTVError>) -> Void)
}
