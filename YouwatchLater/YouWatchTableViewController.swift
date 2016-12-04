//
//  YouWatchTableViewController.swift
//  YouwatchLater
//
//  Created by Vincent Kocupyr on 04/12/2016.
//  Copyright © 2016 Vincent Kocupyr. All rights reserved.
//

import UIKit
import Alamofire

class YouWatchTableViewController: UITableViewController, UISearchBarDelegate {

    
    var items = [NSDictionary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let searchBar = UISearchBar()
        searchBar.showsCancelButton = false
        searchBar.placeholder = "Search a video here!"
        searchBar.delegate = self
        
        self.navigationItem.titleView = searchBar
        
        tableView.reloadData()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    // called when keyboard search button pressed
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        print(searchBar.text!)
        if let searchText = searchBar.text {
            Alamofire.request("https://www.googleapis.com/youtube/v3/search?type=video&maxResults=10&part=snippet&key=AIzaSyDown7kSOnL2Fs9TOeoYtFpC11qVAxTbps&q=\(searchText)").validate().responseJSON { response in
                switch response.result {
                    case .success:
                        print("Validation Successful")
                        if let result = response.result.value {
                            let JSON = result as! NSDictionary
                            let videos = JSON["items"] as! [NSDictionary]
                            self.items = videos
                            self.tableView.reloadData()
                        }
                    case .failure(let error):
                        print(error)
                }
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
            let snippet = video["snippet"] as! NSDictionary
            let imgURL = URL(string: ((snippet["thumbnails"] as! NSDictionary)["default"] as! NSDictionary)["url"] as! String)
            
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: imgURL!)
                DispatchQueue.main.async {
                    cell.thumbnail.image = UIImage(data: data!)
                }
            }
            cell.titleLabel.text = (snippet["title"] as! String)
            cell.descriptionLabel.text = (snippet["description"] as! String)
        }
        
        
        return cell
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showVideo" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let controller = segue.destination as! YouWatchPlayerViewController
                controller.videoId = (self.items[indexPath.row]["id"] as! NSDictionary)["videoId"] as! String
            }
        }
    }


}
