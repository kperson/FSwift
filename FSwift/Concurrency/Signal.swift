//
//  Signal.swift
//  FSwift
//
//  Created by Kelton Person on 11/13/14.
//  Copyright (c) 2014 Kelton. All rights reserved.
//

import Foundation

public enum TryStatus {
    
    case success
    case failure(Error)
}

open class Signal {
    
    fileprivate var f: ((TryStatus) -> ())?
    fileprivate var s: TryStatus?
    fileprivate var operationQueue: OperationQueue?
    
    public init() {
        
    }
    
    open func register(_ f: @escaping (TryStatus) -> ()) {
        self.f = f
        finish()
    }
    
    open func complete(_ status: TryStatus, _ operationQueue: OperationQueue? = nil) {
        self.operationQueue = operationQueue
        self.s = status
        finish()
    }
    
    fileprivate func finish() {
        if(self.f != nil && self.s != nil) {
            if let queue = self.operationQueue {
                let operationCallback = BlockOperation {
                    self.f!(self.s!)
                }
                queue.addOperation(operationCallback)
            }
            else {
                self.f!(self.s!)
            }
        }
    }
    
}
