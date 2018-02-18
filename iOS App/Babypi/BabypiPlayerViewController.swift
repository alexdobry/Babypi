//
//  BabypiPlayerViewController.swift
//  Babypi
//
//  Created by Alex on 24.12.17.
//  Copyright © 2017 Alexander Dobrynin. All rights reserved.
//

import UIKit
import AVKit

class BabypiPlayerViewController: AVPlayerViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        play()
    }
    
    func play() {
        player = AVPlayer(url: URL(string: "http://babypi.local/hls/index.m3u8")!)
        player!.play()
    }
    
    func stop() {
        player!.pause()
        player = nil
    }
}
