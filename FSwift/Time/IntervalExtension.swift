//
//  IntervalExtension.swift
//  FSwift
//
//  Created by Kelton Person on 10/2/14.
//  Copyright (c) 2014 Kelton. All rights reserved.
//

import Foundation

extension Int {

    var milliseconds: NSTimeInterval { return NSTimeInterval(self) * 0.001 }
    var millisecond: NSTimeInterval { return NSTimeInterval(self) * 0.001 }
    
    var seconds: NSTimeInterval { return NSTimeInterval(self) * 1.milliseconds * 1000 }
    var second: NSTimeInterval { return NSTimeInterval(self) * 1.milliseconds * 1000 }
    
    var minutes: NSTimeInterval { return NSTimeInterval(self) * 60.seconds }
    var minute: NSTimeInterval { return NSTimeInterval(self) * 60.seconds }

    var hours: NSTimeInterval { return NSTimeInterval(self) * 60.minutes }
    var hour: NSTimeInterval { return NSTimeInterval(self) * 60.minutes }

    var days: NSTimeInterval { return NSTimeInterval(self) * 24.hours }
    var day: NSTimeInterval { return NSTimeInterval(self) * 24.hours }
    
    var years: NSTimeInterval { return NSTimeInterval(self) * 365.days }
    var year: NSTimeInterval { return NSTimeInterval(self) * 365.days }
    
}