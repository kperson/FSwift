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
        let _ = stream.subscribe(nil) { x in Void() }
        
        let _ = stream.clearSubscriptions()
        XCTAssertTrue(stream.subscriptions.isEmpty, "clearSubscriptions should empty the stream")
    }
    
    func testSubscribeBinding() {
        let stream = Stream<String>()
        
        let _ = stream.clearSubscriptions()
        let _ = stream.subscribe(nil) { x in Void() }
        XCTAssertFalse(stream.subscriptions.first!.shouldExecute, "streams only execute if the bind is not nil")
        
        let _ = stream.clearSubscriptions()
        let _ = stream.subscribe({ nil } ) { x in Void() }
        XCTAssertFalse(stream.subscriptions.first!.shouldExecute, "streams only execute if the bind is not nil")
        
        let _ = stream.clearSubscriptions()
        let _ = stream.subscribe(false) { x in Void() }
        XCTAssertFalse(stream.subscriptions.first!.shouldExecute, "streams only execute if the bind is true")
        
        let _ = stream.clearSubscriptions()
        let _ = stream.subscribe(true) { x in Void() }
        XCTAssertTrue(stream.subscriptions.first!.shouldExecute, "streams only execute if the bind is true")
        
        
        let _ = stream.clearSubscriptions()
        let _ = stream.subscribe() { x in Void() }
        XCTAssertTrue(stream.subscriptions.first!.shouldExecute, "subscribe should default to allowing execution")
    }
    
    func testOpenPublishAndSubscribe() {
        var ct = 0
        let numPublishes = 4
        let numSubscribers = 2
        let value =  UUID().uuidString
        let exp = expectation(description: "testOpenPublishAndSubscribe")
        let stream = Stream<String>()
        for _ in 0...numSubscribers - 1 {
            let _ = stream.subscribe { str in
                XCTAssertEqual(value, str, "stream must publish the correct value")
                ct = ct + 1
                if ct == numPublishes * numSubscribers {
                    exp.fulfill()
                }
            }
            for _ in 0...numPublishes - 1 {
                let _ = stream.publish(value)
            }
        }
        waitForExpectations(timeout: 2.seconds, handler: nil)
        
    }
    
    func testExplicitSubscriptionCancel() {
        let subscription = Subscription<String>(action: { x in Void() }, callbackQueue: OperationQueue.main, executionCheck: { true })
        XCTAssertTrue(subscription.shouldExecute, "subscription should be active if execution check returns true and cancel has not been called")
        
        subscription.cancel()
        XCTAssertFalse(subscription.shouldExecute, "subscription should deactivate if cancel is called")
        
        let stream = Stream<String>()
        let subscription2 = Subscription<String>(action: { x in Void() }, callbackQueue: OperationQueue.main, executionCheck: { true })
        let _ = stream.subscribe(subscription2)
        subscription2.cancel()
        
        XCTAssertTrue(stream.subscriptions.isEmpty, "cancel should immediately remove subscription from the stream")
    }
    
    func testClosedPublishAndSubscribe() {
        let exp = expectation(description: "testClosedPublishAndSubscribe")
        let stream = Stream<String>()
        let _ = stream.subscribe() { x in XCTAssertTrue(false, "this line should never execute since the stream is closed")
            exp.fulfill()
        }
        stream.close()
        let _ = stream.publish("hello")
        let _ = stream.clearSubscriptions()
        
        stream.open()
        let _ = stream.subscribe() { x in
            XCTAssertTrue(true, "this line should execute since the stream in open")
            exp.fulfill()
        }
        let _ = stream.publish("hello")
        

        waitForExpectations(timeout: 2.seconds, handler: nil)

    }
    
    
    func testAutoCancel() {
        let exp = expectation(description: "testAutoCancel")
        let stream = Stream<String>()
        let _ = stream.subscribe(nil) { x in Void() }
        let _ = stream.subscribe("car") { x in Void() }
        let _ = stream.subscribe("hello") { x in
            XCTAssertTrue(true, "this line should execute since the stream in open")
            exp.fulfill()
        }
        let _ = stream.publish("bob")
        waitForExpectations(timeout: 2.seconds, handler: { err in
            XCTAssertEqual(stream.subscriptions.count, 2, "cancelled subscriptions should automatically be cleared from callback list")
        })

    }
    
    
    func testFutureTryPiping() {
        var publishCt = 0
        let message = "hello"
        let exp = expectation(description: "testFuturePiping")
        let stream = Stream<String>()
        let _ = stream.subscribe { x in
            publishCt = publishCt + 1
            XCTAssertTrue(true, "this line should execute since we are publishing via future pipe")
            XCTAssertEqual(message, x, "pipe must generate the correct message")
            exp.fulfill()
        }
        
        let _ = future {
            Try.success(message)
        }.pipeTo(stream)
        
        waitForExpectations(timeout: 2.seconds, handler:nil)
    }
    
    func testFutureTryPipingFailure() {
        var publishCt = 0
        let exp = expectation(description: "testFuturePiping")
        let stream = Stream<Try<String>>()
        let _ = stream.subscribe { x in
            publishCt = publishCt + 1
            XCTAssertTrue(true, "this line should execute since we are publishing via future pipe")
            XCTAssertNil(x.value, "try must be passed on failure")
            exp.fulfill()
        }
        
        let err = NSError(domain: "A", code: 0, userInfo: nil)
        let _ = future {
            Try<String>.failure(err)
        }.pipeTo(stream)
        
        waitForExpectations(timeout: 2.seconds, handler:nil)
    }
    
    func testFutureTryPipingSuccess() {
        var publishCt = 0
        let message = "hello"
        let exp = expectation(description: "testFuturePiping")
        let stream = Stream<Try<String>>()
        let _ = stream.subscribe { x in
            publishCt = publishCt + 1
            XCTAssertTrue(true, "this line should execute since we are publishing via future pipe")
            XCTAssertNil(x.error, "try must be passed on success")
            exp.fulfill()
        }
        
        let _ = future {
            Try<String>.success(message)
        }.pipeTo(stream)
        
        waitForExpectations(timeout: 2.seconds, handler:nil)
    }
    

    
}
