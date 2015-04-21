//
//  Stream.swift
//  FSwift
//
//  Created by Kelton Person on 4/8/15.
//  Copyright (c) 2015 Kelton. All rights reserved.
//

import Foundation

public final class Stream<T> {

    private(set) var isOpen: Bool = true
    private(set) var subscriptions:[Subscription<T>] = []
    
    
    public init() {
        
    }
    
    /**
    closes the stream, 
    note that all queued messages will be published, but no other messages can be published
    */
    public func close() {
        isOpen = false
    }
    
    /**
    opens the stream, by default, a stream is open
    */
    public func open() {
        isOpen = true
    }
    
    private func synced(closure: () -> ()) {
        objc_sync_enter(self)
        closure()
        objc_sync_exit(self)
    }
    
    /**
    publishes a message to the sream
    
    :param: v - the value to publish
    
    :returns: the stream that received the publish request (self)
    */
    public func publish(v: T) -> Stream<T> {
        synced {
            if self.isOpen {
                var last = self.subscriptions.count - 1
                while last >= 0 {
                    if self.subscriptions[last].shouldExecute {
                    self.subscriptions[last].handle(v)
                    }
                    else {
                        self.subscriptions.removeAtIndex(last)
                    }
                    last = last - 1
                }
            }
        }
        return self
    }

    /**
    subscribes to the stream,
    this subscription will not received queued publisheds, only new publisheds
    
    :param: s - a stream subscription
    
    :returns: the stream that received the subscription request (self)
    */
    public func subscribe(s: Subscription<T>) -> Subscription<T> {
        synced  {
            self.subscriptions.append(s)
        }
        return s
    }
    
    /**
    clears all subscriptions,
    note that all queued messages will be published, but no other messages can be published
    :returns: the stream that was cleared (self)
    */
    public func clearSubscriptions() -> Stream<T> {
        synced {
            self.subscriptions = []
        }
        return self
    }
}


/**
*  Manages streams subscriptions
*/
public class Subscription<T> {
    
    private(set) var isCancelled = false
    private let action:(T) -> Void
    private let executionCheck:() -> Bool
    private let callbackQueue: NSOperationQueue
    
    public init(action: (T) -> Void, callbackQueue: NSOperationQueue = NSOperationQueue.mainQueue(), executionCheck: () -> Bool) {
        self.action = action
        self.callbackQueue = callbackQueue
        self.executionCheck = executionCheck
    }
    
    public func handle(v: T)  {
        let operation = NSBlockOperation {
            self.action(v)
        }
        callbackQueue.addOperation(operation)
    }
    
    public func cancel() {
        isCancelled = true
    }
    
    
    public var shouldExecute: Bool {
        return !isCancelled && executionCheck()
    }
    
}


public extension Stream {
    
    /**
    subscribes to the stream
    
    :param: - x an object, if nil the subscription is cancelled
    :param: - f the action to be executed on publish
    
    :returns: the subscription
    */
    public func subscribe(x: AnyObject?, f: T -> Void) -> Subscription<T> {
        let subscription = Subscription<T>(action: f, callbackQueue: NSOperationQueue.mainQueue(), executionCheck: { x != nil })
        return self.subscribe(subscription)
    }
    
    /**
    subscribes to the stream
    
    :param: - x function to be evaluated at publish time, if its produces a nil, the subscription is cancelled
    :param: - f the action to be executed on publish
    
    :returns: the stream that received the subscription request (self)
    */
    public func subscribe(x: () -> AnyObject?, f: T -> Void) -> Subscription<T> {
        let subscription = Subscription(action: f, callbackQueue: NSOperationQueue.mainQueue(), executionCheck: { x() != nil })
        return self.subscribe(subscription)
    }
    
    
    /**
    subscribes to the stream
    
    :param: - x a boolean, if its false, the subscription is cancelled
    :param: - f the action to be executed on publish
    
    :returns: the subscription
    */
    public func subscribe(x: Bool, f: T -> Void) -> Subscription<T> {
        let subscription = Subscription<T>(action: f, callbackQueue: NSOperationQueue.mainQueue(), executionCheck: { x })
        return self.subscribe(subscription)
    }
    
    /**
    subscribes to the stream
    
    :param: - x a function to be evaluated at publish time, if its produces a false, the subscription is cancelled
    :param: - f the action to be executed on publish
    
    :returns: the subscription request
    */
    public func subscribe(x: () -> Bool, f: T -> Void) -> Subscription<T> {
        let subscription = Subscription(action: f, callbackQueue: NSOperationQueue.mainQueue(), executionCheck: { x() })
        return self.subscribe(subscription)
    }
    
    
    /**
    subscribes to the stream, it will always receive a publish callback
    
    :param: - f the action to be executed on publish
    
    :returns: the subscription
    */
    public func subscribe(f: T -> Void) -> Subscription<T>  {
        let subscription = Subscription(action: f, callbackQueue: NSOperationQueue.mainQueue(), executionCheck: { true })
        return self.subscribe(subscription)
    }
    
}

public extension Future {
    
    public func pipeTo(stream: Stream<T>) {
        self.signal.register { status in
            switch status {
            case TryStatus.Success:
                stream.publish(self.finalVal)
            case TryStatus.Failure(let err):
                1 + 1 //do nothing
            }
        }
    
    }
    
    public func pipeTo(stream: Stream<Try<T>>) {
        self.signal.register { status in
            switch status {
            case TryStatus.Success:
                stream.publish(Try.Success(self.finalVal))
            case TryStatus.Failure(let err):
                stream.publish(Try.Failure(err))
            }
        }
    }
    
}


