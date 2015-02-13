//
//  Bool.swift
//  FSwift
//
//  Created by Maxime Ollivier on 2/9/15.
//  Copyright (c) 2015 Kelton. All rights reserved.
//

import Foundation

extension Bool {
    
    public init?(string:String) {
        if string == "0" || string == "false".lowercaseString {
            self = false
        } else if string == "1" || string == "true".lowercaseString {
            self = true
        } else {
            return nil
        }
    }
    
}
