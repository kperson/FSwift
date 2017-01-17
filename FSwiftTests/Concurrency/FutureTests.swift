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
        let _ = futureOnBackground {
            Try<String>.success(hello)
        }.onComplete { x in
            switch x.toTuple {
            case (.some(let val), _):  XCTAssertEqual(val, hello, "x must equal 'Hello World'")
            case (_, .some( _)): XCTAssert(false, "This line should never be executed in the this test")
            default:
                XCTAssert(false, "This line should never be executed in the this test")
            }
        }
        Thread.sleep(forTimeInterval: 100.milliseconds)
    }
    
    func testFutureMapSuccess() {
        var complete = false
        let hello = "Hello World"
        let numberOfCharacters = hello.characters.count
        let _ = futureOnBackground {
           Try<String>.success(hello)
        }.map { x in
            Try<Int>.success(x.characters.count)
        }.onSuccess { ct in
            complete = true
            XCTAssertEqual(ct, numberOfCharacters, "ct must equal the number of characters in 'Hello World'")
        }
        Thread.sleep(forTimeInterval: 100.milliseconds)
        XCTAssert(complete, "OnSuccess should have occured")
    }
    
    func testFailure() {
        let _ = futureOnBackground {
            Try<Int>.failure(NSError(domain: "com.error", code: 200, userInfo: nil))
        }
        .onFailure { error in
            XCTAssertEqual(error.domain, "com.error", "error domain must equal 'com.error'")
        }
        .onSuccess { x in
            XCTAssert(false, "This line should never be executed in this test")
        }
        
        Thread.sleep(forTimeInterval: 100.milliseconds)
    }
    
    func testFutureMapFailure() {
        let _ = futureOnBackground {
            Try<Int>.failure(NSError(domain: "com.error", code: 200, userInfo: nil))
        }.map { t in
            Try<String>.success("Hello")
        }.onFailure { error in
            XCTAssertEqual(error.domain, "com.error", "Error domains should be equal")
        }
        .onSuccess { x in
            XCTAssert(false, "This line should never be executed in this test")
        }
        Thread.sleep(forTimeInterval: 100.milliseconds)
    }
    
    func testBindCheckBool() {
        var success = false
        let _ = futureOnBackground {
            Try<String>.success("hello")
        }.bindToBool({ false })
        .onSuccess { str in
            success = true
        }
        Thread.sleep(forTimeInterval: 100.milliseconds)
        XCTAssertFalse(success, "future must not complete if bind evaluation is false")
        
        
        success = false
        let _ = futureOnBackground {
            Try<String>.success("hello")
        }.bindToBool({ true })
        .onSuccess { str in
            success = true
        }
        Thread.sleep(forTimeInterval: 100.milliseconds)
        XCTAssertTrue(success, "future must not complete if bind evaluation is false")
    }
    
    func testBindCheckOpt() {
        var success = false
        let _ = futureOnBackground {
            Try<String>.success("hello")
        }.bindToOptional({ nil })
        .onSuccess { str in
            success = true
        }
        Thread.sleep(forTimeInterval: 100.milliseconds)
        XCTAssertFalse(success, "future must not complete if bind evaluation is false")
        
        
        success = false
        let _ = futureOnBackground {
            Try<String>.success("hello")
        }.bindToOptional({ "bob" })
        .onSuccess { str in
            success = true
        }
        Thread.sleep(forTimeInterval: 100.milliseconds)
        XCTAssertTrue(success, "future must not complete if bind evaluation is false")
    }
    
    func testCombine() {
        
        let x = futureOnBackground { () -> Try<String> in
            Thread.sleep(forTimeInterval: 500.milliseconds)
            return Try<String>.success("hello")
        }
        
        let y = futureOnBackground { () -> Try<Int> in
            Thread.sleep(forTimeInterval: 100.milliseconds)
            return Try<Int>.success(2)
        }
        
        let _ = combineFuturesOnBackground(x.signal, y.signal)
        .onSuccess { a in }
        
         Thread.sleep(forTimeInterval: 2.seconds)

    }

    func testRecover() {
        var complete = false
        let _ = futureOnBackground {
            Try.failure(NSError(domain: "com.error", code: 100, userInfo: nil))
        }.recover { err in
            Try.success(3)
        }.onSuccess { num in
            complete = true
            XCTAssert(3 == num, "recover must coalesce")
        }
        
        var complete2 = false
        let _ = futureOnBackground {
            Try.success(4)
        }.recover { err in
            Try.success(3)
        }.onSuccess { num in
            complete2 = true
            XCTAssert(4 == num, "recover must coalesce")
        }
        
        Thread.sleep(forTimeInterval: 200.milliseconds)
        XCTAssert(complete2, "recovering must have completed")
        XCTAssert(complete, "recovering must have completed")

    }
    
    func testRecoverFilter() {
        var recoveredOne = false
        let _ = futureOnBackground {
            Try.failure(NSError(domain: "com.error", code: 100, userInfo: nil))
        }.recoverOn { err in
            err.domain == "com.error"
        }.recover { err in
            recoveredOne = true
            return Try.success(3)
        }.onSuccess { num in
            XCTAssert(3 == num, "recover must coalesce")
        }
        
        var recoveredTwo = false
        let _ = futureOnBackground {
            Try.failure(NSError(domain: "com.error2", code: 100, userInfo: nil))
        }.recoverOn { err in
            err.domain == "com.error"
        }.recover { err in
            recoveredTwo = true
            return Try.success(3)
        }.onSuccess { num in
            XCTAssert(3 == num, "recover must coalesce")
        }
    

        
        Thread.sleep(forTimeInterval: 200.milliseconds)
        XCTAssert(recoveredOne, "recovering must have completed")
        XCTAssert(!recoveredTwo, "recovering must have not completed")
        
    }
}
