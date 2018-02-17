//
//  BabypiTableViewController.swift
//  Babypi
//
//  Created by Alex on 27.12.17.
//  Copyright © 2017 Alexander Dobrynin. All rights reserved.
//

import UIKit
import AVKit

fileprivate extension BabypiDashboard {
    var section: Section {
        switch self {
        case .sensor: return .sensor
        case .command: return .command
        }
    }
}

fileprivate extension Command {
    var title: String {
        switch self {
        case .on: return "Stream an"
        case .off: return "Stream aus"
        case .shutdown: return "Pi herunterfahren"
        }
    }
}

enum Section: Hashable {
    case sensor, command
    
    var headerTitle: String? {
        switch self {
        case .sensor: return nil
        case .command: return "Babypi steuern"
        }
    }
    
    static func < (lhs: Section, rhs: Section) -> Bool {
        return lhs.hashValue < rhs.hashValue
    }
}

class BabypiTableViewController: UITableViewController {

    @IBOutlet weak var playerView: PlayerView!
    
    private var connected: Bool = true
    
    var dashboard: [(key: Section, value: [BabypiDashboard])] = [] {
        didSet { tableView.reloadData() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(
            UINib(nibName: SensorTableViewCell.Identifier, bundle: nil),
            forCellReuseIdentifier: SensorTableViewCell.Identifier
        )
        
        playerView.height = 300
        
        let dashboard = Command.all.map(BabypiDashboard.command) + [BabypiDashboard.sensor(data: SensorData(temperature: 21.5, humidity: 80))]
        self.dashboard = dashboard.groupBy(key: { $0.section }).sorted(by: { $0.key < $1.key })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        playerView.url = "http://babypi.local/hls/index.m3u8"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        playerView.url = nil
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if connected {
            tableView.tableHeaderView = playerView
            
            return dashboard.count
        } else {
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text = "No Data Available"
            noDataLabel.textColor = UIColor(red: 22.0/255.0, green: 106.0/255.0, blue: 176.0/255.0, alpha: 1.0)
            noDataLabel.textAlignment = NSTextAlignment.center
            
            tableView.backgroundView = noDataLabel
            tableView.tableHeaderView = nil
            
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dashboard[section].value.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch dashboard[indexPath.section].value[indexPath.row] {
        case let .command(value):
            let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
            cell.textLabel?.text = value.title
            return cell
        case let .sensor(data):
            let cell = tableView.dequeueReusableCell(withIdentifier: SensorTableViewCell.Identifier, for: indexPath) as! SensorTableViewCell
            cell.configure(withTemperature: data.temperature, andHumidity: data.humidity)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dashboard[section].key.headerTitle
    }
}
