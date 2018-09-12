//
//  Iterable+Util.swift
//  FSwift
//
//  Created by Kelton Person on 10/6/14.
//  Copyright (c) 2014 Kelton. All rights reserved.
//

import Foundation

extension Sequence where Iterator.Element : Equatable {
    
    
    public var unique:[Iterator.Element]  {
        return Seq.removeDuplicates(self)
    }
    
}


public extension Sequence {
    
    
    public func foreach(_ f: (Iterator.Element) -> Void) {
        Seq.foreach(self, f)
    }
    
    public func foreachWithIndex( _ f: (Iterator.Element, Int) -> Void) {
        Seq.foreachWithIndex(self, f)
    }
    
    
    public func firstIndexOf( _ f: (Iterator.Element) -> Bool) -> Int? {
        return Seq.firstIndexOf(self, f)
    }
    
    public func lastIndexOf( _ f: (Iterator.Element) -> Bool) -> Int? {
        return Seq.lastIndexOf(self, f)
    }
    
    public var tail: [Iterator.Element]  {
        return Seq.tail(self)
    }
    
    
    public func take(_ amount: Int) -> [Iterator.Element] {
        return Seq.take(self, amount)
    }
    
    public func skip(_ amount: Int) -> [Iterator.Element] {
        return Seq.skip(self, amount)
    }
    
    public func flatten() -> [Iterator.Element]  {
        return self.compactMap { x in x }
    }
    
    /**
    * :param m A mapping a function
    * :param r a reduce function
    *
    * The mapping function is required to take a T (the type of object in the Array) a map it a value of type B (i.e. the key)
    * The reduction function takes the key(type B) and a list of Ts and reduces to a single C
    * See test case in ListExtensionsTests.swift for an example
    * See http://en.wikipedia.org/wiki/MapReduce for more explanation of map reduce
    *
    * :returns a list of C
    *
    */
    public func mapReduce<B:Hashable, C>(_ m: (Iterator.Element) -> B, _ r: (B, [Iterator.Element]) -> C) -> [C]  {
        return Seq.mapReduce(self, m, r)
    }
    
    public func shuffledArr() -> [Iterator.Element] {
        return self.sorted { a, b in arc4random() < arc4random() }
    }
    
    
}

public extension Collection {
    
    public func findFirst(_ f: (Iterator.Element) -> Bool) -> Iterator.Element? {
        return Seq.findFirst(self, f)
    }
    
    public func reduceLeft(_ f: (Iterator.Element, Iterator.Element) -> Iterator.Element) -> Iterator.Element {
        return Array(self.reversed()).reduceRight(f)
    }
    
    
    public func reduceRight(_ f: (Iterator.Element, Iterator.Element) -> Iterator.Element) -> Iterator.Element {
        if self.count == 1 {
            return self.first!
        }
        else {
            return f(self.first!, self.tail.reduceRight(f))
        }
    }
    
    public func foldLeft<B>(_ initialValue: B, _ f: (B, Iterator.Element) -> B) -> B {
        return Array(self.reversed()).foldRight(initialValue, f)
    }
    
    public func foldRight<B>(_ initialValue: B, _ f: (B, Iterator.Element) -> B) -> B {
        return Seq.foldRight(self, initialValue, f)
    }
    
}
