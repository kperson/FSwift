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
    
    var f: (() -> T)? = nil
    var value: T?
    var completionF: ((T) -> Void)?
    var timeoutF: (() -> Void)?
    let operationQueue: NSOperationQueue
    let callbackQueue: NSOperationQueue
    var timeout: NSTimeInterval = -1
    var timeoutTimer: Timer? = nil
    
    public init(_ f: () -> T, operationQueue: NSOperationQueue = defaultFutureQueue, callbackQueue:NSOperationQueue = NSOperationQueue.mainQueue()) {
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
    public func bridgeExecution(f: () -> T) {
        self.f = f
        self.generateCallback()
    }

    /**
    * @param val - a T.  This allows for custom execution.  If you are just using futures.  This is not required.
    *
    * Call this method to add your own custom value.  You can use this to bridge the Future api with other concurrency frameworks and async methods.
    */
    public func bridgeValue(val: T) {
        self.bridgeExecution({ val })
    }
    
    /**
    * @param f - A function that a T as its only argument
    *
    * Registers a completion callback
    */
    public func onComplete(f: (T) -> Void) {
        self.completionF = f
    }
    
    /**
    * @param f - A function that a T as its only argument and returns a D
    * @return a Future<D> A future to be executed after the current Futture is completed.
    *
    * f is a function that will be executed as a Future after completion of current Future.  This method
    * handles all execution and scheduling.  The function takes the results current future as its single argument.
    * That is, it maps the results of current future to a new future
    */
    public func map<D>(f: (T) -> D) -> Future<D> {
        let newFuture = Future<D>(operationQueue: self.operationQueue, callbackQueue: self.callbackQueue)
        self.onComplete { x in
            newFuture.bridgeExecution {
                f(x)
            }
        }
        return newFuture
    }
    
    /*
    public func addTimeout(interval: NSTimeInterval,  f: () -> Void) -> Future<T>  {
        self.timeoutF = f
        self.timeout = interval
        return self
    }
    
    private func timeoutOccurred() {
        self.timeoutTimer?.stop()
        self.timeoutTimer = nil
        let timeoutOperation = NSBlockOperation {
            self.timeoutF!()
        }
        self.callbackQueue.addOperation(timeoutOperation)
    }*/
    
    private func generateCallback() {
       // if self.timeoutF != nil {
          //  self.timeoutTimer = Timer(interval: self.timeout, repeats: false, f:  {
            //    self.timeoutOccurred()
           // })
        //    self.timeoutTimer?.start()
       // }
        let callback = NSBlockOperation {
            self.value = self.f!()
            self.success()
        }
        self.operationQueue.addOperation(callback)
    }
    
    private func success() {
        if(self.timeoutTimer == nil) {
            let successOperation = NSBlockOperation {
                if let completion = self.completionF {
                    completion(self.value!)
                }
            }
            self.callbackQueue.addOperation(successOperation)
       }
    }
    
}


public func future<T>(f: () -> T) -> Future<T> {
    let x = Future(f)
    return x
}

public func futureOnBackground<T>(f: () -> T) -> Future<T> {
    let x = Future(f, operationQueue: defaultFutureQueue, callbackQueue: defaultFutureQueue)
    return x
}
