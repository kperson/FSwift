//
//  IntervalExtension.swift
//  FSwift
//
//  Created by Kelton Person on 10/2/14.
//  Copyright (c) 2014 Kelton. All rights reserved.
//

import Foundation

public extension Int {
    
    public var milliseconds: TimeInterval { return TimeInterval(self) * 0.001 }
    public var millisecond: TimeInterval { return self.milliseconds }
    
    public var seconds: TimeInterval { return TimeInterval(self) * 1.milliseconds * 1000 }
    public var second: TimeInterval { return self.seconds }
    
    public var minutes: TimeInterval { return TimeInterval(self) * 60.seconds }
    public var minute: TimeInterval { return self.minutes }
    
    public var hours: TimeInterval { return TimeInterval(self) * 60.minutes }
    public var hour: TimeInterval { return self.hours }
    
    public var days: TimeInterval { return TimeInterval(self) * 24.hours }
    public var day: TimeInterval { return self.days }
    
    public var years: TimeInterval { return TimeInterval(self) * 365.days }
    public var year: TimeInterval { return self.years }
    
}
