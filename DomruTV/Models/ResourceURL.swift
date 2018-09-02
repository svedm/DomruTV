//
//  ResourceURL.swift
//  DomruTV
//
//  Created by Svetoslav Karasev on 02/09/2018.
//  Copyright © 2018 Svetoslav Karasev. All rights reserved.
//

import Foundation

struct ResourceURL: DomruAPIResponse, Decodable {
    var result: Int
    var url: URL
}
