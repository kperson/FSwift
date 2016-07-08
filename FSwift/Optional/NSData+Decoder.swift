//
//  NSData+Decoder.swift
//  TallyHo
//
//  Created by Kelton Person on 3/9/15.
//  Copyright (c) 2015 FSwift. All rights reserved.
//

import Foundation

public extension Data {
    
    public var arrDecoderFromJSON:Try<Decoder> {
        do {
            let list = try JSONSerialization.jsonObject(with: self, options: JSONSerialization.ReadingOptions.allowFragments) as? [AnyObject]
            return Try(success : Decoder(array: list!, depth: 0))
        }
        catch let err as NSError {
            return Try<Decoder>(failure: err)
        
        }
    }
    
    public var dictDecoderFromJSON:Try<Decoder> {
        do {
            let dict = try JSONSerialization.jsonObject(with: self, options: JSONSerialization.ReadingOptions.allowFragments) as? [String : AnyObject]
            return Try(success: Decoder(dictionary: dict!, depth: 0))
        }
        catch let err as NSError {
            return Try<Decoder>(failure: err)
        }
    }
    
    public var isJSONDecodable:Bool {
        do {
            try JSONSerialization.jsonObject(with: self, options: JSONSerialization.ReadingOptions.allowFragments) as? [String : AnyObject]
            return true
        }
        catch {
            return false
        }
    }
    
}
