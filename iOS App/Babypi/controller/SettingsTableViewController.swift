//
//  SettingsTableViewController.swift
//  Babypi
//
//  Created by Alex on 18.02.18.
//  Copyright © 2018 Alexander Dobrynin. All rights reserved.
//

import UIKit

final class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var hostTextField: UITextField!
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    private let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        
        [hostTextField, userTextField, passwordTextField].forEach { $0?.delegate = self }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hostTextField.text = defaults.host
        userTextField.text = defaults.username
        passwordTextField.text = defaults.password
    }
    
    @IBAction func done(_ sender: Any) {
        defaults.host = hostTextField.text
        defaults.username = userTextField.text
        defaults.password = passwordTextField.text
        
        dismiss(animated: true, completion: nil)
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
