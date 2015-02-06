//
//  JSONDecoder.swift
//  FSwift
//
//  Created by Maxime Ollivier on 1/28/15.
//  Copyright (c) 2015 Kelton. All rights reserved.
//

import Foundation

extension Decoder {
    
    public class func decoderWithJsonData(data:NSData) -> Try<Decoder> {
        var error:NSError?
        
        if data.length > 0 {
            if let jsonObject:AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &error) {
                return Try.Success(Decoder(value:jsonObject, parseType:true, depth:0))
            } else if let error = error {
                return Try.Failure(error)
            } else {
                return Try.Failure(NSError(domain: "com.jsondecoder", code: 0, userInfo: ["message":"Could not parse NSData"]))
            }
        } else {
            return Try.Success(Decoder())
        }
    }
    
}