//
//  Result.swift
//  DomruTV
//
//  Created by Svetoslav Karasev on 02/09/2018.
//  Copyright © 2018 Svetoslav Karasev. All rights reserved.
//

enum Result<T, E: Error> {
    case success(T)
    case error(E)
}
