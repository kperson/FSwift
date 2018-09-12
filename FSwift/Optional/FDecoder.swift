//
//  Decoder.swift
//  FSwift
//
//  Created by Kelton Person on 1/15/15.
//  Copyright (c) 2015 Kelton. All rights reserved.
//

import Foundation
import Swift

public extension FDecoder {
    
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

public struct FDecoder : ExpressibleByArrayLiteral, ExpressibleByDictionaryLiteral {
    
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
    
    public subscript(index: Int) -> FDecoder {
        if let e = error {
            return FDecoder(error: e)
        }
        else {
            if let a = rawArray {
                if index >= a.count {
                    return FDecoder(error: indexOutRangeError(index), depth : depth + 1)
                }
                else {
                    return mapToData(a[index])
                }
            }
            else {
                return FDecoder(error: notAnArrayError)
            }
        }
    }
    
    public subscript(key: String) -> FDecoder {
        if let d = rawDictionary {
            if let val: Any = d[key] {
                return mapToData(val)
            }
            else {
                return FDecoder(error: keyNotPresentError(key), depth : depth + 1)
            }
        }
        else {
            return FDecoder(error: keyNotPresentError(key), depth : depth + 1)
        }
    }
    
    func mapToData(_ val: Any) -> FDecoder {
        if let a = val as? [Any] {
            return FDecoder(array: a, depth : depth + 1)
        }
        else if let d = val as? [String : Any] {
            return FDecoder(dictionary: d, depth : depth + 1)
        }
        else {
            return FDecoder(value: val, depth : depth + 1)
        }
    }
    
}

public struct DecoderArray : Sequence {
    
    public let items: [Any]
    
    public func makeIterator() -> AnyIterator<FDecoder> {
        return AnyIterator(DecoderArrayGenerator(items: items))
    }
    
}

private class DecoderArrayGenerator : IteratorProtocol {

    typealias Element = FDecoder
    
    fileprivate let items: [Any]
    fileprivate var i = -1
    
    init(items: [Any]) {
        self.items = items
    }
    
    func next() -> Element? {
        i = i + 1
        if i < self.items.count {
            return FDecoder(value: self.items[i], parseType: true)
        }
        else {
            return nil
        }
    }
    
    
}



public struct DecoderDictionary : Sequence {
    
    public let items: [String: Any]
    
    public func makeIterator() -> AnyIterator<(String, FDecoder)> {
        return AnyIterator(DecoderDictionaryGenerator(items: items))
    }
    
}


private class DecoderDictionaryGenerator : IteratorProtocol {
    
    typealias Element = (String, FDecoder)

    
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
            let value =  FDecoder(value: self.items[key]!, parseType: true)
            return (key, value)
        }
        else {
            return nil
        }
    }
    
}







