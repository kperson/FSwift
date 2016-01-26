//
//  Storage.swift
//  FSwift
//
//  Created by Maxime Ollivier on 1/27/15.
//  Copyright (c) 2015 Kelton. All rights reserved.
//

import Foundation

public class Storage {
    public class var documentDirectoryPath: String {
        let documentDirectories = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        return documentDirectories.first!
    }
    
    public class var documentDirectoryURL: NSURL {
        return NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
    }
}