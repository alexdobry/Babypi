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
    private var session: NMSSHSession?
    private let validator: UnixResponseValidator
    private let connection: Connection
    private let queue: DispatchQueue
    
    weak var delegate: SSHServiceDelegate?
    
    var connected: Bool {
        guard let session = session else { return false }
        
        return session.isConnected && session.isAuthorized
    }
    
    init(connection: Connection,
         validator: UnixResponseValidator = DefaultUnixResponseValidator.shared,
         queue: DispatchQueue = .global(qos: .userInitiated)) {
        self.validator = validator
        self.connection = connection
        self.queue = queue
    }
    
    func execute(command: Command, defaultTimeout: Int = 5) {
        guard connected else {
            let error = NSError(domain: #file, code: -1, userInfo: [NSLocalizedDescriptionKey: "Not Connected to Pi"])
            delegate?.sshService(self, endExecutingCommand: .failure(error))
            return
        }
        
        delegate?.sshService(self, startExecutingCommand: command)
        
        var error: NSError?
        
        let timeout = command.map { c -> Int in
            if case .shutdown = c { return 10 } else { return defaultTimeout }
        }
        
        queue.async {
            var result: Result<UnixResponse>
            
            if let unixReturn = self.session?.channel.execute(command.shellScriptWithReturn, error: &error, timeout: timeout as NSNumber), error == nil {
                let response = self.validator.validate(reponse: unixReturn, command)
                
                result = Result.success(response)
            } else {
                result = Result.failure(error!)
            }
            
            DispatchQueue.main.async {
                self.delegate?.sshService(self, endExecutingCommand: result)
            }
        }
    }
    
    func connect() {
        queue.async {
            self.disconnect()
            
            self.session = NMSSHSession.connect(
                toHost: self.connection.host,
                withUsername: self.connection.username
            )
            
            var connectionEstablished: Bool
            
            if let session = self.session, session.isConnected, session.authenticate(byPassword: self.connection.password) {
                connectionEstablished = true
            } else {
                connectionEstablished = false
            }
            
            DispatchQueue.main.async {
                self.delegate?.sshService(self, connectionEstablished: connectionEstablished)
            }
        }
    }
    
    func disconnect() {
        session?.disconnect()
    }
}
