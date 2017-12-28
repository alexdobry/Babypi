//
//  BabypiDashboard.swift
//  Babypi
//
//  Created by Alex on 27.12.17.
//  Copyright © 2017 Alexander Dobrynin. All rights reserved.
//

import Foundation

struct SensorData {
    let temperature: Double
    let humidity: Double
}

enum BabypiDashboard {
    case sensor(data: SensorData)
    case command(value: Command)
}
