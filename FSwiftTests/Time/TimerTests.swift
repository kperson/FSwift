//
//  TimerTests.swift
//  FSwift
//
//  Created by Kelton Person on 10/6/14.
//  Copyright (c) 2014 Kelton. All rights reserved.
//

import UIKit
import XCTest

class TimerTests: XCTestCase {

    func testTimerLoop() {
        
        var ct = 0
        let start = Date().timeIntervalSince1970
        let readyExpectation = expectation(withDescription: "ready1")
        Timer(interval: 100.milliseconds, repeats: true, f: { t in
            ct += 1
            if(ct == 2) {
                let end = Date().timeIntervalSince1970
                XCTAssert(end - start >= 200.milliseconds, "If the loop runs twice it must be in about 200.milliseconds")
                readyExpectation.fulfill()
            }
        }).start()
        waitForExpectations(withTimeout: 400.milliseconds, handler:  { error in })
    }
    
    func testTimerStop() {
        var ct = 0
        let readyExpectation = expectation(withDescription: "ready2")
        let timer = Timer(interval: 100.milliseconds, repeats: true, f: { t in
            ct += 1
            if(ct == 2) {
                XCTAssert(false, "The timer should be cancelled before reaching this point")
            }
        })
        timer.start()
        var ct2 = 0
        let timer2 = Timer(interval: 120.milliseconds, repeats: true, f: { t in
            timer.stop()
            ct2 += 1
            if ct2 == 2 {
                XCTAssertEqual(ct, 1, "Tick of timer should only occur once")
                readyExpectation.fulfill()
            }
        })
        timer2.start()
        waitForExpectations(withTimeout: 500.milliseconds, handler:  { error in })
    }
    
    func testTimerWithNoRepeat() {
        var ct = 0
        let readyExpectation = expectation(withDescription: "ready3")
        Timer(interval: 100.milliseconds, repeats: false, f: { t in
            ct += 1
            if(ct == 2) {
                XCTAssert(false, "The timer should be cancelled before reaching this point")
            }
        }).start()

        let cancelTimer = Timer(interval: 250.milliseconds, repeats: false, f: { t in
            readyExpectation.fulfill()
        })
        cancelTimer.start()
        waitForExpectations(withTimeout: 500.milliseconds, handler:  { error in })
    }

}
