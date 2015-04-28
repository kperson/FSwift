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
    
    :param: seq - a seq to iteratee through
    :param: f - function to execute for each item in the sequence
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
    
    :param: seq - a seq to iteratee through
    :param: f - a function to execute for each item in the sequence
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
    
    :param: seq - a sequence to search
    :param: f - search criteria
    
    :returns: the index of fullfilling the criteria, nil if not found
    */
    public class func firstIndexOf<T : SequenceType>(seq: T, _ f: (T.Generator.Element) -> Bool) -> Int? {
        var i = 0
        var final: Int?
        for x in seq {
            if f(x)  {
                return i
            }
            i++
        }
        return final
    }
    
    /**
    Finds the last index fulfilling the search criteria
    
    e.x.
    list = [1, 2, 3, 2]
    Seq.firstIndexOf(list) { x in x == 2 } //returns 3
    
    :param: seq - a sequence to search
    :param: f - search criteria
    
    :returns: the index of fullfilling the criteria, nil if not found
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
    Transforms a sequence into a list, any item the transforms to a nil will not be inserted
    
    e.x.
    Seq.flatMap([1, 2, 3, 4]) { x % 2 == 0 ? x : nil } //returns [2, 4]
    
    :param: seq - a sequence to flatMap
    :param: f  - a transformation function
    
    :returns: a new array with all non-nil items
    */
    public class func flatMap<T : SequenceType, S>(seq: T, _ f: T.Generator.Element -> S?) -> [S] {
        var list = [S]()
        for x in seq {
            if let val = f(x) {
                list.append(val)
            }
        }
        return list
    }
    
    /**
    Generates the tail of a list (i.e. every item except the first), if the list has no tail, an empty array is returned
    
    e.x. 
    Seq.tail([1, 2, 3]) //returns [2, 3]
    
    :param: seq - a sequence
    
    :returns: a new array representing the tail of the sequence
    */
    public class func tail<T : SequenceType>(seq: T) -> [T.Generator.Element] {
        var list:[T.Generator.Element] = []
        var i = 0
        for x in seq {
            if i != 0 {
                list.append(x)
            }
            i++
        }
        return list
    }
    
    
    public class func foldRight<T : CollectionType, B>(seq: T, _ initialValue: B, _ f: (B, T.Generator.Element) -> B) -> B {
        let x = []
        if count(seq) == 0 {
            return initialValue
        }
        else {
            let t = Seq.tail(seq)
            return f(t.foldRight(initialValue, f), first(seq)!)
        }
    }
    
    public class func findFirst<T : CollectionType>(seq: T, _ f: (T.Generator.Element) -> Bool) -> T.Generator.Element? {
        if count(seq) == 0 {
            return nil
        }
        if f(first(seq)!)  {
            return first(seq)!
        }
        else {
            return Seq.findFirst(Seq.tail(seq), f)
        }
    }
    
    
    /**
    Removes duplicates from sequence
    
    :param: seq - a sequence to evaluate
    
    :returns: a new array with duplicates removed
    */
    public class func removeDuplicates<S : SequenceType where S.Generator.Element : Equatable>(seq: S) -> [S.Generator.Element] {
        var uniqueList:[S.Generator.Element] = []
        for x in seq {
            if !contains(uniqueList, x) {
                uniqueList.append(x)
            }
        }
        return uniqueList
    }
    
    /**
    Skips the first n elements of a sequence
    
    e.x.
    Seq.skip([1, 2, 3], 2) //returns [3]
    
    :param: seq - a sequence to evaluate
    :param: amount the number of elements to skip
    
    :returns: a new array with skip elements
    */
    public class func skip<T : SequenceType>(seq: T, _ amount: Int) -> [T.Generator.Element] {
        var i = 0
        var list:[T.Generator.Element] = []
        for x in seq {
            if i >= amount {
                list.append(x)
            }
            i++
        }
        return list
    }
    
    
    
    /**
    Takes the first n elements of a sequence
    
    e.x.
    Seq.take([1, 2, 3], 2) //returns [1, 2]
    
    :param: seq - a sequence to evaluate
    :param: amount the number of elements to take
    
    :returns: a new array with taken elements
    */
    public class func take<T : SequenceType>(seq: T, _ amount: Int) -> [T.Generator.Element] {
        var i = 0
        var list:[T.Generator.Element] = []
        for x in seq {
            if i < amount {
                list.append(x)
            }
            i++
        }
        return list
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
