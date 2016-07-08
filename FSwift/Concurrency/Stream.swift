//
//  Stream.swift
//  FSwift
//
//  Created by Kelton Person on 4/8/15.
//  Copyright (c) 2015 Kelton. All rights reserved.
//

import Foundation

public final class Stream<T>  {
    
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
    
    private func synced(_ closure: () -> ()) {
        objc_sync_enter(self)
        closure()
        objc_sync_exit(self)
    }
    
    /**
    publishes a message to the sream
    
    - parameter v: - the value to publish
    
    - returns: the stream that received the publish request (self)
    */
    public func publish(_ v: T) -> Stream<T> {
        //synced {
        if self.isOpen {
            var last = self.subscriptions.count - 1
            while last >= 0 {
                if self.subscriptions[last].shouldExecute {
                    self.subscriptions[last].handle(v)
                }
                else {
                    self.subscriptions[last].stream = nil
                    self.subscriptions[last].isCancelled = true
                    self.subscriptions.remove(at: last)
                }
                last = last - 1
            }
        }
        //}
        return self
    }
    
    func clean() {
        synced {
            if self.isOpen {
                var last = self.subscriptions.count - 1
                while last >= 0 {
                    if !self.subscriptions[last].shouldExecute {
                        self.subscriptions.remove(at: last)
                    }
                    last = last - 1
                }
            }
        }
    }
    
    /**
    subscribes to the stream,
    this subscription will not received queued publisheds, only new publisheds
    
    - parameter s: - a stream subscription
    
    - returns: the stream that received the subscription request (self)
    */
    public func subscribe(_ s: Subscription<T>) -> Subscription<T> {
        s.stream = self
        self.subscriptions.append(s)
        return s
    }
    
    /**
    clears all subscriptions,
    note that all queued messages will be published, but no other messages can be published
    - returns: the stream that was cleared (self)
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
    
    internal(set) var isCancelled = false
    private let action:(T) -> Void
    private let executionCheck:() -> Bool
    private let callbackQueue: OperationQueue
    
    var stream: Stream<T>?
    
    public init(action: (T) -> Void, callbackQueue: OperationQueue = OperationQueue.main, executionCheck: () -> Bool) {
        self.action = action
        self.callbackQueue = callbackQueue
        self.executionCheck = executionCheck
    }
    
    func handle(_ v: T)  {
        let operation = BlockOperation {
            self.action(v)
        }
        callbackQueue.addOperation(operation)
    }
    
    /**
    Cancels the subscriptuon
    */
    public func cancel() {
        isCancelled = true
        
        //break the link between the stream and the subscription
        stream?.clean()
        stream = nil
    }
    
    /// determines if the subscription will receive a notification
    public var shouldExecute: Bool {
        return !isCancelled && executionCheck()
    }
    
}


public extension Stream {
    
    /**
    subscribes to the stream
    
    - parameter -: x an object, if nil the subscription is cancelled
    - parameter -: f the action to be executed on publish
    
    - returns: the subscription
    */
    public func subscribe(_ x: AnyObject?, f: (T) -> Void) -> Subscription<T> {
        let subscription = Subscription<T>(action: f, callbackQueue: OperationQueue.main, executionCheck: { x != nil })
        return self.subscribe(subscription)
    }
    
    /**
    subscribes to the stream
    
    - parameter -: x function to be evaluated at publish time, if its produces a nil, the subscription is cancelled
    - parameter -: f the action to be executed on publish
    
    - returns: the stream that received the subscription request (self)
    */
    public func subscribe(_ x: () -> AnyObject?, f: (T) -> Void) -> Subscription<T> {
        let subscription = Subscription(action: f, callbackQueue: OperationQueue.main, executionCheck: { x() != nil })
        return self.subscribe(subscription)
    }
    
    
    /**
    subscribes to the stream
    
    - parameter -: x a boolean, if its false, the subscription is cancelled
    - parameter -: f the action to be executed on publish
    
    - returns: the subscription
    */
    public func subscribe(_ x: Bool, f: (T) -> Void) -> Subscription<T> {
        let subscription = Subscription<T>(action: f, callbackQueue: OperationQueue.main, executionCheck: { x })
        return self.subscribe(subscription)
    }
    
    /**
    subscribes to the stream
    
    - parameter -: x a function to be evaluated at publish time, if its produces a false, the subscription is cancelled
    - parameter -: f the action to be executed on publish
    
    - returns: the subscription request
    */
    public func subscribe(_ x: () -> Bool, f: (T) -> Void) -> Subscription<T> {
        let subscription = Subscription(action: f, callbackQueue: OperationQueue.main, executionCheck: { x() })
        return self.subscribe(subscription)
    }
    
    
    /**
    subscribes to the stream, it will always receive a publish callback
    
    - parameter -: f the action to be executed on publish
    
    - returns: the subscription
    */
    public func subscribe(_ f: (T) -> Void) -> Subscription<T>  {
        let subscription = Subscription(action: f, callbackQueue: OperationQueue.main, executionCheck: { true })
        return self.subscribe(subscription)
    }
    
}

