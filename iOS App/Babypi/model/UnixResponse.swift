//
//  UnixResponse.swift
//  Babypi
//
//  Created by Alex on 27.12.17.
//  Copyright © 2017 Alexander Dobrynin. All rights reserved.
//

import Foundation

enum UnixResponse {
    case binary(success: Bool, command: Command)
    case data(value: String, command: Command)
}

protocol UnixResponseValidator {
    func validate(reponse: String, _ command: Command) -> UnixResponse
}

struct DefaultUnixResponseValidator: UnixResponseValidator {
    
    static let shared = DefaultUnixResponseValidator()
    
    private init() { }
    
    func validate(reponse: String, _ command: Command) -> UnixResponse {
        if command.shouldValidate {
            return .binary(success: reponse.contains("0"), command: command)
        } else {
            return .data(value: reponse, command: command)
        }
    }
}
