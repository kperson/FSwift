//
//  ListExtension.swift
//  FSwift
//
//  Created by Kelton Person on 10/6/14.
//  Copyright (c) 2014 Kelton. All rights reserved.
//

import Foundation

public extension Array {
    
    func foreach( f: (T) -> Void) {
        for x in self {
            f(x)
        }
    }
    
}