public extension Future {
    
    public func pipeToOnFilter(_ stream: Stream<T>, _ on: (T) -> Bool) -> Future<T> {
        self.signal.register { status in
            switch status {
            case TryStatus.success:
                if on(self.finalVal) {
                    stream.publish(self.finalVal)
                }
            case TryStatus.failure(_):
                1 + 1 //do nothing
            }
        }
        return self
        
    }
    
    public func pipeToOn(_ stream: Stream<Try<T>>, _ on: (Try<T>) -> Bool) -> Future<T> {
        self.signal.register { status in
            if on(self.value!) {
                switch status {
                case TryStatus.success:
                    stream.publish(Try.Success(self.finalVal))
                case TryStatus.failure(let err):
                    stream.publish(Try.Failure(err))
                }
            }
        }
        return self
    }
    
    public func pipeToOn(_ stream: Stream<Try<T>>, _ on: (T) -> Bool) -> Future<T> {
        self.signal.register { status in
            switch status {
            case TryStatus.success:
                if on(self.finalVal) {
                    stream.publish(Try.Success(self.finalVal))
                }
            default:
                1 + 1 //do bothing
            }
        }
        return self
    }
    
    public func pipeTo(_ stream: Stream<T>) -> Future<T> {
        return self.pipeToOnFilter(stream, { x in true })
    }
    
    public func pipeTo(_ stream: Stream<Try<T>>) -> Future<T> {
        return self.pipeToOn(stream, { (x:Try<T>) -> Bool in true })
    }
    
}

public class StreamHandler<T> {
    
    let s: Stream<Try<T>>
    
    private var completionF: ((Try<T>) -> ())?
    private var successF: ((T) -> ())?
    private var failureF: ((NSError) -> ())?
    
    public private(set) var subscription: Subscription<Try<T>>?
    
    public init(_ s: Stream<Try<T>>) {
        self.s = s
        setup()
    }
    
    func setup() {
        let sub = s.subscribe { t in
            if let e = t.error {
                self.failureF?(e)
            }
            else {
                self.successF?(t.value!)
            }
            self.completionF?(t)
        }
        self.subscription = sub
    }
    
    /**
    * @param f - A function that a T as its only argument
    *
    * Registers a completion callback
    */
    public func onComplete(_ f: (Try<T>) -> ()) -> StreamHandler<T> {
        self.completionF = f
        return self
    }
    
    /**
    * :param f - A function that a T as its only argument
    *
    * Registers a success callback
    */
    public func onSuccess(_ f: (T) -> ()) -> StreamHandler<T> {
        self.successF = f
        return self
    }
    
    /**
    * :param f - A function that a T as its only argument
    *
    * Registers a failure callback
    */
    public func onFailure(_ f: (NSError) -> ()) -> StreamHandler<T> {
        self.failureF = f
        return self
    }
    
    
}

public class Continually<D> {
    
    var generatorAction: (D?) -> D
    
    public init(generatorAction: (D?) -> D) {
        self.generatorAction = generatorAction
    }
    
    public func whileHaving(_ cw: (D) -> Bool) -> Stream<(D, D?)> {
        let stream = Stream<(D, D?)>()
        let asyncGeneration = BlockOperation {
            var old: D? = nil
            while(true) {
                let new = self.generatorAction(old)
                if cw(new) {
                    let rs = (new, old)
                    let _ = stream.publish(rs)
                    old = new
                }
                else {
                    break;
                }
            }
        }
        defaultFutureQueue.addOperation(asyncGeneration)
        return stream
    }
    
    public func until(_ u: (D) -> Bool) -> Stream<(D, D?)> {
        return whileHaving { x in !u(x) }
    }
    
}


public extension Stream {
    
    public class func continually<D>(_ f: (D?) -> D) -> Continually<D> {
        return Continually(generatorAction: f)
    }
    
    public func map<B>(_ f: (T) -> B) -> Stream<B> {
        let stream = Stream<B>()
        subscribe { x in
            let _ = stream.publish(f(x))
        }
        return stream
    }
    
    public func flatMap<B>(_ f: (T) -> B?) -> Stream<B> {
        let s = Stream<B>()
        subscribe { x in
            if let v = f(x) {
                let _ = s.publish(v)
            }
        }
        return s
    }
    
    public func filter(_ f: (T) -> Bool) -> Stream<T> {
        let s = Stream<T>()
        subscribe { x in
            if f(x) {
                s.publish(x)
            }
        }
        return s
    }
    
    public func foreach(_ f: (T) -> Void) {
        subscribe { x in
            f(x)
        }
    }
    
    public func skip(_ amount: Int) -> Stream<T> {
        var i = 0
        let stream = Stream<T>()
        foreach { x in
            if i >= amount {
                stream.publish(x)
            }
            i += 1
        }
        return stream
    }
    
    
}


