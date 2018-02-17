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

enum Section: Hashable {
    case sensor, command
    
    var headerTitle: String? {
        switch self {
        case .sensor: return nil
        case .command: return "Babypi steuern"
        }
    }
    
    var clickable: Bool {
        switch self {
        case .sensor: return false
        case .command: return true
        }
    }
    
    static func < (lhs: Section, rhs: Section) -> Bool {
        return lhs.hashValue < rhs.hashValue
    }
}

class BabypiTableViewController: UITableViewController {

    @IBOutlet weak var playerView: PlayerView! {
        didSet { playerView.height = 300 }
    }
    
    private lazy var service: SSHService = {
        let connection = Connection(
            host: "pi@babypi.local",
            username: "pi",
            password: "Xvne{X9mEXC?f,83n}saGWJxxPmcY6{/)y9aqe7cF8Pqhxz#zXNc))6C4MeBEt7B"
        )
        
        let service = SSHService(connection: connection)
        service.delegate = self
        
        return service
    }()
    
    var dashboard: [(key: Section, value: [BabypiDashboard])] = [] {
        didSet { updateUI() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(
            UINib(nibName: SensorTableViewCell.Identifier, bundle: nil),
            forCellReuseIdentifier: SensorTableViewCell.Identifier
        )
        
        tableView.register(
            UINib(nibName: CommandTableViewCell.Identifier, bundle: nil),
            forCellReuseIdentifier: CommandTableViewCell.Identifier
        )
        
        service.connect()
    }
    
    private var backgroundObserver: NSObjectProtocol?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        backgroundObserver = NotificationCenter.default.addObserver(
            forName: .UIApplicationDidEnterBackground,
            object: nil,
            queue: OperationQueue.main) { _ in
                self.service.disconnect()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let backgroundObserver = backgroundObserver {
            NotificationCenter.default.removeObserver(backgroundObserver)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if !dashboard.isEmpty {
            tableView.tableHeaderView = playerView
            tableView.backgroundView = nil
            
            return dashboard.count
        } else {
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text = "No connection \n Pull to reconnect"
            noDataLabel.textColor = .primaryColor
            noDataLabel.textAlignment = .center
            noDataLabel.numberOfLines = 2
            noDataLabel.font = .preferredFont(forTextStyle: .title1)
            
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
            let cell = tableView.dequeueReusableCell(withIdentifier: CommandTableViewCell.Identifier, for: indexPath) as! CommandTableViewCell
            cell.title = value.title
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
    
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return dashboard[indexPath.section].key.clickable
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer { tableView.deselectRow(at: indexPath, animated: true) }
        
        switch dashboard[indexPath.section].value[indexPath.row] {
        case .command(let value): service.execute(command: value)
        case .sensor: break
        }
    }
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        service.connect()
    }
    
    private func updateUI() {
        tableView.reloadData()
        
        showPlayer(true)
    }
    
    private func showPlayer(_ bool: Bool) { // TODO: add and remove from view
        playerView.url = bool ? "http://babypi.local/hls/index.m3u8" : nil
    }
    
    private func indexPath(for command: Command) -> IndexPath? {
        return dashboard.flatMap { (section, value) -> IndexPath? in
            let row = value.enumerated().first { _, dash in
                switch dash {
                case .command(let c): return c.hashValue == command.hashValue
                case .sensor: return false
                }
            }?.offset
            
            if let row = row {
                return IndexPath(row: row, section: section.hashValue)
            } else {
                return nil
            }
        }.first
    }
    
    private func commandTableViewCell(for command: Command) -> CommandTableViewCell? {
        guard let indexPath = indexPath(for: command) else { return nil }
        return tableView.cellForRow(at: indexPath) as? CommandTableViewCell
    }
}

extension BabypiTableViewController: SSHServiceDelegate {
    
    func sshService(_ service: SSHService, connectionEstablished bool: Bool) {
        debugPrint(#function, bool)
        
        if refreshControl?.isRefreshing ?? false {
            refreshControl?.endRefreshing()
        }
        
        if bool {
            let dashboard = Command.all.map(BabypiDashboard.command) + [BabypiDashboard.sensor(data: SensorData(temperature: 21.5, humidity: 80))]
            
            self.dashboard = dashboard.groupBy(key: { $0.section }).sorted(by: { $0.key < $1.key })
        } else {
            self.dashboard.removeAll()
        }
    }
    
    func sshService(_ service: SSHService, startExecutingCommand command: Command) {
        debugPrint(#function, command)
        
        commandTableViewCell(for: command)?.spinning = true
    }
    
    func sshService(_ service: SSHService, endExecutingCommand result: Result<UnixResponse>) {
        debugPrint(#function, result)
        
        var message: String
        
        switch result {
        case .success(let response):
            commandTableViewCell(for: response.command)?.spinning = false
            
            switch response.command {
            case .cameraOff: showPlayer(false)
            case .cameraOn: showPlayer(true)
            case .shutdown: break
            }
            
            message = "\"\(response.command.title)\" \(response.success ? " was executed successfully" : "failed")"
        case .failure(let error):
            message = "error message: \(error.localizedDescription)"
        }
        
        let alert = UIAlertController(title: "Execution Result", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        alert.view.tintColor = .primaryColor
        
        present(alert, animated: true, completion: nil)
    }
}
