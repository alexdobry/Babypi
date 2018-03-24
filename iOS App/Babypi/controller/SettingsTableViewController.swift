//
//  SettingsTableViewController.swift
//  Babypi
//
//  Created by Alex on 18.02.18.
//  Copyright © 2018 Alexander Dobrynin. All rights reserved.
//

import UIKit

extension String {
    var nilIfEmpty: String? {
        return isEmpty ? nil : self
    }
}

final class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var hostTextField: UITextField!
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    private let defaults = UserDefaults.standard
    
    var didTapDone: () -> () = { }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Settings"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        
        [hostTextField, userTextField, passwordTextField].forEach { $0?.delegate = self }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hostTextField.text = defaults.host
        userTextField.text = defaults.username
        passwordTextField.text = defaults.password
    }
    
    deinit { debugPrint(#file, #function) }
    
    @objc func done() {
        defaults.host = hostTextField.text?.nilIfEmpty
        defaults.username = userTextField.text?.nilIfEmpty
        defaults.password = passwordTextField.text?.nilIfEmpty
        
        didTapDone()
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

extension SettingsTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
