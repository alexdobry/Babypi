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
    
    private var indicator: UIActivityIndicatorView!
    
    private var commands: [(key: Section, value: [Command])] = [] {
        didSet { updateUI() }
    }
    
    private var sensorData: SensorData?
    
    var didTapSettings: () -> () = {}
    var viewModel: WebbasedBabypiViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupPlayerView()
        setupRefreshControl()
        
        viewModel.delegate = self
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
        
        commands = Dictionary(grouping: Command.all, by: { $0.section }).sorted(by: { $0.key < $1.key })
    }
    
    private func setupPlayerView() {
        playerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 212)
        tableView.tableHeaderView = playerView
    }
    
    private func setupRefreshControl() {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        view.addSubview(indicator)
        
        indicator.tintColor = .primaryColor
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        indicator.isUserInteractionEnabled = false
        
        self.indicator = indicator
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return commands.count
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
        tableView.deselectRow(at: indexPath, animated: true)
        
        let command = commands[indexPath.section].value[indexPath.row]
        
        switch command {
        case .shutdown:
            let shutDownAction = UIAlertAction(title: "Shutdown", style: .destructive, handler: { _ in
                self.viewModel.perform(command: command)
            })
            
            presentAlert(title: "Realy want to shut down?", message: nil, defaultAction: shutDownAction)
            
        case _: viewModel.perform(command: command)
        }
    }
    
    @IBAction func showSettings(_ sender: Any) {
        didTapSettings()
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

    }
    
    private func showPlayer(_ bool: Bool) { // TODO: add and remove from view
        if bool {
            playerViewController!.play()
        } else {
            playerViewController!.stop()
        }
    }
    
    private func presentAlert(title: String, message: String?, defaultAction: UIAlertAction?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if let action = defaultAction {
            alert.addAction(action)
        }
        
        present(alert, animated: true, completion: nil)
    }
}

extension BabypiTableViewController: WebbasedBabypiViewModelDelegate {
    func didStartRequest(for command: Command) {
        indicator.startAnimating()
    }
    
    func didEndRequest(for command: Command, with result: Result<WebbasedReturn>) {
        indicator.stopAnimating()
        
        switch result {
        case .success(let s):
            switch s {
            case .sensorData(let sensor):
                sensorData = sensor
                tableView.reloadSections(IndexSet(integer: Section.sensor.hashValue), with: .automatic)
                
            case .simpleResponse(let response):
                switch command {
                case .cameraOn where response.status == "ok" : showPlayer(true)
                case .cameraOn, .cameraOff: showPlayer(false)
                case .shutdown, .temperature: break
                }
                
                presentAlert(title: response.status, message: response.message, defaultAction: nil)
            }
        case .failure(let e):
            presentAlert(title: "Server Error", message: e.localizedDescription, defaultAction: nil)
        }
    }
}
