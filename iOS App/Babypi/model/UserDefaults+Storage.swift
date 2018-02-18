//
//  UserDefaults+Storage.swift
//  Babypi
//
//  Created by Alex on 18.02.18.
//  Copyright © 2018 Alexander Dobrynin. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    var host: String? {
        get { return string(forKey: #function) }
        set { set(newValue, forKey: #function) }
    }
    
    var username: String? {
        get { return string(forKey: #function) }
        set { set(newValue, forKey: #function) }
    }
    
    var password: String? {
        get { return string(forKey: #function) }
        set { set(newValue, forKey: #function) }
    }
}
