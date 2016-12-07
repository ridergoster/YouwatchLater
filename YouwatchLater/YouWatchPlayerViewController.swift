//
//  YouWatchPlayerViewController.swift
//  YouwatchLater
//
//  Created by Vincent Kocupyr on 04/12/2016.
//  Copyright © 2016 Vincent Kocupyr. All rights reserved.
//

import UIKit
import YouTubePlayer
import SCLAlertView
import CoreData
import UserNotifications

class YouWatchPlayerViewController: UIViewController, YouTubePlayerDelegate {

    @IBOutlet weak var youtubePlayer: YouTubePlayerView!
    var video: YouWatchVideo?
    weak var delegate: YouWatchTableViewController!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(YouWatchPlayerViewController.back(sender:)))
        
        self.navigationItem.leftBarButtonItem = newBackButton
        
        self.youtubePlayer.delegate = self
        self.youtubePlayer.playerVars = [
            "playsinline": "1" as AnyObject,
            "showinfo": "0" as AnyObject
        ]
        
        if let data = video {
            self.youtubePlayer.loadVideoID(data.videoId!)
            self.titleLabel.text = data.name!
            self.descLabel.text = data.desc!
        }
        
    }
    
    func playerReady(_ videoPlayer: YouTubePlayerView) {
        self.youtubePlayer.play()
    }
    func playerStateChanged(_ videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {
       
    }
    func playerQualityChanged(_ videoPlayer: YouTubePlayerView, playbackQuality: YouTubePlaybackQuality) {
        
    }
    
    @IBAction func onClick(_ sender: UIBarButtonItem) {
        
        let alertView = SCLAlertView()
        
        if find(videoId: (video?.videoId)!) == true {
            alertView.addButton("Remove") {
                self.deleteItem()
            }
            alertView.showWarning("Remove video", subTitle: "Removing video from the list ?")
        } else {
            alertView.addButton("High") {
                self.saveItem(priority: "high")
            }
            alertView.addButton("Medium") {
                self.saveItem(priority: "medium")
            }
            alertView.addButton("Low") {
                self.saveItem(priority: "low")
            }
            alertView.showSuccess("Save video", subTitle: "Choose a priority for the video")
        }
    }
    
    func back(sender: UIBarButtonItem) {
        // Perform your custom actions
        self.youtubePlayer.stop()
        // Go back to the previous ViewController
        _ = navigationController?.popViewController(animated: true)
    }
    
    func saveItem(priority: String) {
        // save item
        
        if let context = DataManager.shared.objectContext {
            if let data = self.video {
                context.insert(data)
                try? context.save()
            }
        }
        
        var length = 0
        
        switch priority {
            case "high":
                length = 30
                break
            case "medium":
                length = 60
                break
            default:
                length = 120
        }
        
        self.notificationBuilder(length: length)
    }

    func deleteItem() {
        if let context = DataManager.shared.objectContext {
            if let data = self.video {
                context.delete(data)
                try? context.save()
            }
        }
    }
    
    func find(videoId: String)->Bool {
        if let context = DataManager.shared.objectContext {
            let request: NSFetchRequest<YouWatchVideo> = YouWatchVideo.fetchRequest()
            request.predicate = NSPredicate(format: "videoId contains[c] %@", videoId)
            if let results = try? context.fetch(request) {
                return results.count > 0 ? true : false
            }
            return false
        } else {
            return false
        }
    }
    
    func notificationBuilder(length: Int) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                let content = UNMutableNotificationContent()
                content.title = "Don't forget to Watch !"
                content.body = (self.video?.name)!
                content.sound = UNNotificationSound.default()
                
                let date = Date(timeIntervalSinceNow: TimeInterval(length))
                let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date)
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
                
                let identifier = "Notification\(self.video?.videoId!)"
                let request = UNNotificationRequest(identifier: identifier,
                                                    content: content, trigger: trigger)
                center.add(request, withCompletionHandler: { (error) in
                    if let error = error {
                        print(error)
                    }
                })
            }
        }
    }
}
