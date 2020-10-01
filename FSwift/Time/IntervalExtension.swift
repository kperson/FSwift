//
//  IntervalExtension.swift
//  FSwift
//
//  Created by Kelton Person on 10/2/14.
//  Copyright (c) 2014 Kelton. All rights reserved.
//

import Foundation

public extension Int {
    
    var milliseconds: TimeInterval { return TimeInterval(self) * 0.001 }
    var millisecond: TimeInterval { return self.milliseconds }
    
    var seconds: TimeInterval { return TimeInterval(self) * 1.milliseconds * 1000 }
    var second: TimeInterval { return self.seconds }
    
    var minutes: TimeInterval { return TimeInterval(self) * 60.seconds }
    var minute: TimeInterval { return self.minutes }
    
    var hours: TimeInterval { return TimeInterval(self) * 60.minutes }
    var hour: TimeInterval { return self.hours }
    
    var days: TimeInterval { return TimeInterval(self) * 24.hours }
    var day: TimeInterval { return self.days }
    
    var years: TimeInterval { return TimeInterval(self) * 365.days }
    var year: TimeInterval { return self.years }
    
}
