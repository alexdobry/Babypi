//
//  SensorTableViewCell.swift
//  Babypi
//
//  Created by Alex on 27.12.17.
//  Copyright © 2017 Alexander Dobrynin. All rights reserved.
//

import UIKit

class SensorTableViewCell: UITableViewCell {

    static let Identifier = "SensorTableViewCell"
    
    @IBOutlet private weak var temperatureLabel: UILabel!
    @IBOutlet private weak var humidityLabel: UILabel!
    
    func configure(withTemperature t: Double, andHumidity h: Double) {
        temperatureLabel.text = t.description
        humidityLabel.text = h.description
    }
}
