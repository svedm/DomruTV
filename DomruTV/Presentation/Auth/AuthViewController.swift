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

    struct Actions {
        var login: (_ login: String, _ password: String, _ failure: @escaping (Error) -> Void) -> Void
    }

    var actions: Actions!

    override func viewDidLoad() {
        super.viewDidLoad()

        passwordField.delegate = self
    }

    @IBAction private func login() {
        guard
            let login = loginField.text, !login.isEmpty,
            let password = passwordField.text, !password.isEmpty
        else { return }

        actions.login(login, password) { _ in
            let controller = UIAlertController(title: "Error", message: "Wrong login or password", preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(controller, animated: true, completion: nil)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        login()
        return true
    }
}
