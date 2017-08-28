//
//  NSData+Decoder.swift
//  TallyHo
//
//  Created by Kelton Person on 3/9/15.
//  Copyright (c) 2015 FSwift. All rights reserved.
//

import Foundation

public extension Data {
    
    public var arrDecoderFromJSON:Try<FDecoder> {
        do {
            let list = try JSONSerialization.jsonObject(with: self, options: JSONSerialization.ReadingOptions.allowFragments) as? [Any]
            return Try.success(FDecoder(array: list!, depth: 0))
        }
        catch let err as NSError {
            return Try<FDecoder>.failure(err)
        
        }
    }
    
    public var dictDecoderFromJSON:Try<FDecoder> {
        do {
            let dict = try JSONSerialization.jsonObject(with: self, options: JSONSerialization.ReadingOptions.allowFragments) as? [String : Any]
            return Try.success(FDecoder(dictionary: dict!, depth: 0))
        }
        catch let err as NSError {
            return Try<FDecoder>.failure(err)
        }
    }
    
    public var isJSONDecodable:Bool {
        do {
            let _ = try JSONSerialization.jsonObject(with: self, options: JSONSerialization.ReadingOptions.allowFragments) as? [String : Any]
            return true
        }
        catch {
            return false
        }
    }
    
}
