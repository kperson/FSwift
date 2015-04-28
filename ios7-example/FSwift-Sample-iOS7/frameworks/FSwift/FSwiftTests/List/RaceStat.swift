//
//  RaceStats.swift
//  FSwift
//
//  Created by Kelton Person on 10/9/14.
//  Copyright (c) 2014 Kelton. All rights reserved.
//

import Foundation

struct RaceStat:Equatable {
    
    let timeSlot: Int
    let numInSlot: Int
    
}

func ==(lhs: RaceStat, rhs: RaceStat) -> Bool {
    return lhs.numInSlot == rhs.numInSlot && lhs.timeSlot == rhs.timeSlot
}