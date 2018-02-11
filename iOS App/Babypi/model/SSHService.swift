//
//  SSHService.swift
//  Babypi
//
//  Created by Alex on 24.12.17.
//  Copyright © 2017 Alexander Dobrynin. All rights reserved.
//

import Foundation

struct Connection {
    let host: String
    let username: String
    let password: String
}

protocol SSHServiceDelegate: class {
    func sshService(_ service: SSHService, connectionEstablished bool: Bool)
    func sshService(_ service: SSHService, startExecutingCommand command: Command)
    func sshService(_ service: SSHService, endExecutingCommand result: Result<UnixResponse>)
}

final class SSHService {
    private let session: NMSSHSession
    private let validator: UnixResponseValidator
    
    weak var delegate: SSHServiceDelegate?
    
    init(connection: Connection, validator: UnixResponseValidator = DefaultUnixResponseValidator.shared) {
        self.validator = validator
        session = NMSSHSession.connect(toHost: connection.host, withUsername: connection.username)
        
        if session.isConnected && session.authenticate(byPassword: connection.password){
            delegate?.sshService(self, connectionEstablished: true)
        } else {
            delegate?.sshService(self, connectionEstablished: false)
        }
    }
    
    func execute(command: Command, defaultTimeout: Int = 5) {
        delegate?.sshService(self, startExecutingCommand: command)
        
        var error: NSError?
        
        let timeout = command.map { c -> Int in
            if case .shutdown = c { return 10 } else { return defaultTimeout }
        }
        
        if let result = session.channel.execute(command.shellScript, error: &error, timeout: timeout as NSNumber), error == nil {
            let response = validator.validate(reponse: result, command)
            
            delegate?.sshService(self, endExecutingCommand: Result.success(response))
        } else {
            delegate?.sshService(self, endExecutingCommand: Result.failure(error!))
        }
    }
    
    func disconnect() {
        session.disconnect()
    }
}
