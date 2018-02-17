//
//  Command.swift
//  Babypi
//
//  Created by Alex on 27.12.17.
//  Copyright © 2017 Alexander Dobrynin. All rights reserved.
//

import Foundation

enum Command {
    case cameraOn, cameraOff, shutdown
}

fileprivate let ShellScriptReturnValue = ">/dev/null 2>&1; echo $?"

extension Command {
    var title: String {
        switch self {
        case .cameraOn: return "Stream an"
        case .cameraOff: return "Stream aus"
        case .shutdown: return "Pi herunterfahren"
        }
    }
    
    var shellScriptWithReturn: String {
        return shellScript.appending(ShellScriptReturnValue)
    }
    
    var shellScript: String {
        switch self {
        case .cameraOn: return "sudo /home/pi/Babypi/picam.sh start"
        case .cameraOff: return "sudo /home/pi/Babypi/picam.sh stop"
        case .shutdown: return "sudo shutdown -h now"
        }
    }
    
    func map<B>(f: (Command) -> B) -> B {
        return f(self)
    }
    
    static let all = [cameraOn, cameraOff, shutdown]
}
