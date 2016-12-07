//
//  YouWatchVideo+Function.swift
//  YouwatchLater
//
//  Created by Vincent Kocupyr on 06/12/2016.
//  Copyright © 2016 Vincent Kocupyr. All rights reserved.
//

import Foundation
import CoreData

extension YouWatchVideo {
    
    //MARK: - Initialize
    convenience init(needSave: Bool, context: NSManagedObjectContext?) {
        
        // Create the NSEntityDescription
        let entity = NSEntityDescription.entity(forEntityName: "YouWatchVideo", in: context!)
        
        
        if(!needSave) {
            self.init(entity: entity!, insertInto: nil)
        } else {
            self.init(entity: entity!, insertInto: context!)
        }
        
    }
    
    public override var description: String {
        var res = "YouWatchVideo:"
        if let videoId = self.videoId {
            res.append(" [id: \(videoId) ]")
        }
        if let name = self.name {
            res.append(" [pwd: \(name) ]")
        }
        return res
    }
}
