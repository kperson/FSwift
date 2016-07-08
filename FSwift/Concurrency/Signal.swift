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
    case failure(NSError)
}

public class Signal {
    
    private var f: ((TryStatus) -> ())?
    private var s: TryStatus?
    private var operationQueue: OperationQueue?
    
    public init() {
        
    }
    
    public func register(_ f: (TryStatus) -> ()) {
        self.f = f
        finish()
    }
    
    public func complete(_ status: TryStatus, _ operationQueue: OperationQueue? = nil) {
        self.operationQueue = operationQueue
        self.s = status
        finish()
    }
    
    private func finish() {
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
