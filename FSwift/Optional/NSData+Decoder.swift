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
        do {
            let list = try NSJSONSerialization.JSONObjectWithData(self, options: NSJSONReadingOptions.AllowFragments) as? [AnyObject]
            return Try(success : Decoder(array: list!, depth: 0))
        }
        catch let err as NSError {
            return Try<Decoder>(failure: err)
        
        }
    }
    
    public var dictDecoderFromJSON:Try<Decoder> {
        do {
            let dict = try NSJSONSerialization.JSONObjectWithData(self, options: NSJSONReadingOptions.AllowFragments) as? [String : AnyObject]
            return Try(success: Decoder(dictionary: dict!, depth: 0))
        }
        catch let err as NSError {
            return Try<Decoder>(failure: err)
        }
    }
    
    public var isJSONDecodable:Bool {
        do {
            try NSJSONSerialization.JSONObjectWithData(self, options: NSJSONReadingOptions.AllowFragments) as? [String : AnyObject]
            return true
        }
        catch {
            return false
        }
    }
    
}