//
//  Decoder.swift
//  FSwift
//
//  Created by Kelton Person on 1/15/15.
//  Copyright (c) 2015 Kelton. All rights reserved.
//

import Foundation
import Swift

public extension Decoder {
    
    public var string: String? {
        return self.val as? String
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
        return self.val as? Bool
    }
    
    public var errorMessage: String? {
        if let err = self.err as NSError? {
            return err.userInfo["message"] as? String
        }
        return nil
    }
    
}

public struct Decoder : ArrayLiteralConvertible, DictionaryLiteralConvertible {
    
    let notAnArrayError = NSError(domain: "com.optionreader", code: 2, userInfo: [ "message" : "data is not array like" ])
    let notADictionaryError = NSError(domain: "com.optionreader", code: 3, userInfo: [ "message" : "data is not dictionary like" ])
    
    
    private var rawDictionary: [String : AnyObject]?
    private var rawArray: [AnyObject]?
    private var value: AnyObject?
    private var error: NSError?
    let depth: Int
    
    
    public init(arrayLiteral elements: AnyObject...) {
        self.rawArray = elements
        self.depth = 0
    }
    
    public init(dictionary: [String : AnyObject], depth: Int = 0) {
        self.rawDictionary = dictionary
        self.depth = depth
    }
    
    public init(dictionaryLiteral elements: (String, AnyObject)...) {
        var d:[String: AnyObject] = [ : ]
        for (k, v) in elements {
            d[k] = v
        }
        self.rawDictionary = d
        self.depth = 0
    }
    
    public init(array: [AnyObject], depth: Int = 0) {
        self.rawArray = array
        self.depth = depth
    }
    
    private init(value: AnyObject, parseType: Bool = false, depth: Int = 0) {
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
    
    
    private func indexOutRangeError(index: Int) -> NSError {
        return NSError(domain: "com.optionreader", code: 1, userInfo: [ "message" : "index \(index) of range of array at depth \(self.depth)" ])
    }
    
    private func keyNotPresentError(key: String) -> NSError {
        return NSError(domain: "com.optionreader", code: 1, userInfo: [ "message" : "key '\(key)' not present in dictionary at depth \(self.depth)" ])
    }
    
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
    
    public subscript(key: String) -> Decoder {
        if let d = rawDictionary {
            if let val: AnyObject = d[key] {
                return mapToData(val)
            }
            else {
                return Decoder(error: keyNotPresentError(key), depth : depth + 1)
            }
        }
        else {
            return Decoder(error: keyNotPresentError(key), depth : depth + 1)
        }
    }
    
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
    
    public let items: [AnyObject]
    
    public func generate() -> AnyGenerator<Decoder> {
        return DecoderArrayGenerator(items: items)
    }
    
}

private class DecoderArrayGenerator : AnyGenerator<Decoder> {

    private let items: [AnyObject]
    private var i = -1
    
    init(items: [AnyObject]) {
        self.items = items
    }
    
    override func next() -> Element? {
        i++
        if i < self.items.count {
            return Decoder(value: self.items[i], parseType: true)
        }
        else {
            return nil
        }
    }
    
    
}



public struct DecoderDictionary : SequenceType {
    
    public let items: [String: AnyObject]
    
    public func generate() -> AnyGenerator<(String, Decoder)> {
        return DecoderDictionaryGenerator(items: items)
    }
    
}


private class DecoderDictionaryGenerator : AnyGenerator<(String, Decoder)> {
    
    
    private let items: [String: AnyObject]
    private let keys: [String]
    private var i = -1
    
    init(items: [String : AnyObject]) {
        self.items = items
        self.keys = Array(items.keys)
    }
    
    override func next() -> Element? {
        i++
        if i < self.items.count {
            let key = keys[i]
            let value =  Decoder(value: self.items[key]!, parseType: true)
            return (key, value)
        }
        else {
            return nil
        }
    }
    
    
}

