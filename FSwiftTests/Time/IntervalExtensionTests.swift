//
//  IntervalExtensionTests.swift
//  FSwift
//
//  Created by Kelton Person on 10/2/14.
//  Copyright (c) 2014 Kelton. All rights reserved.
//

import XCTest

class IntervalExtensionTests: XCTestCase {

    
    func testMilliseconds() {
        XCTAssertEqual(5.milliseconds, 0.005, "5 milliseconds must be 0.005 (NSTimeInterval)")
        XCTAssertEqual(5.millisecond, 0.005, "5 milliseconds must be 0.005 (NSTimeInterval)")
    }
    
    func testSeconds() {
        XCTAssertEqual(5.seconds, 5.0, "5 seconds must be 5.0 (NSTimeInterval)")
        XCTAssertEqual(5.second, 5.0, "5 seconds must be 5.0 (NSTimeInterval)")
    }
    
    func testMinutes() {
        XCTAssertEqual(5.minutes, 300.0, "5 minutes must be 300.0 (NSTimeInterval)")
        XCTAssertEqual(5.minute, 300.0, "5 minutes must be 300.0 (NSTimeInterval)")
    }
    
    func testHours() {
        XCTAssertEqual(5.hours, 18000, "5 hours must be 18000.0 (NSTimeInterval)")
        XCTAssertEqual(5.hour, 18000, "5 hours must be 18000.0 (NSTimeInterval)")

    }
    
    func testDays() {
        XCTAssertEqual(5.days, 432000, "5 days must be 432000.0 (NSTimeInterval)")
        XCTAssertEqual(5.day, 432000, "5 days must be 432000.0 (NSTimeInterval)")
    }
    
    func testYears() {
        XCTAssertEqual(5.years, 157680000, "5 years must be 157680000.0 (NSTimeInterval)")
        XCTAssertEqual(5.years, 157680000, "5 years must be 157680000.0 (NSTimeInterval)")
    }

}
