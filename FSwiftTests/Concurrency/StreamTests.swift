//
//  StreamTests.swift
//  FSwift
//
//  Created by Kelton Person on 4/8/15.
//  Copyright (c) 2015 Kelton. All rights reserved.
//

import Foundation
import XCTest

class StreamTests : XCTestCase {
    

    func testDefaultState() {
        let stream = Stream<String>()
        XCTAssertTrue(stream.isOpen, "stream should be open by default")
    }
    
    func testClearSubscriptions() {
        let stream = Stream<String>()
        stream.subscribe(nil) { x in Void() }
        
        stream.clearSubscriptions()
        XCTAssertTrue(stream.subscriptions.isEmpty, "clearSubscriptions should empty the stream")
    }
    
    func testSubscribeBinding() {
        let stream = Stream<String>()
        
        stream.clearSubscriptions()
        stream.subscribe(nil) { x in Void() }
        XCTAssertFalse(stream.subscriptions.first!.shouldExecute, "streams only execute if the bind is not nil")
        
        stream.clearSubscriptions()
        stream.subscribe({nil } ) { x in Void() }
        XCTAssertTrue(stream.subscriptions.first!.shouldExecute, "streams only execute if the bind is not nil")
        
        stream.clearSubscriptions()
        stream.subscribe(false) { x in Void() }
        XCTAssertFalse(stream.subscriptions.first!.shouldExecute, "streams only execute if the bind is true")
        
        stream.clearSubscriptions()
        stream.subscribe(true) { x in Void() }
        XCTAssertTrue(stream.subscriptions.first!.shouldExecute, "streams only execute if the bind is true")
        
        
        stream.clearSubscriptions()
        stream.subscribe() { x in Void() }
        XCTAssertTrue(stream.subscriptions.first!.shouldExecute, "subscribe should default to allowing execution")
    }
    
    func testOpenPublishAndSubscribe() {
        
        var ct = 0
        let numPublishes = 4
        let numSubscribers = 2
        let value =  NSUUID().UUIDString
        let exp = expectationWithDescription("check")
        let stream = Stream<String>()
        for s in 0...numSubscribers - 1 {
            stream.subscribe { str in
                XCTAssertEqual(value, str, "stream must publish the correct value")
                ct = ct + 1
                if ct == numPublishes * numSubscribers {
                    exp.fulfill()
                }
            }
            for x in 0...numPublishes - 1 {
                stream.publish(value)
            }
        }
        waitForExpectationsWithTimeout(2.seconds, handler: nil)
        
    }
    
    func testClosedPublishAndSubscribe() {
        let exp = expectationWithDescription("check")
        let stream = Stream<String>()
        stream.subscribe() { x in XCTAssertTrue(false, "this line should never execute since the stream is closed")
            exp.fulfill()
        }
        stream.close()
        stream.publish("hello")
        stream.clearSubscriptions()
        
        stream.open()
        stream.subscribe() { x in
            XCTAssertTrue(true, "this line should execute since the stream in open")
            exp.fulfill()
        }
        stream.publish("hello")
        waitForExpectationsWithTimeout(2.seconds, handler: nil)

    }
    
    
    func testAutoCancel() {
        let exp = expectationWithDescription("check")
        let stream = Stream<String>()
        stream.subscribe(nil) { x in Void() }
        stream.subscribe("car") { x in Void() }
        stream.subscribe("hello") { x in
            XCTAssertTrue(true, "this line should execute since the stream in open")
            exp.fulfill()
        }
        stream.publish("bob")
        waitForExpectationsWithTimeout(2.seconds, handler: { err in
            XCTAssertEqual(stream.subscriptions.count, 2, "cancelled subscriptions should automatically be cleared from callback list")
        })

    }
    

    
}