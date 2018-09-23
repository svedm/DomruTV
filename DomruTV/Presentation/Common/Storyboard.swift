//
//  Storyboard.swift
//  DomruTV
//
//  Created by Svetoslav Karasev on 22/09/2018.
//  Copyright © 2018 Svetoslav Karasev. All rights reserved.
//

import UIKit

enum Storyboard {
    static let channels = UIStoryboard(name: "Channels", bundle: nil)
    static let auth = UIStoryboard(name: "Auth", bundle: nil)
}

extension UIStoryboard {
    func instantiate<T: UIViewController>() -> T {
        let viewController = instantiateViewController(withIdentifier: String(describing: T.self))

        guard let typedViewController = viewController as? T else { fatalError("Cannot instantiate viewController") }

        return typedViewController
    }
}
