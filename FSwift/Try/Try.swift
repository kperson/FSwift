//
//  Try.swift
//  FSwift
//
//  Created by Kelton Person on 10/2/14.
//  Copyright (c) 2014 Kelton. All rights reserved.
//

import Foundation

public enum Try<T> {
    
    case success(T)
    case failure(NSError)
    
    public var toTuple: (T?, NSError?) {
        switch self {
        case Try.success(let v): return (v, nil)
        case Try.failure(let e): return (nil, e)
        }
    }
    
    public var match:TryStatus {
        switch self {
        case Try.success(_): return TryStatus.success
        case Try.failure(let e): return TryStatus.failure(e)
        }
    }
    
    public var value: T? {
        switch self {
        case Try.success(let v): return v
        case Try.failure(_): return nil
        }
    }
    
    public var error: NSError? {
        switch self {
        case Try.success(_): return nil
        case Try.failure(let e): return e
        }
    }
    
}
