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
            Try<String>(success: hello)
        }.onComplete { x in
            switch x.toTuple {
            case (.Some(let val), _):  XCTAssertEqual(val, hello, "x must equal 'Hello World'")
            case (_, .Some(let error)): XCTAssert(false, "This line should never be executed in the this test")
            default:
                XCTAssert(false, "This line should never be executed in the this test")
            }
        }
        NSThread.sleepForTimeInterval(100.milliseconds)
    }
    
    func testFutureMapSuccess() {
        var complete = false
        let hello = "Hello World"
        let numberOfCharacters = count(hello)
        futureOnBackground {
           Try<String>(success: hello)
        }.map { x in
            Try<Int>(success: count(x))
        }.onSuccess { ct in
            complete = true
            XCTAssertEqual(ct, numberOfCharacters, "ct must equal the number of characters in 'Hello World'")
        }
        NSThread.sleepForTimeInterval(100.milliseconds)
        XCTAssert(complete, "OnSuccess should have occured")
    }
    
    func testFailure() {
        let hello = "Hello World"
        let numberOfCharacters = count(hello)
        let z = futureOnBackground {
            Try<Int>(failure: NSError(domain: "com.error", code: 200, userInfo: nil))
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
            Try<Int>(failure: NSError(domain: "com.error", code: 200, userInfo: nil))
        }.map { t in
            Try<String>(success: "Hello")
        }.onFailure { error in
            XCTAssertEqual(error.domain, "com.error", "Error domains should be equal")
        }
        .onSuccess { x in
            XCTAssert(false, "This line should never be executed in this test")
        }
        NSThread.sleepForTimeInterval(100.milliseconds)
    }
    
    func testCombine() {
        
        let x = futureOnBackground { () -> Try<String> in
            NSThread.sleepForTimeInterval(500.milliseconds)
            return Try<String>(success: "hello")
        }
        
        let y = futureOnBackground { () -> Try<Int> in
            NSThread.sleepForTimeInterval(100.milliseconds)
            return Try<Int>(success: 2)
        }
        
        combineFuturesOnBackground(x.signal, y.signal)
        .onSuccess { a in
            for val in 0...y.finalVal - 1 {
            }
        }
        
         NSThread.sleepForTimeInterval(2.seconds)

    }

    func testRecover() {
        var complete = false
        futureOnBackground {
            Try<Int>(failure: NSError(domain: "com.error", code: 100, userInfo: nil))
        }.recover { err in
            Try<Int>(success: 3)
        }.onSuccess { num in
            complete = true
            println(num)
            XCTAssert(3 == num, "recover must coalesce")
        }
        
        var complete2 = false
        futureOnBackground {
            Try<Int>(success: 4)
        }.recover { err in
            Try<Int>(success: 3)
        }.onSuccess { num in
            complete2 = true
            XCTAssert(4 == num, "recover must coalesce")
        }
        
        NSThread.sleepForTimeInterval(200.milliseconds)
        XCTAssert(complete2, "recovering must have completed")
        XCTAssert(complete, "recovering must have completed")

    }
    
    func testRecoverFilter() {
        var recoveredOne = false
        futureOnBackground {
            Try<Int>(failure: NSError(domain: "com.error", code: 100, userInfo: nil))
        }.recoverOn { err in
            err.domain == "com.error"
        }.recover { err in
            recoveredOne = true
            return Try<Int>(success: 3)
        }.onSuccess { num in
            XCTAssert(3 == num, "recover must coalesce")
        }
        
        var recoveredTwo = false
        futureOnBackground {
            Try<Int>(failure: NSError(domain: "com.error2", code: 100, userInfo: nil))
        }.recoverOn { err in
            err.domain == "com.error"
        }.recover { err in
            recoveredTwo = true
            return Try<Int>(success: 3)
        }.onSuccess { num in
            XCTAssert(3 == num, "recover must coalesce")
        }
    

        
        NSThread.sleepForTimeInterval(200.milliseconds)
        XCTAssert(recoveredOne, "recovering must have completed")
        XCTAssert(!recoveredTwo, "recovering must have not completed")
        
    }
}
