//
//  Date.swift
//  FSwift
//
//  Created by Maxime Ollivier on 1/27/15.
//  Copyright (c) 2015 Kelton. All rights reserved.
//

import Foundation

public enum DatePrintComponent {
    case FullYear
    case MonthNumber
    case Day
    case Hour24
    case Seconds
}

public extension NSDate {
    public func stringWithFormat(format:String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.stringFromDate(self)
    }
    
    public func printWithComponent(component:DatePrintComponent) -> String {
        switch component {
        case .FullYear:
            return self.stringWithFormat("yyyy")
        case .MonthNumber:
            return self.stringWithFormat("MM")
        case .Day:
            return self.stringWithFormat("dd")
        case .Hour24:
            return self.stringWithFormat("HH")
        case .Seconds:
            return self.stringWithFormat("mm")
        }
    }
    
    public subscript(component: DatePrintComponent) -> String {
        return printWithComponent(component)
    }
}


public func + (date:NSDate, time: NSTimeInterval) -> NSDate {
    return date.dateByAddingTimeInterval(time)
    
}

public func + (time: NSTimeInterval, date:NSDate) -> NSDate {
    return date.dateByAddingTimeInterval(time)
}


public func - (date:NSDate, time: NSTimeInterval) -> NSDate {
    return date.dateByAddingTimeInterval(-time)
}

public func - (time: NSTimeInterval, date:NSDate) -> NSDate {
    return date.dateByAddingTimeInterval(-time)
}

public func > (left: NSDate, right: NSDate) -> Bool {
    let compare = left.compare(right)
    
    if compare == NSComparisonResult.OrderedDescending {
        return true
    }
    else {
        return false
    }
}

public func < (left: NSDate, right: NSDate) -> Bool {
    let compare = right.compare(left)
    
    if compare == NSComparisonResult.OrderedDescending {
        return true
    }
    else {
        return false
    }
}


public func >= (left: NSDate, right: NSDate) -> Bool {
    let compare = left.compare(right)
    
    if compare == NSComparisonResult.OrderedDescending || compare == NSComparisonResult.OrderedSame {
        return true
    }
    else {
        return false
    }
}

public func <= (left: NSDate, right: NSDate) -> Bool {
    let compare = right.compare(left)
    
    if compare == NSComparisonResult.OrderedDescending || compare == NSComparisonResult.OrderedSame  {
        return true
    }
    else {
        return false
    }
}