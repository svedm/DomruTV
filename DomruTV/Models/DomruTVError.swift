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
}
