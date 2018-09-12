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



enum BindCheck {
    
    case boolCheck(() -> Bool)
    case anyObjectCheck(() -> Any?)
    
    var shouldExecute:Bool {
        switch self {
        case .boolCheck(let f): return f()
        case .anyObjectCheck(let f): return f() != nil
        }
    }
    
}

public class Promise<T> {
    
    public let future: Future<T>
    
    public init(operationQueue: OperationQueue = FutureQueues.defaultFutureQueue, callbackQueue:OperationQueue = OperationQueue.main) {
        future = Future(operationQueue: operationQueue, callbackQueue:callbackQueue)
    }
    
    public func completeWith(_ f:@escaping () -> Try<T>) {
        future.completeWith(f)
    }
    
    public func completeWith(_ val: T) {
        future.completeWith(val)
    }
    
    public func completeWith(_ error: NSError) {
        future.completeWith(error)
    }
    
}

public class FutureQueues {
    
    public static let defaultFutureQueue = OperationQueue()
    
}

public class Future<T> {
    
    private var f: (() -> Try<T>)? = nil
    private var futureValue: Try<T>?
    private var completionF: ((Try<T>) -> ())?
    private var mappedCompletionF:((Try<T>) -> ())?
    
    private var bindCheck: BindCheck = BindCheck.boolCheck({ true })
    
    private var interalCompletionHandler:(() -> ())?
    
    private var successF: ((T) -> ())?
    private var recoverF: ((NSError) -> Future<T>)?
    private var mappedRecoverF: ((NSError) -> Try<T>)?
    private var recoverFilter: ((NSError) -> Bool) = { err in true }
    
    private var failureF: ((NSError) -> ())?
    private var signals: [Signal] = []
    
    let operationQueue: OperationQueue
    let callbackQueue: OperationQueue
    
    public init(_ f: @escaping () -> Try<T>, operationQueue: OperationQueue = FutureQueues.defaultFutureQueue, callbackQueue:OperationQueue = OperationQueue.main) {
        self.operationQueue = operationQueue
        self.callbackQueue = callbackQueue
        self.completeWith(f)
    }
    
