//
//  DomruTVError.swift
//  DomruTV
//
//  Created by Svetoslav Karasev on 02/09/2018.
//  Copyright © 2018 Svetoslav Karasev. All rights reserved.
//

enum DomruTVError: Error {
    case network(Error)
    case api(Error)

    var localizedDescription: String {
        switch self {
            case .network(let error):
                return error.localizedDescription
            case .api(let error):
                return error.localizedDescription
        }
    }
}
