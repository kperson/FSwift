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
    
    public class func Success(val: T) -> Try<T> {
        return Try(success: val)
    }
    
    public class func Failure(error: NSError) -> Try<T> {
        return Try<T>(failure: error)
    }
    
    //maybe we use custom matching? http://austinzheng.com/2014/12/17/custom-pattern-matching/
    public var match:TryStatus {
        if let v = value {
            return TryStatus.Success
        }
        else {
            return TryStatus.Failure(error!)
        }
    }
    
}