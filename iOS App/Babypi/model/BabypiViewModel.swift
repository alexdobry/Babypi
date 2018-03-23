//
//  BabypiViewModel.swift
//  Babypi
//
//  Created by Alex on 21.03.18.
//  Copyright © 2018 Alexander Dobrynin. All rights reserved.
//

import Foundation

enum WebbasedReturn {
    case simpleResponse(r: SimpleResponse)
    case sensorData(s: SensorData)
}

struct SimpleResponse: Codable {
    let status: String
    let message: String
}

protocol WebbasedBabypiViewModelDelegate: class {
    func didStartRequest(for command: Command)
    func didEndRequest(for command: Command, with result: Result<WebbasedReturn>)
}

final class WebbasedBabypiViewModel {
    
    private let webservice: Webservice
    private let baseUrl: URL
    private let decoder: JSONDecoder
    
    weak var delegate: WebbasedBabypiViewModelDelegate?
    
    init(baseUrl: URL, webservice: Webservice = Webservice(), decoder: JSONDecoder = JSONDecoder()) {
        decoder.dateDecodingStrategy = .secondsSince1970
        
        self.decoder = decoder
        self.webservice = webservice
        self.baseUrl = baseUrl
    }
    
    func perform(command: Command) {
        delegate?.didStartRequest(for: command)
        
        switch command {
        case .cameraOn, .cameraOff:
            let r =  Ressource(
                url: baseUrl.appendingPathComponent("camera"),
                body: ["state" : command == .cameraOn ? "on" : "off"],
                method: "POST",
                parse: { try self.decoder.decode(SimpleResponse.self, from: $0) }
            )
            
            webservice.request(ressource: r, completion: { result in
                self.delegate?.didEndRequest(for: command, with: result.map { WebbasedReturn.simpleResponse(r: $0) })
            })
        case .shutdown:
            let r = Ressource(
                url: baseUrl.appendingPathComponent("babypi"),
                body: [:],
                method: "DELETE",
                parse: { try self.decoder.decode(SimpleResponse.self, from: $0) }
            )
            
            webservice.request(ressource: r, completion: { result in
                self.delegate?.didEndRequest(for: command, with: result.map { WebbasedReturn.simpleResponse(r: $0) })
            })
        case .temperature:
            let r = Ressource(
                url: baseUrl.appendingPathComponent("dht22"),
                body: [:],
                method: "GET",
                parse: { try self.decoder.decode(SensorData.self, from: $0) }
            )
            
            webservice.request(ressource: r, completion: { result in
                self.delegate?.didEndRequest(for: command, with: result.map { WebbasedReturn.sensorData(s: $0) })
            })
        }
    }
}
