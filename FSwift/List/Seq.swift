//
//  Seq.swift
//  FSwift
//
//  Created by Kelton Person on 4/14/15.
//  Copyright (c) 2015 Kelton. All rights reserved.
//

import Foundation

public class Seq {
    
    /**
    Iterates through a sequence
    
    e.x.
    list = [1, 2, 3]
    Seq.foreach(list) { i in println(i * 2) }
    
    - parameter seq: - a seq to iteratee through
    - parameter f: - function to execute for each item in the sequence
    */
    public class func foreach<T : SequenceType>(seq: T, _ f: (T.Generator.Element) -> Void) {
        for x in seq {
            f(x)
        }
    }
    
    /**
    Iterates through a sequence providing an index as it goes
    
    e.x.
    list = [1, 2, 3]
    Seq.foreach(list) { (num, index) in println(num * index) }
    
    - parameter seq: - a seq to iteratee through
    - parameter f: - a function to execute for each item in the sequence
    */
    public class func foreachWithIndex<T : SequenceType>(seq: T, _ f: (T.Generator.Element, Int) -> Void) {
        var i = 0
        for x in seq {
            f(x, i)
            i += 1
        }
    }
    
    /**
    Finds the first index fulfilling the search criteria
    
    e.x.
    list = [1, 2, 3]
    Seq.firstIndexOf(list) { x in x == 2 } //returns 1
    
    - parameter seq: - a sequence to search
    - parameter f: - search criteria
    
    - returns: the index of fullfilling the criteria, nil if not found
    */
    public class func firstIndexOf<T : SequenceType>(seq: T, _ f: (T.Generator.Element) -> Bool) -> Int? {
        var i = 0
        for x in seq {
            if f(x)  {
                return i
            }
            i++
        }
        return nil;
    }
    
    /**
    Finds the last index fulfilling the search criteria
    
    e.x.
    list = [1, 2, 3, 2]
    Seq.firstIndexOf(list) { x in x == 2 } //returns 3
    
    - parameter seq: - a sequence to search
    - parameter f: - search criteria
    
    - returns: the index of fullfilling the criteria, nil if not found
    */
    public class func lastIndexOf<T : SequenceType>(seq: T, _ f: (T.Generator.Element) -> Bool) -> Int? {
        var i = 0
        var final: Int?
        for x in seq {
            if f(x)  {
                final = i
            }
            i++
        }
        return final
    }
    
    
    /**
    Generates the tail of a list (i.e. every item except the first), if the list has no tail, an empty array is returned
    
    e.x.
    Seq.tail([1, 2, 3]) //returns [2, 3]
    
    - parameter seq: - a sequence
    
    - returns: a new array representing the tail of the sequence
    */
    public class func tail<T : SequenceType>(seq: T) -> AnySequence<T.Generator.Element>  {
        let b = TailGenerator<T.Generator.Element>()
        b.setup(seq)
        return AnySequence<T.Generator.Element>(GeneratorSequence<TailGenerator<T.Generator.Element>>(b))
    }
    
    public class func headTail<T : SequenceType>(seq: T) -> (T.Generator.Element?, AnySequence<T.Generator.Element>)  {
        let b = HeadTailGenerator<T.Generator.Element>()
        b.setup(seq)
        return (b.head, AnySequence<T.Generator.Element>(GeneratorSequence<HeadTailGenerator<T.Generator.Element>>(b)))
    }
    
    
    public class func foldRight<T : SequenceType, B>(seq: T, _ initialValue: B, _ f: (B, T.Generator.Element) -> B) -> B {
        let (head, tail) = headTail(seq)
        if let h = head {
            return f(Seq.foldRight(tail, initialValue, f), h)
        }
        else {
            return initialValue
        }
    }
    
    public class func lazyFlatMap<T : SequenceType, B>(seq: T, _ f: (T.Generator.Element) -> B?) -> AnySequence<B> {
        let b = FlatMapGenerator<T.Generator.Element, B>(f: f)
        b.setup(seq)
        let a = GeneratorSequence<FlatMapGenerator<T.Generator.Element, B>>(b)

        let q = AnySequence<B>(a)
        return q
    }
    
    
    public class func reduceRight<T : SequenceType>(seq: T, _ f: (T.Generator.Element, T.Generator.Element) -> T.Generator.Element) -> T.Generator.Element {
        let (head, tail) = headTail(seq)
        if let h = head {
            return Seq.foldRight(tail, h, f)
        }
        else {
            fatalError("can call reduce on an empty sequence")
        }
    }
    
    public class func findFirst<T : SequenceType>(seq: T, _ f: (T.Generator.Element) -> Bool) -> T.Generator.Element? {
        let (head, tail) = headTail(seq)
        switch head {
        case .Some(let h) where f(h) == true: return h
        case .None: return nil
        default: return Seq.findFirst(tail, f)
        }
    }
    
    
    /**
    Removes duplicates from sequence
    
    - parameter seq: - a sequence to evaluate
    
    - returns: a new array with duplicates removed
    */
    public class func removeDuplicates<S : SequenceType where S.Generator.Element : Equatable>(seq: S) -> [S.Generator.Element] {
        var uniqueList:[S.Generator.Element] = []
        for x in seq {
            if !uniqueList.contains(x) {
                uniqueList.append(x)
            }
        }
        return uniqueList
    }
    
