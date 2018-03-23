//
//  Result.swift
//  Babypi
//
//  Created by Alex on 27.12.17.
//  Copyright © 2017 Alexander Dobrynin. All rights reserved.
//

import Foundation

enum Result<T> {
    case success(T)
    case failure(Error)
    
    func map<U>(_ f: (T) -> U) -> Result<U> {
        switch self {
        case .failure(let e): return .failure(e)
        case .success(let s): return .success(f(s))
        }
    }
}
