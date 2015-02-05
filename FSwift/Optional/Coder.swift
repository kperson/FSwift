//
//  Coder.swift
//  FSwift
//
//  Created by Maxime Ollivier on 2/4/15.
//  Copyright (c) 2015 Kelton. All rights reserved.
//

import UIKit

public class Coder: NSObject {
    
    private var _coders:[String:Coder] = [:]
    public var string:String?
    
    public subscript(key: String) -> Coder {
        if let coder = _coders[key] {
            return coder
        } else {
            let coder = Coder()
            _coders[key] = coder
            return coder
        }
    }
    
    public var object:AnyObject {
        if let string = string {
            return string
        } else {
            var dict:[String:AnyObject] = [:]
            for (key, value) in _coders {
                dict[key] = value.object
            }
            return dict
        }
    }
    
}
