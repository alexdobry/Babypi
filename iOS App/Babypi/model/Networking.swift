    //
//  Networking.swift
//  Babypi
//
//  Created by Alex on 21.03.18.
//  Copyright © 2018 Alexander Dobrynin. All rights reserved.
//

import Foundation

struct Ressource<T> {
    let url: URL
    let body: [String: Any]
    let method: String
    let parse: (Data) throws -> T
}

final class Webservice {
    
    func request<T>(ressource: Ressource<T>, timeout: TimeInterval = 5.0, completion: @escaping (Result<T>) -> Void) {
        var request = URLRequest(url: ressource.url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: timeout)
        request.httpMethod = ressource.method
        
        if !ressource.body.isEmpty {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: ressource.body, options: [])
        }
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            let result: Result<T>
            
            if let error = error {
                result = .failure(error)
            } else {
                do {
                    let json = try ressource.parse(data!)
                    
                    result = .success(json)
                } catch let parseError {
                    result = .failure(parseError)
                }
            }
            
            DispatchQueue.main.async {
                completion(result)
            }
        }.resume()
    }
}
