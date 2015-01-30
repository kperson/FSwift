//
//  JSONDecoder.swift
//  FSwift
//
//  Created by Maxime Ollivier on 1/28/15.
//  Copyright (c) 2015 Kelton. All rights reserved.
//

import Foundation

class JSONDecoder: Decoder {
    
    class func decoderWithJsonData(data:NSData) -> Try<JSONDecoder> {
        var error:NSError?
        
        if let jsonObject:AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &error) {
            return Try.Success(JSONDecoder(value:jsonObject, parseType:true, depth:0))
        } else if let error = error {
            return Try.Failure(error)
        } else {
            return Try.Failure(NSError(domain: "com.jsondecoder", code: 0, userInfo: ["message":"Could not parse NSData"]))
        }
    }
    
}