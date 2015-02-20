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

public class Future<T> {
    
    private var f: (() -> Try<T>)? = nil
    private var futureValue: Try<T>?
    private var completionF: ((Try<T>) -> ())?
    private var mappedCompletionF:(() -> ())?

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
        self.bridgeExecution(f)
        
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
            switch self.futureValue! {
            case Try.Success(let val):
                signal.complete(TryStatus.Success, self.callbackQueue)
                
            case Try.Failure(let error):
                signal.complete(TryStatus.Failure(error), self.callbackQueue)
            }
        }
        return signal
    }
    
    /**
     * @param f - A zero argument function that returns a T.  
     *
     * This allows for execution to complete the future.  If you are just using futures, then this is not required.  This is something like fulfilling a promise.
     * You can use this to bridge the Future api with other concurrency frameworks and async methods.
     */
    public func bridgeExecution(f: () -> Try<T>) {
        if self.f == nil {
            self.f = f
            self.generateCallback()
        }
    }

    /**
    * @param val - a T.  
    *
    * This allows for a value to complete the future.  If you are just using futures, then this is not required.  This is something like fulfilling a promise.
    * You can use this to bridge the Future api with other concurrency frameworks and async methods.
    */
    public func bridgeSuccess(val: T) {
        self.bridgeExecution({ Try.Success(val) })
    }
    
    /**
    * @param val - error NSerror.
    *
    * This allows for an error to complete the future.  If you are just using futures, then this is not required.  This is something like fulfilling a promise.
    * You can use this to bridge the Future api with other concurrency frameworks and async methods.
    */
    public func bridgeFailure(error: NSError) {
        self.bridgeExecution({ Try.Failure(error) })
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
    * @param f - A function that a T as its only argument
    *
    * Registers a success callback
    */
    public func onSuccess(f: (T) -> ()) -> Future<T> {
        self.successF = f
        return self
    }
    
    /**
    * @param f - A function that a T as its only argument
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
    
    
    /**
    * @param f - A function that a T as its only argument and returns a D
    * @return a Future<D> A future to be executed after the current Futture is completed.
    *
    * f is a function that will be executed as a Future after completion of current Future.  This method
    * handles all execution and scheduling.  The function takes the results current future as its single argument.
    * That is, it maps the results of current future to a new future
    */
    public func map<D>(f: (T) -> Try<D>) -> Future<D> {
        let mappedFuture = Future<D>(operationQueue: self.operationQueue, callbackQueue: self.callbackQueue)
        self.mappedCompletionF = {
            mappedFuture.bridgeExecution {
                if let successfulValue = self.futureValue!.value {
                    return f(successfulValue)
                }
                else {
                    return Try.Failure(self.futureValue!.error!)
                }
            }
        }
        return mappedFuture
    }
    
    public func mapToFuture<D>(f: (T) -> Future<D>) -> Future<D> {
        let mappedFuture = Future<D>(operationQueue: self.operationQueue, callbackQueue: self.callbackQueue)
        self.mappedCompletionF = {
            if self.futureValue!.value != nil {
                f(self.futureValue!.value!)
                    .onSuccess { x in
                        mappedFuture.bridgeSuccess(x)
                        return Void()
                        
                    }.onFailure { err in
                        mappedFuture.bridgeFailure(err)
                        return Void()
                }
            }
            else {
                mappedFuture.bridgeFailure(self.futureValue!.error!)
            }
            
        }
        return mappedFuture
    }
    
    
    private func generateCallback() {
        let operation = NSBlockOperation {
            self.futureValue = self.f!()
            switch (self.recoverF, self.mappedRecoverF, self.futureValue!) {
            case (.Some(let r), _, Try.Failure(let error)):
                if self.recoverFilter(error) {
                    r(error).onComplete { try in
                        self.futureValue = try
                        self.futureExecutionComplete()
                    }
                }
                else {
                    self.futureExecutionComplete()
                }
            case (_, .Some(let m), Try.Failure(let error)):
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
        let operationCallback = NSBlockOperation {
            self.completionF?(self.futureValue!)
            switch self.futureValue! {
                case Try.Success(let val):
                    self.successF?(val())
                case Try.Failure(let error):
                    self.failureF?(error)
            }
            self.mappedCompletionF?()
            self.interalCompletionHandler?()
            
            switch self.futureValue! {
            case Try.Success(let val):
                for x in self.signals {
                    x.complete(TryStatus.Success)
                }
            case Try.Failure(let error):
                for x in self.signals {
                    x.complete(TryStatus.Failure(error))
                }
                
            }
            
        }
        self.callbackQueue.addOperation(operationCallback)
    }
    
    public class func await(futureList: [Future<T>], completionHandler: () -> ()) {
        var ct = 0
        for f in futureList {
            if f.futureValue == nil {
                f.interalCompletionHandler = {
                    ct = ct + 1
                    if ct == countElements(futureList) {
                        completionHandler()
                    }
                }
            }
            else {
                ct = ct + 1
                if ct == countElements(futureList) {
                    completionHandler()
                }
            }
        }
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
                    f.bridgeSuccess(Void())
                }
            case TryStatus.Failure(let error):
                f.bridgeFailure(error)
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