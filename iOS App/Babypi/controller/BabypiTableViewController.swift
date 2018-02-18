//
//  BabypiTableViewController.swift
//  Babypi
//
//  Created by Alex on 27.12.17.
//  Copyright © 2017 Alexander Dobrynin. All rights reserved.
//

import UIKit

fileprivate extension Command {
    var section: Section {
        switch self {
        case .cameraOff, .cameraOn, .shutdown: return .command
        case .temperature: return .sensor
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
    
    func footerTitle(with sensorData: SensorData?) -> String? {
        guard let sensorData = sensorData else { return nil }
        
        switch self {
        case .sensor:
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            
            return "last modified at ".appending(formatter.string(from: sensorData.timestamp))
        case .command: return nil
        }
    }
    
    static func < (lhs: Section, rhs: Section) -> Bool {
        return lhs.hashValue < rhs.hashValue
    }
}

class BabypiTableViewController: UITableViewController {
    
    @IBOutlet weak private var playerView: UIView!
    
    private lazy var service: SSHService = {
        let defaults = UserDefaults.standard
        let connection = Connection(
            host: defaults.host ?? "",
            username: defaults.username ?? "",
            password: defaults.password ?? ""
        )
        
        let service = SSHService(connection: connection)
        service.delegate = self
        
        return service
    }()
    
    var commands: [(key: Section, value: [Command])] = [] {
        didSet { updateUI() }
    }
    
    private var sensorData: SensorData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupPlayerView()
        setupRefreshControl()
        
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
    
    private func setupTableView() {
        tableView.register(
            UINib(nibName: SensorTableViewCell.Identifier, bundle: nil),
            forCellReuseIdentifier: SensorTableViewCell.Identifier
        )
        
        tableView.register(
            UINib(nibName: CommandTableViewCell.Identifier, bundle: nil),
            forCellReuseIdentifier: CommandTableViewCell.Identifier
        )
    }
    
    private func setupPlayerView() {
        playerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 212)
        tableView.tableHeaderView = playerView
    }
    
    private func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .primaryColor
        refreshControl.attributedTitle = nil
        
        tableView.refreshControl = refreshControl
        tableView.refreshControl!.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView?.backgroundView?.layer.zPosition -= 1
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if !commands.isEmpty {
            tableView.backgroundView = nil
            
            return commands.count
        } else {
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text = "No connection \n Pull to reconnect"
            noDataLabel.textColor = .primaryColor
            noDataLabel.textAlignment = .center
            noDataLabel.numberOfLines = 2
            noDataLabel.font = .preferredFont(forTextStyle: .title1)
            
            tableView.backgroundView = noDataLabel
            
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commands[section].value.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let command = commands[indexPath.section].value[indexPath.row]
        
        switch command {
        case .cameraOff, .cameraOn, .shutdown:
            let cell = tableView.dequeueReusableCell(withIdentifier: CommandTableViewCell.Identifier, for: indexPath) as! CommandTableViewCell
            cell.title = command.title
            return cell
        case .temperature:
            let cell = tableView.dequeueReusableCell(withIdentifier: SensorTableViewCell.Identifier, for: indexPath) as! SensorTableViewCell
            cell.configure(withTemperature: sensorData?.temperature ?? 0.0, andHumidity: sensorData?.humidity ?? 0.0)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return commands[section].key.headerTitle
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return commands[section].key.footerTitle(with: sensorData)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer { tableView.deselectRow(at: indexPath, animated: true) }
        
        let command = commands[indexPath.section].value[indexPath.row]
        service.execute(command: command, defaultTimeout: command.timeout)
    }
    
    @objc func refresh(_ sender: UIRefreshControl) {
        sender.attributedTitle = NSAttributedString(string: "reconnecting to raspbery pi ...")
        
        service.connect()
    }
    
    private var playerViewController: BabypiPlayerViewController?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case "EmbededSegue":
            playerViewController = segue.destination as? BabypiPlayerViewController
            
        default: break
        }
    }
    
    // MARK: - Helper
    
    private func updateUI() {
        tableView.reloadData()
        
        showPlayer(true)
    }
    
    private func showPlayer(_ bool: Bool) { // TODO: add and remove from view
        if bool {
            playerViewController!.play()
//            tableView.tableHeaderView = playerView
        } else {
            playerViewController!.stop()
//            tableView.tableHeaderView = nil
        }
    }
}

extension BabypiTableViewController: SSHServiceDelegate {
    
    func sshService(_ service: SSHService, connectionEstablished bool: Bool) {
        debugPrint(#function, bool)
        
        if refreshControl?.isRefreshing ?? false {
            refreshControl?.endRefreshing()
        }
        
        if bool {
            self.commands = Command.all.groupBy(key: { $0.section }).sorted(by: { $0.key < $1.key })
        } else {
            self.commands.removeAll()
        }
    }
    
    func sshService(_ service: SSHService, startExecutingCommand command: Command) {
        debugPrint(#function, command)

        if let refreshControl = refreshControl {
            let offset = CGPoint(x: 0, y: tableView.contentOffset.y - refreshControl.frame.size.height)
            tableView.setContentOffset(offset, animated: true)
         
            refreshControl.beginRefreshing()
            refreshControl.attributedTitle = NSAttributedString(string: "executing \(command.title)")
        }
    }
    
    func sshService(_ service: SSHService, endExecutingCommand result: Result<UnixResponse>) {
        debugPrint(#function, result)
        
        if refreshControl?.isRefreshing ?? false {
            refreshControl?.endRefreshing()
        }
        
        var message: String
        
        switch result {
        case .success(let response):
            switch response {
            case let .binary(success, command):
                switch command {
                case .cameraOff: showPlayer(false)
                case .cameraOn: showPlayer(true)
                case .shutdown, .temperature: break
                }
                
                message = "\"\(command.title)\" \(success ? " was executed successfully" : "failed")"
                
            case let .data(value, command):
                self.sensorData = value.data(using: .utf8).flatMap { data -> SensorData? in
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    return try? decoder.decode(SensorData.self, from: data)
                }
                
                message = "\"\(command.title)\" value is \(sensorData.debugDescription)"
            }

        case .failure(let error):
            message = "error message: \(error.localizedDescription)"
        }
        
        tableView.reloadData()
        
        let alert = UIAlertController(title: "Execution Result", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        alert.view.tintColor = .primaryColor
        
        present(alert, animated: true, completion: nil)
    }
}