    public init(operationQueue: OperationQueue = FutureQueues.defaultFutureQueue, callbackQueue:OperationQueue = OperationQueue.main) {
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
                signal.complete(TryStatus.success, self.callbackQueue)
                
            case (_, let error):
                signal.complete(TryStatus.failure(error!), self.callbackQueue)
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
    func completeWith(_ f:@escaping () -> Try<T>) {
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
    func completeWith(_ val: T) {
        self.completeWith({ Try<T>.success(val) })
    }
    
    /**
     * :param val - error NSerror.
     *
     * This allows for an error to complete the future.  If you are just using futures, then this is not required.  This is something like fulfilling a promise.
     * You can use this to bridge the Future api with other concurrency frameworks and async methods.
     */
    func completeWith(_ error: NSError) {
        self.completeWith({ Try<T>.failure(error) })
    }
    
    /**
     * @param f - A function that a T as its only argument
     *
     * Registers a completion callback
     */
    public func onComplete(_ f:@escaping (Try<T>) -> ()) -> Future<T> {
        self.completionF = f
        return self
    }
    
    /**
     * :param f - A function that a T as its only argument
     *
     * Registers a success callback
     */
    public func onSuccess(_ f:@escaping (T) -> ()) -> Future<T> {
        self.successF = f
        return self
    }
    
    /**
     * :param f - A function that a T as its only argument
     *
     * Registers a failure callback
     */
    public func onFailure(_ f:@escaping (NSError) -> ()) -> Future<T> {
        self.failureF = f
        return self
    }
    
    public func recoverWithFuture(_ f:@escaping (NSError) -> Future<T>) -> Future<T> {
        self.recoverF = f
        return self
    }
    
    public func recover(_ f:@escaping (NSError) -> Try<T>) -> Future<T> {
        self.mappedRecoverF = f
        return self
    }
    
    public func recoverOn(_ f: @escaping (NSError) -> Bool) -> Future<T> {
        self.recoverFilter = f
        return self
    }
    
    public func bindToBool(_ b:@escaping () -> Bool) -> Future<T> {
        self.bindCheck = BindCheck.boolCheck(b)
        return self
    }
    
    public func bindToOptional(_ b: @escaping () -> Any?) -> Future<T> {
        self.bindCheck = BindCheck.anyObjectCheck(b)
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
    public func map<D>(_ f: @escaping (T) -> Try<D>) -> Future<D> {
        let mappedFuture = Future<D>(operationQueue: self.operationQueue, callbackQueue: self.callbackQueue)
        self.mappedCompletionF = { futureValue in
            mappedFuture.completeWith {
                if let successfulValue = futureValue.value {
                    return f(successfulValue)
                }
                else {
                    return Try<D>.failure(futureValue.error!)
                }
            }
        }
        return mappedFuture
    }
    
    public func flatMap<D>(_ f: @escaping (T) -> Future<D>) -> Future<D> {
        let mappedFuture = Future<D>(operationQueue: self.operationQueue, callbackQueue: self.callbackQueue)
        self.mappedCompletionF = {futureValue in
            if futureValue.value != nil {
                let _ = f(futureValue.value!)
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
        let operation = BlockOperation {
            self.futureValue = self.f!()
            switch (self.recoverF, self.mappedRecoverF, self.futureValue!.toTuple.1) {
            case (.some(let r), _, .some(let error)):
            
                if self.recoverFilter(error) {
                    let _ = r(error).onComplete { [unowned self] t in
                        self.futureValue = t
                        self.futureExecutionComplete()
                    }
                }
                else {
                    self.futureExecutionComplete()
                }
            case (_, .some(let m), .some(let error)):
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
            let operationCallback = BlockOperation {
                self.completionF?(self.futureValue!)
                switch self.futureValue!.toTuple {
                case (.some(let val), _):
                    self.successF?(val)
                case (_, .some(let error)):
                    self.failureF?(error)
                default:
                    self.handleImpossibleMatch()
                }
                self.mappedCompletionF?(self.futureValue!)
                self.interalCompletionHandler?()
                
                switch self.futureValue!.toTuple {
                case (.some(_), _):
                    for x in self.signals {
                        x.complete(TryStatus.success)
                    }
                case (_, .some(let error)):
                    for x in self.signals {
                        x.complete(TryStatus.failure(error))
                    }
                default:
                    self.handleImpossibleMatch()
                }
                self.successF = nil
                self.failureF = nil
                self.mappedRecoverF = nil
                self.mappedCompletionF = nil
                self.completionF = nil
                self.interalCompletionHandler = nil
                self.recoverF = nil
                self.recoverFilter = { err in true }
                self.f = nil
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

public func combineFutures(_ signals: Signal...) -> Future<Void> {
    return combineFuturesWithOptions(signals, operationQueue: FutureQueues.defaultFutureQueue, callbackQueue: OperationQueue.main)
}

public func combineFuturesOnBackground(_ signals: Signal...) -> Future<Void> {
    return combineFuturesWithOptions(signals, operationQueue: FutureQueues.defaultFutureQueue, callbackQueue: FutureQueues.defaultFutureQueue)
}

public func combineFutures(_ signals: [Signal]) -> Future<Void> {
    return combineFuturesWithOptions(signals, operationQueue: FutureQueues.defaultFutureQueue, callbackQueue: OperationQueue.main)
}

public func combineFuturesOnBackground(_ signals: [Signal]) -> Future<Void> {
    return combineFuturesWithOptions(signals, operationQueue: FutureQueues.defaultFutureQueue, callbackQueue: FutureQueues.defaultFutureQueue)
}

public func combineFuturesWithOptions(_ signals: [Signal], operationQueue: OperationQueue = FutureQueues.defaultFutureQueue, callbackQueue:OperationQueue = OperationQueue.main) -> Future<Void> {
    let f = Future<Void>(operationQueue: operationQueue, callbackQueue: callbackQueue)
    var ct = 0
    for x in signals {
        x.register { status in
            switch status {
            case TryStatus.success:
                ct = ct + 1
                if ct == signals.count {
                    f.completeWith(Void())
                }
            case TryStatus.failure(let error):
                f.completeWith(error)
            }
        }
    }
    return f
}


public func future<T>(_ f: @escaping () -> Try<T>) -> Future<T> {
    return Future(f)
}

public func futureOnBackground<T>(_ f: @escaping () -> Try<T>) -> Future<T> {
    return Future(f, operationQueue: FutureQueues.defaultFutureQueue, callbackQueue: FutureQueues.defaultFutureQueue)
}
