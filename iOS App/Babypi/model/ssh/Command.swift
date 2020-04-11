//
//  Command.swift
//  Babypi
//
//  Created by Alex on 27.12.17.
//  Copyright © 2017 Alexander Dobrynin. All rights reserved.
//

import Foundation

enum Command {
    case cameraOn, cameraOff, shutdown, record, reboot
}

extension Command {
    var title: String {
        switch self {
        case .cameraOn: return "Stream an"
        case .cameraOff: return "Stream aus"
        case .shutdown: return "Pi herunterfahren"
        case .record: return "Video aufzeichnen"
        case .reboot: return "Pi neustarten"
        }
    }
    
    static let all = [record, cameraOn, cameraOff, reboot, shutdown]
}
