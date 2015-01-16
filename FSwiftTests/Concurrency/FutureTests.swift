//
//  FutureTests.swift
//  FSwift
//
//  Created by Kelton Person on 10/3/14.
//  Copyright (c) 2014 Kelton. All rights reserved.
//

import UIKit
import XCTest

class FutureTests: XCTestCase {

    func testFutureOnComplete() {
        let hello = "Hello World"
        futureOnBackground {
            Try.Success(hello)
        }.onComplete { x in
            switch x {
                case Try.Success(let val):  XCTAssertEqual(val(), hello, "x must equal 'Hello World'")
                case Try.Failure(let error): XCTAssert(false, "This line should never be executed in the this test")
            }
        }
        NSThread.sleepForTimeInterval(100.milliseconds)
    }
    
    func testFutureMapSuccess() {
        var complete = false
        let hello = "Hello World"
        let numberOfCharacters = countElements(hello)
        futureOnBackground {
           Try.Success(hello)
        }.map { x in
            Try.Success(countElements(x))
        }.onSuccess { ct in
            complete = true
            XCTAssertEqual(ct, numberOfCharacters, "ct must equal the number of characters in 'Hello World'")
        }
        NSThread.sleepForTimeInterval(100.milliseconds)
        XCTAssert(complete, "OnSuccess should have occured")
    }
    
    func testFailure() {
        let hello = "Hello World"
        let numberOfCharacters = countElements(hello)
        let z = futureOnBackground {
            Try<Int>.Failure(NSError(domain: "com.error", code: 200, userInfo: nil))
        }
        .onComplete { x in
            switch x {
                case Try.Failure(let error):  XCTAssertEqual(error.domain, "com.error", "error domain must equal 'com.error'")
                case Try.Success(let val): XCTAssert(false, "This line should never be executed in this test")
            }
        }
        .onFailure { error in
            XCTAssertEqual(error.domain, "com.error", "error domain must equal 'com.error'")
        }
        .onSuccess { x in
            XCTAssert(false, "This line should never be executed in this test")
        }
        
        NSThread.sleepForTimeInterval(100.milliseconds)
    }
    
    func testFutureMapFailure() {
        futureOnBackground {
            Try<Int>.Failure(NSError(domain: "com.error", code: 200, userInfo: nil))
        }.map { t in
            Try.Success("Hello")
        }.onFailure { error in
            XCTAssertEqual(error.domain, "com.error", "Error domains should be equal")
        }
        .onSuccess{ x in
            XCTAssert(false, "This line should never be executed in this test")
        }
        NSThread.sleepForTimeInterval(100.milliseconds)
    }
    
    func testCombine() {
        
        let x = futureOnBackground { () -> Try<String> in
            NSThread.sleepForTimeInterval(500.milliseconds)
            return Try.Success("hello")
        }
        
        let y = futureOnBackground { () -> Try<Int> in
            NSThread.sleepForTimeInterval(100.milliseconds)
            return Try.Success(2)
        }
        
        combineFuturesOnBackground(x.signal, y.signal)
        .onSuccess { a in
            for val in 0...y.finalVal - 1 {
            }
        }
        
         NSThread.sleepForTimeInterval(2.seconds)

    }
    
    func testAwait() {
        let x = futureOnBackground {
            Try.Success("Hello World")
        }
        
        let start = NSDate().timeIntervalSince1970
        let y = futureOnBackground { () -> Try<String> in
            NSThread.sleepForTimeInterval(100.milliseconds)
            return Try<String>.Failure(NSError(domain: "com.error", code: 200, userInfo: nil))
        }
        
        var complete = false
        Future.await([x, y], {
            complete = true
            let end = NSDate().timeIntervalSince1970
            XCTAssert(end - start >= 100.millisecond, "The future needs to have been completed in about 100 milliseconds")
        })
        
        NSThread.sleepForTimeInterval(200.millisecond)
        XCTAssertTrue(complete, "The await method must have triggered")
    }
}
