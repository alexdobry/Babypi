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
        
        
        try! AVAudioSession.sharedInstance().setCategory(.playback)
        
        play()
    }
    
    func play() {
        player = AVPlayer(url: URLs.LiveStream)
        player!.seek(to: CMTime.positiveInfinity)
        player!.play()
    }
    
    func stop() {
        player = nil
    }
}
