//
//  OptionalExtension.swift
//  FSwift
//
//  Created by Kelton Person on 10/6/14.
//  Copyright (c) 2014 Kelton. All rights reserved.
//

import Foundation

extension Optional {
    
    func getOrElse(defaultValue: Wrapped) -> Wrapped {
        if self == nil {
            return defaultValue
        }
        else {
            return self!
        }
    }
    
    func flatMap<S>(f: (Wrapped) -> S) -> S? {
        if self == nil {
            return nil
        }
        else {
            return f(self!)
        }
    }
    
    
}