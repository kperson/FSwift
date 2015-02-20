//
//  JSONCoder.swift
//  FSwift
//
//  Created by Maxime Ollivier on 2/4/15.
//  Copyright (c) 2015 Kelton. All rights reserved.
//

import Foundation

public extension Coder {
    
    var jsonData:NSData? {
        var error:NSError?
        let data = NSJSONSerialization.dataWithJSONObject(object, options: NSJSONWritingOptions.allZeros, error: &error)
        if error != nil {println("Parsing error: \(error)")} //TODO: Make into Try like the JSON decoder
        return data
    }
    
}