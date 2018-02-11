//
//  Command.swift
//  Babypi
//
//  Created by Alex on 27.12.17.
//  Copyright © 2017 Alexander Dobrynin. All rights reserved.
//

import Foundation

enum Command {
    case on, off, shutdown
}

extension Command {
    var shellScript: String {
        switch self {
        case .on: return ""
        case .off: return ""
        case .shutdown: return "sudo shutdown -h now; echo $?"
        }
    }
    
    func map<B>(f: (Command) -> B) -> B {
        return f(self)
    }
    
    static let all = [on, off, shutdown]
}
