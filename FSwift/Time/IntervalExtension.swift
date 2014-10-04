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
    public var millisecond: NSTimeInterval { return NSTimeInterval(self) * 0.001 }
    
    public var seconds: NSTimeInterval { return NSTimeInterval(self) * 1.milliseconds * 1000 }
    public var second: NSTimeInterval { return NSTimeInterval(self) * 1.milliseconds * 1000 }
    
    public var minutes: NSTimeInterval { return NSTimeInterval(self) * 60.seconds }
    public var minute: NSTimeInterval { return NSTimeInterval(self) * 60.seconds }

    public var hours: NSTimeInterval { return NSTimeInterval(self) * 60.minutes }
    public var hour: NSTimeInterval { return NSTimeInterval(self) * 60.minutes }

    public var days: NSTimeInterval { return NSTimeInterval(self) * 24.hours }
    public var day: NSTimeInterval { return NSTimeInterval(self) * 24.hours }
    
    public var years: NSTimeInterval { return NSTimeInterval(self) * 365.days }
    public var year: NSTimeInterval { return NSTimeInterval(self) * 365.days }
    
}