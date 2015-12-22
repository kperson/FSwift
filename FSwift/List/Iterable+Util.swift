//
//  Iterable+Util.swift
//  FSwift
//
//  Created by Kelton Person on 10/6/14.
//  Copyright (c) 2014 Kelton. All rights reserved.
//

import Foundation

public extension SequenceType where Generator.Element : Equatable {
    
    
    public var unique:[Generator.Element]  {
        return Seq.removeDuplicates(self)
    }
    
}


public extension SequenceType {
    
    
    public var toArray:[Generator.Element] {
        return Array(self)
    }
    
    public func foreach(f: (Generator.Element) -> Void) {
        Seq.foreach(self, f)
    }
    
    public func foreachWithIndex( f: (Generator.Element, Int) -> Void) {
        Seq.foreachWithIndex(self, f)
    }
    
    
    public func firstIndexOf( f: (Generator.Element) -> Bool) -> Int? {
        return Seq.firstIndexOf(self, f)
    }
    
    public func lastIndexOf( f: (Generator.Element) -> Bool) -> Int? {
        return Seq.lastIndexOf(self, f)
    }
    
    public var tail: AnySequence<Generator.Element> {
        return Seq.tail(self)
    }
    
    
    public func take(amount: Int) -> AnySequence<Generator.Element>  {
        return Seq.take(self, amount)
    }
    
    public func skip(amount: Int) -> AnySequence<Generator.Element> {
        return Seq.skip(self, amount)
    }
    
    public func lazyFlatMap<B>(f:(Generator.Element) -> B?) -> AnySequence<B> {
        let b = FlatMapGenerator<Generator.Element, B>(f: f)
        b.setup(self)
        let a = GeneratorSequence<FlatMapGenerator<Generator.Element, B>>(b)
        let q = AnySequence<B>(a)
        return q
    }
    
    public func lazyFilter(f:(Generator.Element) -> Bool) -> AnySequence<Generator.Element> {
        return Seq.lazyFilter(self, f)
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
    public func mapReduce<B:Hashable, C>(m: (Generator.Element) -> B, _ r: (B, [Generator.Element]) -> C) -> [C]  {
        return Seq.mapReduce(self, m, r)
    }
    
    public func shuffled() -> [Generator.Element] {
        return self.sort { a, b in arc4random() < arc4random() }
    }
    
    
    public func reduceLeft(f: (Generator.Element, Generator.Element) -> Generator.Element) -> Generator.Element {
        return Seq.reduceRight(Array(self.reverse()), f)
    }
    
    
    public func reduceRight(f: (Generator.Element, Generator.Element) -> Generator.Element) -> Generator.Element {
        return Seq.reduceRight(self, f)
    }
    
    
    public func foldLeft<B>(initialValue: B, _ f: (B, Generator.Element) -> B) -> B {
        return Array(self.reverse()).foldRight(initialValue, f)
    }
    
    
    public func foldRight<B>(initialValue: B, _ f: (B, Generator.Element) -> B) -> B {
        return Seq.foldRight(self, initialValue, f)
    }
    
    
    public func findFirst(f: (Generator.Element) -> Bool) -> Generator.Element? {
        return Seq.findFirst(self, f)
    }
    
}