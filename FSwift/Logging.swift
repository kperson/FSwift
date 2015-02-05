//
//  Logging.swift
//  FSwift
//
//  Created by Maxime Ollivier on 1/27/15.
//  Copyright (c) 2015 Kelton. All rights reserved.
//

import Foundation

// MARK: Easy printing

postfix operator <<< {}

infix operator <<< {}

public postfix func <<<<T>(value:T) -> T{
    println(value)
    return value
}

public func <<<<T>(left:T,message:String) -> T{
    println("\(message): \(left)")
    return left
}