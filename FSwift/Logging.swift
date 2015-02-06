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

public enum LogType {
    case General
    case Network
    case Bluetooth
    
    var isActive:Bool {
        switch self {
        case .Bluetooth:
            return true
        case .General:
            return true
        case .Network:
            return true
        }
    }
}

public func log<T>(object:T, type:LogType) {
    if type.isActive {
        println(object)
    }
}