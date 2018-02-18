//
//  Command.swift
//  Babypi
//
//  Created by Alex on 27.12.17.
//  Copyright © 2017 Alexander Dobrynin. All rights reserved.
//

import Foundation

enum Command {
    case cameraOn, cameraOff, temperature, shutdown
}

fileprivate let ShellScriptReturnValue = ">/dev/null 2>&1; echo $?"

extension Command {
    var title: String {
        switch self {
        case .temperature: return "Temperatur & Luftfeuchtigkeit"
        case .cameraOn: return "Stream an"
        case .cameraOff: return "Stream aus"
        case .shutdown: return "Pi herunterfahren"
        }
    }
    
    var shellScript: String {
        switch self {
        case .temperature: return "sudo /home/pi/Babypi/dht22.py"
        case .cameraOn: return "sudo /home/pi/Babypi/picam.sh start".appending(ShellScriptReturnValue)
        case .cameraOff: return "sudo /home/pi/Babypi/picam.sh stop".appending(ShellScriptReturnValue)
        case .shutdown: return "sudo shutdown -h now".appending(ShellScriptReturnValue)
        }
    }
    
    var shouldValidate: Bool {
        switch self {
        case .cameraOn, .cameraOff: return true
        case .temperature, .shutdown: return false
        }
    }
    
    var timeout: Int {
        switch self {
        case .temperature: return 6
        case .cameraOff, .cameraOn: return 3
        case .shutdown: return 10
        }
    }
    
    func map<B>(f: (Command) -> B) -> B {
        return f(self)
    }
    
    static let all = [cameraOn, cameraOff, temperature, shutdown]
}
