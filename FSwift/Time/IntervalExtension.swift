//
//  IntervalExtension.swift
//  FSwift
//
//  Created by Kelton Person on 10/2/14.
//  Copyright (c) 2014 Kelton. All rights reserved.
//

import Foundation

public extension Int {

    public var milliseconds: NSTimeInterval { return NSTimeInterval(self) * 0.001 }
    public var millisecond: NSTimeInterval { return self.milliseconds }
    
    public var seconds: NSTimeInterval { return NSTimeInterval(self) * 1.milliseconds * 1000 }
    public var second: NSTimeInterval { return self.seconds }
    
    public var minutes: NSTimeInterval { return NSTimeInterval(self) * 60.seconds }
    public var minute: NSTimeInterval { return self.minutes }

    public var hours: NSTimeInterval { return NSTimeInterval(self) * 60.minutes }
    public var hour: NSTimeInterval { return self.hours }

    public var days: NSTimeInterval { return NSTimeInterval(self) * 24.hours }
    public var day: NSTimeInterval { return self.days }
    
    public var years: NSTimeInterval { return NSTimeInterval(self) * 365.days }
    public var year: NSTimeInterval { return self.years }
    
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