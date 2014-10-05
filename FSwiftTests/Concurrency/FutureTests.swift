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
        let hello = "Hello World"
        let numberOfCharacters = countElements(hello)
        futureOnBackground {
           Try.Success(hello)
        }.mapSuccess { x in
            Try.Success(countElements(x))
        }.onSuccess { ct in
            XCTAssertEqual(ct, 11, "ct must equal the number of characters in 'Hello World'")
        }
        NSThread.sleepForTimeInterval(100.milliseconds)
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
                case Try.Success(let val): XCTAssert(false, "This line should never be executed in the this test")
            }
        }
        .onFailure { error in
            XCTAssertEqual(error.domain, "com.error", "error domain must equal 'com.error'")
        }
        .onSuccess { x in
            XCTAssert(false, "This line should never be executed in the this test")
        }
        
        z.mapFailure { (error: NSError)  in
            Try.Success(error.code)
        }
        .onSuccess { errorCode in
            XCTAssertEqual(errorCode, 200, "error code must equal 200")
        }
        
        NSThread.sleepForTimeInterval(100.milliseconds)
    }
}
