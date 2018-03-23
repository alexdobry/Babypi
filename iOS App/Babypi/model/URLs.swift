//
//  URLs.swift
//  Babypi
//
//  Created by Alex on 23.03.18.
//  Copyright © 2018 Alexander Dobrynin. All rights reserved.
//

import Foundation

struct URLs {
    private static let Base = "http://babypi.local"
    static let Webservice = URL(string: "\(Base):8080")!
    static let LiveStream = URL(string: "\(Base)/hls/index.m3u8")!
}
