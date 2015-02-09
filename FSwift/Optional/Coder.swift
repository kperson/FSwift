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
    public var bool:Bool?
    
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
        } else if let bool = bool {
            return bool
        }  else {
            var dict:[String:AnyObject] = [:]
            for (key, coder) in _coders {
                if !coder.isEmpty {
                    dict[key] = coder.object
                }
            }
            return dict
        }
    }
    
    private var isEmpty:Bool {
        return string == nil && bool == nil && _coders.isEmpty
    }
    
    public var decoder:Decoder {
        return Decoder(value: object, parseType: true, depth: 0)
    }
    
}