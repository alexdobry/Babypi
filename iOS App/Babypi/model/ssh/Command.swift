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

extension Command {
    var title: String {
        switch self {
        case .temperature: return "Temperatur & Luftfeuchtigkeit"
        case .cameraOn: return "Stream an"
        case .cameraOff: return "Stream aus"
        case .shutdown: return "Pi herunterfahren"
        }
    }
    
    static let all = [cameraOn, cameraOff, temperature, shutdown]
}
