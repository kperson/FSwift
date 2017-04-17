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
        if let _val = self.val {
            return _val as? String
        }
        return nil
    }
    
    public var int: Int? {
        if let _val = self.val {
            return _val as? Int
        }
        return nil
    }
    
    public var double: Double? {
        if let _val = self.val {
            return _val as? Double
        }
        return nil
    }
    
    public var float: Float? {
        if let _val = self.val {
            return _val as? Float
        }
        return nil
    }
    
    public var bool: Bool? {
        if let _val = self.val {
            return _val as? Bool
        }
        return nil
    }
    
    public var errorMessage: String? {
        if let err = self.err as NSError? {
            return err.userInfo["message"] as? String
        }
        return nil
    }
    
}

public struct Decoder : ExpressibleByArrayLiteral, ExpressibleByDictionaryLiteral {
    
    let notAnArrayError = NSError(domain: "com.optionreader", code: 2, userInfo: [ "message" : "data is not array like" ])
    let notADictionaryError = NSError(domain: "com.optionreader", code: 3, userInfo: [ "message" : "data is not dictionary like" ])
    
    
    fileprivate var rawDictionary: [String : Any]?
    fileprivate var rawArray: [Any]?
    fileprivate var value: Any?
    fileprivate var error: NSError?
    let depth: Int
    
    
    public init(arrayLiteral elements: Any...) {
        self.rawArray = elements
        self.depth = 0
    }
    
    public init(dictionary: [String : Any], depth: Int = 0) {
        self.rawDictionary = dictionary
        self.depth = depth
    }
    
    public init(dictionaryLiteral elements: (String, Any)...) {
        var d:[String: Any] = [ : ]
        for (k, v) in elements {
            d[k] = v
        }
        self.rawDictionary = d
        self.depth = 0
    }
    
    public init(array: [Any], depth: Int = 0) {
        self.rawArray = array
        self.depth = depth
    }
    
    fileprivate init(value: Any, parseType: Bool = false, depth: Int = 0) {
        self.depth = depth
        if !parseType {
            self.value = value
        }
        else {
            if let a = value as? [Any] {
                self.rawArray = a
            }
            else if let d = value as? [String : Any] {
                self.rawDictionary = d
            }
            else {
                self.value = value
            }
        }
    }
    
    fileprivate init(error: NSError, depth: Int = 0) {
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
    
    public var val: Any? {
        return self.value
    }
    
    public var err: NSError? {
        return self.error
    }
    
    
    fileprivate func indexOutRangeError(_ index: Int) -> NSError {
        return NSError(domain: "com.optionreader", code: 1, userInfo: [ "message" : "index \(index) of range of array at depth \(self.depth)" ])
    }
    
    fileprivate func keyNotPresentError(_ key: String) -> NSError {
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
            if let val: Any = d[key] {
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
    
    func mapToData(_ val: Any) -> Decoder {
        if let a = val as? [Any] {
            return Decoder(array: a, depth : depth + 1)
        }
        else if let d = val as? [String : Any] {
            return Decoder(dictionary: d, depth : depth + 1)
        }
        else {
            return Decoder(value: val, depth : depth + 1)
        }
    }
    
}

public struct DecoderArray : Sequence {
    
    public let items: [Any]
    
    public func makeIterator() -> AnyIterator<Decoder> {
        return AnyIterator(DecoderArrayGenerator(items: items))
    }
    
}

private class DecoderArrayGenerator : IteratorProtocol {

    typealias Element = Decoder
    
    fileprivate let items: [Any]
    fileprivate var i = -1
    
    init(items: [Any]) {
        self.items = items
    }
    
    func next() -> Element? {
        i = i + 1
        if i < self.items.count {
            return Decoder(value: self.items[i], parseType: true)
        }
        else {
            return nil
        }
    }
    
    
}



public struct DecoderDictionary : Sequence {
    
    public let items: [String: Any]
    
    public func makeIterator() -> AnyIterator<(String, Decoder)> {
        return AnyIterator(DecoderDictionaryGenerator(items: items))
    }
    
}


private class DecoderDictionaryGenerator : IteratorProtocol {
    
    typealias Element = (String, Decoder)

    
    fileprivate let items: [String: Any]
    fileprivate let keys: [String]
    fileprivate var i = -1
    
    init(items: [String : Any]) {
        self.items = items
        self.keys = Array(items.keys)
    }
    
    func next() -> Element? {
        i = i + 1
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

