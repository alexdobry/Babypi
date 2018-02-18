//
//  PlayerView.swift
//  Babypi
//
//  Created by Alex on 27.12.17.
//  Copyright © 2017 Alexander Dobrynin. All rights reserved.
//

import Foundation
import UIKit
import AVKit

/*
 An object that manages a player's visual output.
 https://developer.apple.com/documentation/avfoundation/avplayerlayer
*/

class PlayerView: UIView {
    
    private var player: AVPlayer? {
        get { return playerLayer.player }
        set { playerLayer.player = newValue }
    }
    
    private var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    // Override UIView property
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    // CUSTOM
    
    var height: CGFloat? {
        didSet {
            guard let height = height else { return }
            
            frame = CGRect(x: 0, y: 0, width: frame.width, height: height)
        }
    }
    
    var url: String? {
        didSet {
            if let url = url.flatMap(URL.init) {
                playerLayer.videoGravity = .resizeAspect
                
                player = AVPlayer(url: url)
                player?.play()
            } else {
                player = nil
            }
        }
    }
}