    /**
    Skips the first n elements of a sequence
    
    e.x.
    Seq.skip([1, 2, 3], 2) //returns [3]
    
    - parameter seq: - a sequence to evaluate
    - parameter amount: the number of elements to skip
    
    - returns: a new array with skip elements
    */
    public class func skip<T : SequenceType>(seq: T, _ amount: Int) -> AnySequence<T.Generator.Element> {
        let generator = SkipGenerator<T.Generator.Element>(skip: amount)
        generator.setup(seq)
        return AnySequence<T.Generator.Element>(GeneratorSequence<SkipGenerator<T.Generator.Element>>(generator))
    }
    
    public class func lazyFilter<T : SequenceType>(seq: T, _ f: (T.Generator.Element) -> Bool) -> AnySequence<T.Generator.Element> {
        let generator = LazyFilterGenerator<T.Generator.Element>(f: f)
        generator.setup(seq)
        return AnySequence<T.Generator.Element>(GeneratorSequence<LazyFilterGenerator<T.Generator.Element>>(generator))
    }
    
    
    
    /**
    Takes the first n elements of a sequence
    
    e.x.
    Seq.take([1, 2, 3], 2) //returns [1, 2]
    
    - parameter seq: - a sequence to evaluate
    - parameter amount: the number of elements to take
    
    - returns: a new array with taken elements
    */
    public class func take<T : SequenceType>(seq: T, _ amount: Int) -> AnySequence<T.Generator.Element> {
        let generator = TakeGenerator<T.Generator.Element>(take: amount)
        generator.setup(seq)
        return AnySequence<T.Generator.Element>(GeneratorSequence<TakeGenerator<T.Generator.Element>>(generator))
    }
    
    
    public class func mapReduce<T : SequenceType, B:Hashable, C>(seq: T, _ m: (T.Generator.Element) -> B, _ r: (B, [T.Generator.Element]) -> C) -> [C]  {
        var dict:Dictionary<B, [T.Generator.Element]> = [:]
        for x in seq {
            let key = m(x)
            if var l = dict[key] {
                l.append(x)
                dict[key] = l
            }
            else {
                dict[key] = [x]
            }
        }
        var rs:[C] = []
        for (k, v) in dict {
            rs.append(r(k, v))
        }
        return rs
    }
    
}


public class HeadTailGenerator<T> : GeneratorType {
    
    public typealias Element = T
    
    private var fetchNext: () -> Element? = { _ in nil }
    internal var head: T?
    
    
    func setup<B: SequenceType where B.Generator.Element == Element>(b: B) {
        var generator = b.generate()
        head = generator.next()
        fetchNext = {
            generator.next()
        }
    }
    
    
    public func next() -> Element? {
        return fetchNext()
    }
    
}



public class TakeGenerator<T> : GeneratorType {
    
    public typealias Element = T
    
    private var fetchNext: () -> Element? = { _ in nil }
    
    let take: Int
    var takeCount = 0
    
    init(take: Int) {
        self.take = take
    }
    
    func setup<B: SequenceType where B.Generator.Element == Element>(b: B) {
        var generator = b.generate()
        fetchNext = {
            generator.next()
        }
    }
    
    
    public func next() -> Element? {
        if takeCount < take {
            takeCount = takeCount + 1
            return fetchNext()
        }
        else {
            return nil
        }
    }
    
}


public class SkipGenerator<T> : GeneratorType {
    
    public typealias Element = T
    
    private var fetchNext: () -> Element? = { _ in nil }
    
    let skip: Int
    
    init(skip: Int) {
        self.skip = skip
    }
    
    func setup<B: SequenceType where B.Generator.Element == Element>(b: B) {
        var generator = b.generate()
        var i = 0
        while i < self.skip && generator.next() != nil {
            i++
        }
        fetchNext = {
            generator.next()
        }
    }
    
    
    public func next() -> Element? {
        return fetchNext()
    }
    
}



public class TailGenerator<T> : GeneratorType {

    public typealias Element = T

    private var fetchNext: () -> Element? = { _ in nil }
    private var hasStarted = false
    
    
    func setup<B: SequenceType where B.Generator.Element == Element>(b: B) {
        var generator = b.generate()
        fetchNext = {
            generator.next()
        }
    }
    
    
    public func next() -> Element? {
        if !hasStarted {
            hasStarted = true
            if let _ = fetchNext() {
                return fetchNext()
            }
            else {
                return nil
            }
        }
        else {
            return fetchNext()
        }
    }
    
}


public class LazyFilterGenerator<T> : GeneratorType {
    
    public typealias Element = T
    
    private var fetchNext: () -> T? = { _ in nil }
    
    
    let f: (T) -> Bool
    
    init(f: (T) -> Bool) {
        self.f = f
    }
    
    
    func setup<B: SequenceType where B.Generator.Element == Element>(b: B) {
        var generator = b.generate()
        fetchNext = {
            generator.next()
        }
    }
    
    
    public func next() -> Element? {
        let n = fetchNext()
        if let x = n {
            if f(x) {
                return x
            }
            else {
                return next()
            }
        }
        else {
            return nil
        }
    }
    
}



public class FlatMapGenerator<T, B> : GeneratorType {
    
    public typealias Element = B
    
    private var fetchNext: () -> T? = { _ in nil }

    
    let f: (T) -> B?
    
    init(f: (T) -> B?) {
        self.f = f
    }
    

    func setup<B: SequenceType where B.Generator.Element == T>(b: B) {
        var generator = b.generate()
        fetchNext = {
            generator.next()
        }
    }
    
    
    public func next() -> Element? {
        let n = fetchNext()
        if let x = n {
            if let s = f(x) {
                return s
            }
            else {
                return next()
            }
        }
        else {
            return nil
        }
    }
    
}


