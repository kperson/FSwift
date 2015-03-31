//
//  Try.swift
//  FSwift
//
//  Created by Kelton Person on 10/2/14.
//  Copyright (c) 2014 Kelton. All rights reserved.
//

import Foundation

final public class Try<T> {
    
    public var value: T?
    public var error: NSError?
    
    public init(success: T) {
        self.value = success
    }
    
    public init(failure: NSError) {
        self.error = failure
    }

    public var toTuple: (T?, NSError?) {
        return (value, error)
    }
    
}