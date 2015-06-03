//
//  NSData+Decoder.swift
//  TallyHo
//
//  Created by Kelton Person on 3/9/15.
//  Copyright (c) 2015 FSwift. All rights reserved.
//

import Foundation

public extension NSData {
    
    public var arrDecoderFromJSON:Try<Decoder> {
        var error: NSError?
        let list = NSJSONSerialization.JSONObjectWithData(self, options: NSJSONReadingOptions.AllowFragments, error: &error) as? [AnyObject]
        if let err = error {
            return Try<Decoder>(failure: err)
        }
        else {
            return Try(success : Decoder(array: list!, depth: 0))
        }
    }
    
    public var dictDecoderFromJSON:Try<Decoder> {
        var error: NSError?
        let dict = NSJSONSerialization.JSONObjectWithData(self, options: NSJSONReadingOptions.AllowFragments, error: &error) as? [String : AnyObject]
        if let err = error {
            return Try<Decoder>(failure: err)
        }
        else {
            return Try(success: Decoder(dictionary: dict!, depth: 0))
        }
    }
    
    public var isJSONDecodable:Bool {
        var error: NSError?
        let dict = NSJSONSerialization.JSONObjectWithData(self, options: NSJSONReadingOptions.AllowFragments, error: &error) as? [String : AnyObject]
        if let err = error {
            return false
        }
        else {
            return true
        }
    }
    
}