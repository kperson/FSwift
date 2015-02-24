//
//  Decoder.swift
//  FSwift
//
//  Created by Kelton Person on 1/15/15.
//  Copyright (c) 2015 Kelton. All rights reserved.
//

import Foundation

public extension Decoder {
    
    public var string: String? {
        if let string = self.val as? String {
            return (string.isEmpty) ? nil : string
        } else {
            return nil
        }
    }
    
    public func hasString(key:String) -> Bool {
        return self[key].string != nil
    }
    
    public var int: Int? {
        return self.val as? Int
    }
    
    public var double: Double? {
        return self.val as? Double
    }
    
    public var float: Float? {
        return self.val as? Float
    }
    
    public var bool: Bool? {
        if let x = self.val as? Bool {
            return x
        } else if let x = self.val as? String {
            return Bool(string:x)
        } else {
            return nil
        }
    }
    
    public var stringArray: [String]? {
        return self.val as? [String]
    }
    
    public var errorMessage: String? {
        if let err = self.err as NSError? {
            return err.userInfo!["message"] as String?
        }
        return nil
    }
    
}

public class Decoder {
    
    let notAnArrayError = NSError(domain: "com.optionreader", code: 2, userInfo: [ "message" : "data is not array like" ])
    let notADictionaryError = NSError(domain: "com.optionreader", code: 3, userInfo: [ "message" : "data is not dictionary like" ])
    
    
    private var rawDictionary: [String : AnyObject]?
    private var rawArray: [AnyObject]?
    private var value: AnyObject?
    private var error: NSError?
    let depth: Int
    
    // MARK: Init
    
    public init(dictionary: [String : AnyObject], depth: Int = 0) {
        self.rawDictionary = dictionary
        self.depth = depth
    }
    
    public init(array: [AnyObject], depth: Int = 0) {
        self.rawArray = array
        self.depth = depth
    }
    
    public init(value: AnyObject, parseType: Bool = false, depth: Int = 0) {
        self.depth = depth
        if !parseType {
            self.value = value
        }
        else {
            if let a = value as? [AnyObject] {
                self.rawArray = a
            }
            else if let d = value as? [String : AnyObject] {
                self.rawDictionary = d
            }
            else {
                self.value = value
            }
        }
    }
    
    private init(error: NSError, depth: Int = 0) {
        self.depth = depth
        self.error = error
    }
    
    public init() { //Empty
        self.depth = 0
    }
    
    // MARK: Values
    
    public var arr: DecoderArray? {
        if let a = rawArray {
            return DecoderArray(items: a)
        }
        else {
            return nil
        }
    }
    
    public var dict: DecoderDictionary? {
        if let a = rawDictionary {
            return DecoderDictionary(items: a)
        }
        else {
            return nil
        }
    }
    
    public var val: AnyObject? {
        return self.value
    }
    
    public var err: NSError? {
        return self.error
    }
    
    public var initialArr: [AnyObject]? {
        return self.rawArray
    }
    
    public var initialDict: [String : AnyObject]? {
        return self.rawDictionary
    }
    
    // MARK: Error
    
    private func indexOutRangeError(index: Int) -> NSError {
        return NSError(domain: "com.optionreader", code: 1, userInfo: [ "message" : "index \(index) of range of array at depth \(self.depth)" ])
    }
    
    private func keysNotPresentError(keys: [String]) -> NSError {
        return NSError(domain: "com.optionreader", code: 1, userInfo: [ "message" : "key(s) '\(keys)' not present in dictionary at depth \(self.depth)" ])
    }
    
    // MARK: Index
    
    public subscript(index: Int) -> Decoder {
        if let e = error {
            return Decoder(error: e)
        }
        else {
            if let a = rawArray {
                if index >= a.count {
                    return Decoder(error: indexOutRangeError(index), depth : depth + 1)
                }
                else {
                    return mapToData(a[index])
                }
            }
            else {
                return Decoder(error: notAnArrayError)
            }
        }
    }
    
    // MARK: Key
    
    public subscript(dotpaths: String...) -> Decoder {
        for dotpath in dotpaths {
            if let decoder = decoderForDotpath(dotpath) {
                return decoder
            }
        }
        return Decoder(error: keysNotPresentError(dotpaths), depth : depth + 1)
    }
    
    private func decoderForDotpath(dotpath:String) -> Decoder? {
        let keys = dotpath.componentsSeparatedByString(".")
        var decoder:Decoder? = self
        for key in keys {
            decoder = decoder?.decoderForKey(key)
        }
        return decoder
    }
    
    private func decoderForKey(key:String) -> Decoder? {
        if let d = rawDictionary {
            if let val: AnyObject = d[key] {
                return mapToData(val)
            }
        }
        return nil
    }
    
    // MARK: Map
    
    func mapToData(val: AnyObject) -> Decoder {
        if let a = val as? [AnyObject] {
            return Decoder(array: a, depth : depth + 1)
        }
        else if let d = val as? [String : AnyObject] {
            return Decoder(dictionary: d, depth : depth + 1)
        }
        else {
            return Decoder(value: val, depth : depth + 1)
        }
    }
    
}

public struct DecoderArray : SequenceType {
    
    let items: [AnyObject]
    
    public func generate() -> GeneratorOf<Decoder> {
        
        var i = -1
        
        return GeneratorOf<Decoder> {
            i++
            if( i < self.items.count) {
                return Decoder(value: self.items[i], parseType: true)
            }
            else {
                return nil
            }
        }
    }
    
    
}

public struct DecoderDictionary : SequenceType {
    
    let items: [String: AnyObject]
    
    public func generate() -> GeneratorOf<(String, Decoder)> {
        
        var i = -1
        let keys = items.keys.array
        
        return GeneratorOf<(String, Decoder)> {
            i++
            if( i < self.items.count) {
                let key = keys[i]
                let value =  Decoder(value: self.items[key]!, parseType: true)
                return (key, value)
            }
            else {
                return nil
            }
        }
    }
    
    
}