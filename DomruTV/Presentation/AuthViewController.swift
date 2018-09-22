//
//  AuthViewController.swift
//  DomruTV
//
//  Created by Svetoslav Karasev on 02/09/2018.
//  Copyright © 2018 Svetoslav Karasev. All rights reserved.
//

import UIKit

class AuthViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet private var loginField: UITextField!
    @IBOutlet private var passwordField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        passwordField.delegate = self
    }

    @IBAction private func login() {
        print("asd")
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        login()
        return true
    }
}
