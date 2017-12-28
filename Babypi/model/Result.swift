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
}
