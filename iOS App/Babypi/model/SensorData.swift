//
//  SensorData.swift
//  Babypi
//
//  Created by Alex on 27.12.17.
//  Copyright © 2017 Alexander Dobrynin. All rights reserved.
//

import Foundation

struct SensorData: Codable {
    let temperature: Double
    let humidity: Double
    let timestamp: Date
}
