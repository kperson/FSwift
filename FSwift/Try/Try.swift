//
//  Try.swift
//  FSwift
//
//  Created by Kelton Person on 10/2/14.
//  Copyright (c) 2014 Kelton. All rights reserved.
//

import Foundation

public enum Try<T> {
    case Success(@autoclosure() -> T)
    case Failure(NSError)
        
    public var error: NSError? {
        switch self {
            case .Failure(let err): return err
            default: return nil
        }
    }
    
    public var value: T? {
        switch self {
            case .Success(let val): return val()
            default: return nil
        }
    }
}