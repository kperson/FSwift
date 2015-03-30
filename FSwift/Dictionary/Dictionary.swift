//
//  Dictionary.swift
//  FSwift
//
//  Created by Maxime Ollivier on 1/27/15.
//  Copyright (c) 2015 Kelton. All rights reserved.
//

import Foundation

extension Dictionary {
    mutating func addOptional(optional:Value?, forKey:Key) {
        if let object = optional {
            self[forKey] = object
        }
    }
}