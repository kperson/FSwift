//
//  OptionalExtension.swift
//  FSwift
//
//  Created by Kelton Person on 10/6/14.
//  Copyright (c) 2014 Kelton. All rights reserved.
//

import Foundation

extension Optional {
    
    func getOrElse(defaultValue: T) -> T {
        if self == nil {
            return defaultValue
        }
        else {
            return self!
        }
    }
    
}