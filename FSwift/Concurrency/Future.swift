//
//  Future.swift
//  FSwift
//
//  Created by Kelton Person on 10/3/14.
//  Copyright (c) 2014 Kelton. All rights reserved.
//

import Foundation

let defaultFutureQueue = NSOperationQueue()

public class Future<T> {
    
    private var f: (() -> Try<T>)? = nil
    private var value: Try<T>?
    private var completionF: ((Try<T>) -> ())?
    private var successF: ((T) -> ())?
    private var failureF: ((NSError) -> ())?
    
    private var mapSuccessF: ((T) -> ())?
    
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
    
    /**
     * @param f - A zero argument function that returns a T.  This allows for custom execution.  If you are just using futures.  This is not required.
     *
     * Call this method to add your own custom exeuction for the future.  You can use this to bridge the Future api with other concurrency frameworks and async methods.
     */
    public func bridgeExecution(f: () -> Try<T>) {
        self.f = f
        self.generateCallback()
    }

    /**
    * @param val - a T.  This allows for custom execution.  If you are just using futures, then this is not required.
    *
    * Call this method to add your own custom value.  You can use this to bridge the Future api with other concurrency frameworks and async methods.
    */
    public func bridgeSuccess(val: T) {
        self.bridgeExecution({ Try.Success(val) })
    }
    
    /**
    * @param error - a NSError.  This allows for custom execution error.  If you are just using futures, then this is not required.
    *
    * Call this method to add your own error value value.  You can use this to bridge the Future api with other concurrency frameworks and async methods.
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
    
    /**
    * @param f - A function that a T as its only argument and returns a D
    * @return a Future<D> A future to be executed after the current Futture is completed.
    *
    * f is a function that will be executed as a Future after completion of current Future.  This method
    * handles all execution and scheduling.  The function takes the results current future as its single argument.
    * That is, it maps the results of current future to a new future
    */
    public func map<D>(f: (T) -> Try<D>) -> Future<D> {
        let newFuture = Future<D>(operationQueue: self.operationQueue, callbackQueue: self.callbackQueue)
        self.mapSuccessF =  { x in
            newFuture.bridgeExecution {
                f(x)
            }
        }
        return newFuture
    }
    
    
    private func generateCallback() {
        let callback = NSBlockOperation {
            self.value = self.f!()
            self.futureExecutionComplete()
        }
        self.operationQueue.addOperation(callback)
    }
    
    private func futureExecutionComplete() {
        let successOperation = NSBlockOperation {
            self.completionF?(self.value!)
            switch self.value! {
            case Try.Success(let val):
                self.successF?(val())
                self.mapSuccessF?(val())
            case Try.Failure(let error):
                self.failureF?(error)
            }
        }
        self.callbackQueue.addOperation(successOperation)
    }
}


public func future<T>(f: () -> Try<T>) -> Future<T> {
    let x = Future(f)
    return x
}

public func futureOnBackground<T>(f: () -> Try<T>) -> Future<T> {
    let x = Future(f, operationQueue: defaultFutureQueue, callbackQueue: defaultFutureQueue)
    return x
}
