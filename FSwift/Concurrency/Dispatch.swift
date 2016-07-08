//
//  Dispatch.swift
//  FSwift
//
//  Created by Maxime Ollivier on 1/27/15.
//  Copyright (c) 2015 Kelton. All rights reserved.
//

import Foundation

public class Dispatch {

    public class func delay(_ delay:TimeInterval, closure:()->()) {
        let x = DispatchWallTime.now() + DispatchTimeInterval.milliseconds(Int(delay * 1000))
       DispatchQueue.main.after(walltime: x, execute: closure)
    }

    public class func background(_ block:()->()) {
        DispatchQueue.global(attributes: DispatchQueue.GlobalAttributes.qosDefault).async(execute: { () -> Void in
            block()
        })
    }

    public class func foreground(_ block:()->()) {
        DispatchQueue.main.async(execute: { () -> Void in
            block()
        })
    }

}
