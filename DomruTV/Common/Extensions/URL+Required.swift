//
//  URL+Required.swift
//  DomruTV
//
//  Created by Svetoslav Karasev on 02/09/2018.
//  Copyright © 2018 Svetoslav Karasev. All rights reserved.
//

import Foundation

extension URL {
    static func fromRequired(string: String) -> URL {
        guard let url = URL(string: string) else { fatalError("URL must be valid") }

        return url
    }
}
