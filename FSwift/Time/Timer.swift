//
//  Timer.swift
//  FSwift
//
//  Created by Kelton Person on 10/4/14.
//  Copyright (c) 2014 Kelton. All rights reserved.
//

import Foundation

open class Timer {

    let interval: TimeInterval
    let repeats: Bool
    let f: (Timer) -> Void
    var isRunning: Bool = false
    fileprivate var timer: Foundation.Timer?
    
    public init(interval: TimeInterval, repeats: Bool, f: @escaping (Timer) -> Void) {
        self.interval = interval
        self.repeats = repeats
        self.f = f
    }
    
    @objc func tick() {
        if self.timer != nil  {
            self.f(self)
        }
        if !self.repeats {
            self.stop()
        }
    }
    
    open func start() {
        if self.timer == nil {
            self.timer = Foundation.Timer(timeInterval: interval, target:self, selector: #selector(Timer.tick), userInfo: nil, repeats: repeats)
            RunLoop.current.add(self.timer!, forMode: RunLoopMode.defaultRunLoopMode)
            self.isRunning = true
        }
    }
    
    open func stop() {
        self.timer?.invalidate()
        self.timer = nil
        self.isRunning = false
    }
    
    open var running: Bool {
        return self.isRunning
    }
    
    
}

