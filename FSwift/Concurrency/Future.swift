//
//  Future.swift
//  FSwift
//
// This is an implementation of Futures and Proimises
// For more information see http://en.wikipedia.org/wiki/Futures_and_promises
//
//  Created by Kelton Person on 10/3/14.
//  Copyright (c) 2014 Kelton. All rights reserved.
//

import Foundation


let defaultFutureQueue = NSOperationQueue()

enum BindCheck {
    
    case BoolCheck(() -> Bool)
    case AnyObjectCheck(() -> AnyObject?)
    
    var shouldExecute:Bool {
        switch self {
        case BoolCheck(let f): return f()
        case AnyObjectCheck(let f): return f() != nil
        }
    }
    
}

public class Promise<T> {
    
    public let future: Future<T>
    
    public init(operationQueue: NSOperationQueue = defaultFutureQueue, callbackQueue:NSOperationQueue = NSOperationQueue.mainQueue()) {
        future = Future(operationQueue: operationQueue, callbackQueue:callbackQueue)
    }
    
    public func completeWith(f: () -> Try<T>) {
        future.completeWith(f)
    }
    
    public func completeWith(val: T) {
        future.completeWith(val)
    }
    
    public func completeWith(error: NSError) {
        future.completeWith(error)
    }

}

public class Future<T> {
    
    private var f: (() -> Try<T>)? = nil
    private var futureValue: Try<T>?
    private var completionF: ((Try<T>) -> ())?
    private var mappedCompletionF:((Try<T>) -> ())?
    
    private var bindCheck: BindCheck = BindCheck.BoolCheck({ true })
    
    private var interalCompletionHandler:(() -> ())?

    private var successF: ((T) -> ())?
    private var recoverF: ((NSError) -> Future<T>)?
    private var mappedRecoverF: ((NSError) -> Try<T>)?
    private var recoverFilter: ((NSError) -> Bool) = { err in true }
    
    private var failureF: ((NSError) -> ())?
    private var signals: [Signal] = []
    
    let operationQueue: NSOperationQueue
    let callbackQueue: NSOperationQueue
    
    public init(_ f: () -> Try<T>, operationQueue: NSOperationQueue = defaultFutureQueue, callbackQueue:NSOperationQueue = NSOperationQueue.mainQueue()) {
        self.operationQueue = operationQueue
        self.callbackQueue = callbackQueue
        self.completeWith(f)
    }
    
    public init(operationQueue: NSOperationQueue = defaultFutureQueue, callbackQueue:NSOperationQueue = NSOperationQueue.mainQueue()) {
        self.operationQueue = operationQueue
        self.callbackQueue = callbackQueue
    }
    
    public var signal: Signal {
        let signal = Signal()
        if futureValue == nil {
            signals.append(signal)
        }
        else {
            switch self.futureValue!.toTuple {
            case (let val, _) where val != nil:
                signal.complete(TryStatus.Success, self.callbackQueue)
                
            case (_, let error):
                signal.complete(TryStatus.Failure(error!), self.callbackQueue)
            }
        }
        return signal
    }
    
    /**
     * :param f - A zero argument function that returns a T.
     *
     * This allows for execution to complete the future.  If you are just using futures, then this is not required.  This is something like fulfilling a promise.
     * You can use this to bridge the Future api with other concurrency frameworks and async methods.
     */
    func completeWith(f: () -> Try<T>) {
        if self.f == nil {
            self.f = f
            self.generateCallback()
        }
    }

    /**
    * :param val - a T.
    *
    * This allows for a value to complete the future.  If you are just using futures, then this is not required.  This is something like fulfilling a promise.
    * You can use this to bridge the Future api with other concurrency frameworks and async methods.
    */
    func completeWith(val: T) {
        self.completeWith({ Try<T>(success: val) })
    }
    
    /**
    * :param val - error NSerror.
    *
    * This allows for an error to complete the future.  If you are just using futures, then this is not required.  This is something like fulfilling a promise.
    * You can use this to bridge the Future api with other concurrency frameworks and async methods.
    */
    func completeWith(error: NSError) {
        self.completeWith({ Try<T>(failure: error) })
    }
    
    /**
    * @param f - A function that a T as its only argument
    *
    * Registers a completion callback
    */
    public func onComplete(f: (Try<T>) -> ()) -> Future<T> {
        self.completionF = f
        return self
    }
    
    /**
    * :param f - A function that a T as its only argument
    *
    * Registers a success callback
    */
    public func onSuccess(f: (T) -> ()) -> Future<T> {
        self.successF = f
        return self
    }
    
    /**
    * :param f - A function that a T as its only argument
    *
    * Registers a failure callback
    */
    public func onFailure(f: (NSError) -> ()) -> Future<T> {
        self.failureF = f
        return self
    }
    
    public func recoverWithFuture(f: (NSError) -> Future<T>) -> Future<T> {
        self.recoverF = f
        return self
    }
    
    public func recover(f: (NSError) -> Try<T>) -> Future<T> {
        self.mappedRecoverF = f
        return self
    }
    
    public func recoverOn(f: (NSError) -> Bool) -> Future<T> {
        self.recoverFilter = f
        return self
    }
    
    public func bindToBool(b:() -> Bool) -> Future<T> {
        self.bindCheck = BindCheck.BoolCheck(b)
        return self
    }
    
