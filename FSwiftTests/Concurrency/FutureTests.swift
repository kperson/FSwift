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
            hello
        }.onComplete { x in
            XCTAssertEqual(x, hello, "x must equal 'Hello World'")
        }
        NSThread.sleepForTimeInterval(100.milliseconds)
    }
    
    func testFutureMap() {
        let hello = "Hello World"
        let numberOfCharacters = countElements(hello)
        futureOnBackground {
            hello
        }.map { x in
            countElements(x)
        }.onComplete { ct in
            XCTAssertEqual(ct, 11, "ct must equal the number of characters in 'Hello World'")
        }
        NSThread.sleepForTimeInterval(100.milliseconds)
    }
    
    /*
    func testTimeout() {
        let hello = "Hello World"
        let numberOfCharacters = countElements(hello)
        futureOnBackground {
            hello
        }.map { (x: String) -> Int in
            println("Starting")
            NSThread.sleepForTimeInterval(1.second)
            println("Returning")
            return countElements(x)
        }.addTimeout(100.milliseconds,  {
            println("Timeout")
        })
        NSThread.sleepForTimeInterval(2.second)

    }*/

}
