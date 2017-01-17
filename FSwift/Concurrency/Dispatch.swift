//
//  Dispatch.swift
//  FSwift
//
//  Created by Maxime Ollivier on 1/27/15.
//  Copyright (c) 2015 Kelton. All rights reserved.
//

import Foundation

public class Dispatch {

    open class func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }

    open class func background(_ block:@escaping ()->()) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            block()
        }
    }

    open class func foreground(_ block:@escaping ()->()) {
        DispatchQueue.main.async(execute: { () -> Void in
            block()
        })
    }

}