    public func bindToOptional(b: () -> AnyObject?) -> Future<T> {
        self.bindCheck = BindCheck.AnyObjectCheck(b)
        return self
    }
    
    
    /**
    * :param f - A function that a T as its only argument and returns a D
    * :returns a Future<D> A future to be executed after the current Futture is completed.
    *
    * f is a function that will be executed as a Future after completion of current Future.  This method
    * handles all execution and scheduling.  The function takes the results current future as its single argument.
    * That is, it maps the results of current future to a new future
    */
    public func map<D>(f: (T) -> Try<D>) -> Future<D> {
        let mappedFuture = Future<D>(operationQueue: self.operationQueue, callbackQueue: self.callbackQueue)
        self.mappedCompletionF = { futureValue in
            mappedFuture.completeWith {
                if let successfulValue = futureValue.value {
                    return f(successfulValue)
                }
                else {
                    return Try<D>(failure: futureValue.error!)
                }
            }
        }
        return mappedFuture
    }
    
    public func flatMap<D>(f: (T) -> Future<D>) -> Future<D> {
        let mappedFuture = Future<D>(operationQueue: self.operationQueue, callbackQueue: self.callbackQueue)
        self.mappedCompletionF = {futureValue in
            if futureValue.value != nil {
                f(futureValue.value!)
                .onSuccess { x in
                    mappedFuture.completeWith(x)
                    return Void()
                }.onFailure { err in
                    mappedFuture.completeWith(err)
                    return Void()
                }
            }
            else {
                mappedFuture.completeWith(futureValue.error!)
            }
            
        }
        return mappedFuture
    }
    
    
    private func generateCallback() {
        let operation = NSBlockOperation {
            self.futureValue = self.f!()
            switch (self.recoverF, self.mappedRecoverF, self.futureValue!.toTuple.1) {
            case (.Some(let r), _, .Some(let error)):
                if self.recoverFilter(error) {
                    r(error).onComplete { t in
                        self.futureValue = t
                        self.futureExecutionComplete()
                    }
                }
                else {
                    self.futureExecutionComplete()
                }
            case (_, .Some(let m), .Some(let error)):
                if self.recoverFilter(error) {
                    self.futureValue = m(error)
                    self.futureExecutionComplete()
                }
                else {
                    self.futureExecutionComplete()
                }
            default:
                self.futureExecutionComplete()
            }
        }
        self.operationQueue.addOperation(operation)
        
    }
    
    private func futureExecutionComplete() {
        if self.bindCheck.shouldExecute {
            let operationCallback = NSBlockOperation {
                self.completionF?(self.futureValue!)
                switch self.futureValue!.toTuple {
                case (.Some(let val), _):
                    self.successF?(val)
                case (_, .Some(let error)):
                    self.failureF?(error)
                default:
                    self.handleImpossibleMatch()
                }
                self.mappedCompletionF?(self.futureValue!)
                self.interalCompletionHandler?()
                
                switch self.futureValue!.toTuple {
                case (.Some(_), _):
                    for x in self.signals {
                        x.complete(TryStatus.Success)
                    }
                case (_, .Some(let error)):
                    for x in self.signals {
                        x.complete(TryStatus.Failure(error))
                    }
                default:
                    self.handleImpossibleMatch()
                }

                
            }
            self.callbackQueue.addOperation(operationCallback)
        }
    }
    
    
    func handleImpossibleMatch() {
        /*
        This code can not execute, val and error are mutally exclusive
        Usually this is handle in an enum, but it appears that Swift does not allow for this (multi val generic enum)
        current, look for this to be re-enabled when iOS 9 beta is released
        */
        fatalError("value and error are mutally exclusive, you have reached an impossible matching condition")
    }
        
    public var value: Try<T>? {
        return self.futureValue
    }
    
    public var finalVal: T {
        return self.value!.value!
    }
    
}

public func combineFutures(signals: Signal...) -> Future<Void> {
    return combineFuturesWithOptions(signals, operationQueue: defaultFutureQueue, callbackQueue: NSOperationQueue.mainQueue())
}

public func combineFuturesOnBackground(signals: Signal...) -> Future<Void> {
    return combineFuturesWithOptions(signals, operationQueue: defaultFutureQueue, callbackQueue: defaultFutureQueue)
}

public func combineFutures(signals: [Signal]) -> Future<Void> {
    return combineFuturesWithOptions(signals, operationQueue: defaultFutureQueue, callbackQueue: NSOperationQueue.mainQueue())
}

public func combineFuturesOnBackground(signals: [Signal]) -> Future<Void> {
    return combineFuturesWithOptions(signals, operationQueue: defaultFutureQueue, callbackQueue: defaultFutureQueue)
}

public func combineFuturesWithOptions(signals: [Signal], operationQueue: NSOperationQueue = defaultFutureQueue, callbackQueue:NSOperationQueue = NSOperationQueue.mainQueue()) -> Future<Void> {
    let f = Future<Void>(operationQueue: operationQueue, callbackQueue: callbackQueue)
    var ct = 0
    for x in signals {
        x.register { status in
            switch status {
            case TryStatus.Success:
                ct = ct + 1
                if ct == signals.count {
                    f.completeWith(Void())
                }
            case TryStatus.Failure(let error):
                f.completeWith(error)
            }
        }
    }
    return f
}


public func future<T>(f: () -> Try<T>) -> Future<T> {
    return Future(f)
}

public func futureOnBackground<T>(f: () -> Try<T>) -> Future<T> {
    return Future(f, operationQueue: defaultFutureQueue, callbackQueue: defaultFutureQueue)
}