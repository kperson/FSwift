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
    
    public init(_ val: T) {
        self.value = val
    }
    
    public init(_ e: NSError) {
        self.error = e
    }
    
    /*
    public static func Success<D>(value: D) -> Try<D> {
        return Try<D>(value)
    }
    
    public static func Failure<D>(error: NSError) -> Try<D> {
        return Try<D>(error)
    }*/
    
    public var toTuple: (T?, NSError?) {
        return (value, error)
    }
    
}