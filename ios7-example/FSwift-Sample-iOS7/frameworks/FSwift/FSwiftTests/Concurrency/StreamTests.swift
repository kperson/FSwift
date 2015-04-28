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
        stream.subscribe({ nil } ) { x in Void() }
        XCTAssertFalse(stream.subscriptions.first!.shouldExecute, "streams only execute if the bind is not nil")
        
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
        let exp = expectationWithDescription("testOpenPublishAndSubscribe")
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
    
    func testExplicitSubscriptionCancel() {
        let subscription = Subscription<String>(action: { x in Void() }, callbackQueue: NSOperationQueue.mainQueue(), executionCheck: { true })
        XCTAssertTrue(subscription.shouldExecute, "subscription should be active if execution check returns true and cancel has not been called")
        
        subscription.cancel()
        XCTAssertFalse(subscription.shouldExecute, "subscription should deactivate if cancel is called")
        
        let stream = Stream<String>()
        let subscription2 = Subscription<String>(action: { x in Void() }, callbackQueue: NSOperationQueue.mainQueue(), executionCheck: { true })
        stream.subscribe(subscription2)
        subscription2.cancel()
        
        XCTAssertTrue(stream.subscriptions.isEmpty, "cancel should immediately remove subscription from the stream")
    }
    
    func testClosedPublishAndSubscribe() {
        let exp = expectationWithDescription("testClosedPublishAndSubscribe")
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
        let exp = expectationWithDescription("testAutoCancel")
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
    
    
    func testFutureTryPiping() {
        var publishCt = 0
        let message = "hello"
        let exp = expectationWithDescription("testFuturePiping")
        let stream = Stream<String>()
        stream.subscribe { x in
            publishCt = publishCt + 1
            XCTAssertTrue(true, "this line should execute since we are publishing via future pipe")
            XCTAssertEqual(message, x, "pipe must generate the correct message")
            exp.fulfill()
        }
        
        future {
            Try.Success(message)
        }.pipeTo(stream)
        
        waitForExpectationsWithTimeout(2.seconds, handler:nil)
    }
    
    func testFutureTryPipingFailure() {
        var publishCt = 0
        let message = "hello"
        let exp = expectationWithDescription("testFuturePiping")
        let stream = Stream<Try<String>>()
        stream.subscribe { x in
            publishCt = publishCt + 1
            XCTAssertTrue(true, "this line should execute since we are publishing via future pipe")
            XCTAssertNil(x.value, "try must be passed on failure")
            exp.fulfill()
        }
        
        future {
            Try<String>(failure: NSError())
        }.pipeTo(stream)
        
        waitForExpectationsWithTimeout(2.seconds, handler:nil)
    }
    
    func testFutureTryPipingSuccess() {
        var publishCt = 0
        let message = "hello"
        let exp = expectationWithDescription("testFuturePiping")
        let stream = Stream<Try<String>>()
        stream.subscribe { x in
            publishCt = publishCt + 1
            XCTAssertTrue(true, "this line should execute since we are publishing via future pipe")
            XCTAssertNil(x.error, "try must be passed on success")
            exp.fulfill()
        }
        
        future {
            Try<String>(success: message)
        }.pipeTo(stream)
        
        waitForExpectationsWithTimeout(2.seconds, handler:nil)
    }
    

    
}