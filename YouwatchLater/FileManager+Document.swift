//
//  FileManager+Document.swift
//  YouwatchLater
//
//  Created by Vincent Kocupyr on 06/12/2016.
//  Copyright © 2016 Vincent Kocupyr. All rights reserved.
//

import Foundation

extension FileManager {
    
    public static func documentURL() -> URL? {
        return documentURL(childPath: nil)
    }
    
    public static func documentURL(childPath: String?) -> URL? {
        if let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            if let path = childPath {
                return docURL.appendingPathComponent(path)
            }
            return docURL
        }
        return nil
    }
}
