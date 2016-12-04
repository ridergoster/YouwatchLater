//
//  YouWatchPlayerViewController.swift
//  YouwatchLater
//
//  Created by Vincent Kocupyr on 04/12/2016.
//  Copyright © 2016 Vincent Kocupyr. All rights reserved.
//

import UIKit
import YouTubePlayer

class YouWatchPlayerViewController: UIViewController, YouTubePlayerDelegate {

    @IBOutlet weak var youtubePlayer: YouTubePlayerView!
    var videoId: String = ""
    weak var delegate: YouWatchTableViewController!
    
    @IBOutlet weak var loadVideo: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(YouWatchPlayerViewController.back(sender:)))
        
        self.navigationItem.leftBarButtonItem = newBackButton
        
        self.youtubePlayer.delegate = self
        self.youtubePlayer.loadVideoID(self.videoId)
    }
    
    func playerReady(_ videoPlayer: YouTubePlayerView) {
        self.youtubePlayer.play()
    }
    func playerStateChanged(_ videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {
       
    }
    func playerQualityChanged(_ videoPlayer: YouTubePlayerView, playbackQuality: YouTubePlaybackQuality) {
        
    }
    
    
    func back(sender: UIBarButtonItem) {
        // Perform your custom actions
        self.youtubePlayer.stop()
        // Go back to the previous ViewController
        _ = navigationController?.popViewController(animated: true)
    }
}
