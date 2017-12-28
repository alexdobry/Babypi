//
//  UnixResponse.swift
//  Babypi
//
//  Created by Alex on 27.12.17.
//  Copyright © 2017 Alexander Dobrynin. All rights reserved.
//

import Foundation

struct UnixResponse {
    let success: Bool
    let command: Command
}

protocol UnixResponseValidator {
    func validate(reponse: String, _ command: Command) -> UnixResponse
}

struct DefaultUnixResponseValidator: UnixResponseValidator {
    
    static let shared = DefaultUnixResponseValidator()
    
    private init() { }
    
    func validate(reponse: String, _ command: Command) -> UnixResponse {
        return UnixResponse(success: reponse.contains("0"), command: command)
    }
}
