//
//  Date.swift
//  FSwift
//
//  Created by Maxime Ollivier on 1/27/15.
//  Copyright (c) 2015 Kelton. All rights reserved.
//

import Foundation

public enum DatePrintComponent {
    case fullYear
    case monthNumber
    case day
    case hour24
    case seconds
}

public extension Date {
    public func stringWithFormat(_ format:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    public func printWithComponent(_ component:DatePrintComponent) -> String {
        switch component {
        case .fullYear:
            return self.stringWithFormat("yyyy")
        case .monthNumber:
            return self.stringWithFormat("MM")
        case .day:
            return self.stringWithFormat("dd")
        case .hour24:
            return self.stringWithFormat("HH")
        case .seconds:
            return self.stringWithFormat("mm")
        }
    }
    
    public subscript(component: DatePrintComponent) -> String {
        return printWithComponent(component)
    }
}


public func + (date:Date, time: TimeInterval) -> Date {
    return date.addingTimeInterval(time)
    
}

public func + (time: TimeInterval, date:Date) -> Date {
    return date.addingTimeInterval(time)
}


public func - (date:Date, time: TimeInterval) -> Date {
    return date.addingTimeInterval(-time)
}

public func - (time: TimeInterval, date:Date) -> Date {
    return date.addingTimeInterval(-time)
}

public func > (left: Date, right: Date) -> Bool {
    let compare = left.compare(right)
    
    if compare == ComparisonResult.orderedDescending {
        return true
    }
    else {
        return false
    }
}

public func < (left: Date, right: Date) -> Bool {
    let compare = right.compare(left)
    
    if compare == ComparisonResult.orderedDescending {
        return true
    }
    else {
        return false
    }
}


public func >= (left: Date, right: Date) -> Bool {
    let compare = left.compare(right)
    
    if compare == ComparisonResult.orderedDescending || compare == ComparisonResult.orderedSame {
        return true
    }
    else {
        return false
    }
}

public func <= (left: Date, right: Date) -> Bool {
    let compare = right.compare(left)
    
    if compare == ComparisonResult.orderedDescending || compare == ComparisonResult.orderedSame  {
        return true
    }
    else {
        return false
    }
}
