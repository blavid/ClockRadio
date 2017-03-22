//
//  Radio.swift
//  ClockRadio
//
//  Created by Blake Clough on 3/21/17.
//  Copyright © 2017 Blake Clough. All rights reserved.
//

import Foundation
import AVFoundation

class Radio {
    // prevent others from initing this class outside of the singlton
    private init() {
        opbUrl = URL(string:"http://stream1.opb.org/radio.mp3")!
        player = AVPlayer(url: opbUrl)
        let player2 = AVPlayerItem(url: opbUrl)
    }
    
    // The one-line singlton
    static let sharedInstance = Radio()
    var opbUrl: URL
    var player: AVPlayer
    var isPlaying = false
    
    func play() {
        player.play()
        isPlaying = true
    }
    
    func pause() {
        player.pause()
        player.
        isPlaying = false
    }
    
    func toggle() {
        if isPlaying == true {
            pause()
        } else {
            play()
        }
    }
    
}
