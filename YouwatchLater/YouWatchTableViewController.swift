//
//  YouWatchTableViewController.swift
//  YouwatchLater
//
//  Created by Vincent Kocupyr on 04/12/2016.
//  Copyright © 2016 Vincent Kocupyr. All rights reserved.
//

import UIKit
import Alamofire
import UserNotifications
import CoreData

class YouWatchTableViewController: UITableViewController, UISearchBarDelegate {

    
    var items = [YouWatchVideo]()
    var query: String = ""
    var pageToken: String = ""
    var isList: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let searchBar = UISearchBar()
        searchBar.showsCancelButton = false
        searchBar.placeholder = "Search a video here!"
        searchBar.delegate = self
        
        self.navigationItem.titleView = searchBar
        
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound];
        center.requestAuthorization(options: options) {
            (granted, error) in
            if !granted {
                print("Something went wrong")
            }
        }
        
        loadSavedVideo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.isList == true {
            loadSavedVideo()
        }
    }
    
    public func loadSavedVideo() {
        self.isList = true
        if let context = DataManager.shared.objectContext {
            let request: NSFetchRequest<YouWatchVideo> = YouWatchVideo.fetchRequest()
            if let results = try? context.fetch(request) {
                self.items = results
            }
        }
        
        self.tableView.reloadData()
    }
    
    @IBAction func clickStar(_ sender: UIBarButtonItem) {
        loadSavedVideo()
    }
    
    // called when keyboard search button pressed
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        self.isList = false
        if let searchText = searchBar.text {
            if let searchQuery = searchText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
                if (self.numberOfSections(in: self.tableView) > 0 ) {
                    let top = IndexPath(row: NSNotFound, section: 0)
                    self.tableView.scrollToRow(at: top, at: .top, animated: true)
                }
                self.query = searchQuery
                self.pageToken = ""
                self.items = []
                self.fetchData()
            }
        }
        searchBar.endEditing(true)
    }
    
    public func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! YoutWatchCell
        
        if items.count > 0 {
            let video = items[indexPath.row]
            
            let imgURL = URL(string: video.imgUrl!)
            
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: imgURL!)
                DispatchQueue.main.async {
                    cell.thumbnail.image = UIImage(data: data!)
                }
            }
            cell.titleLabel.text = video.name!
            cell.descriptionLabel.text = video.desc!
        }
        
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = self.items.count - 1
        if indexPath.row == lastElement && self.isList == false {
            self.fetchData()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showVideo" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let controller = segue.destination as! YouWatchPlayerViewController
                controller.video = self.items[indexPath.row]
            }
        }
    }
    
    private func fetchData() {
        Alamofire.request("https://www.googleapis.com/youtube/v3/search?type=video&maxResults=10&part=snippet&key=AIzaSyDown7kSOnL2Fs9TOeoYtFpC11qVAxTbps&q=\(self.query)&pageToken=\(self.pageToken)").validate().responseJSON { response in
            switch response.result {
            case .success:
                if let result = response.result.value {
                    if let context = DataManager.shared.objectContext {
                        let JSON = result as! NSDictionary
                        self.pageToken = JSON["nextPageToken"] as! String
                        let videos = JSON["items"] as! [NSDictionary]
                        for data in videos {
                            
                            let video: YouWatchVideo = YouWatchVideo.init(needSave: false, context: context);

                            let snippet = data["snippet"] as! NSDictionary
                        
                            video.videoId = (data["id"] as! NSDictionary)["videoId"] as? String
                            video.name = snippet["title"] as? String
                            video.desc = snippet["description"] as? String
                            video.imgUrl = ((snippet["thumbnails"] as! NSDictionary)["medium"] as! NSDictionary)    ["url"] as? String
                            video.channelName = snippet["channelTitle"] as? String
                        
                            self.items.append(video)
                        }
                        self.tableView.reloadData()
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }


}
