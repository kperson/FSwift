//
//  Date.swift
//  FSwift
//
//  Created by Maxime Ollivier on 1/27/15.
//  Copyright (c) 2015 Kelton. All rights reserved.
//

import Foundation

enum DatePrintComponent {
    case FullYear
    case MonthNumber
    case Day
    case Hour24
    case Seconds
}

extension NSDate {
    func stringWithFormat(format:String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.stringFromDate(self)
    }
    
    func printWithComponent(component:DatePrintComponent) -> String {
        switch component {
        case .FullYear:
            return self.stringWithFormat("yyyy")
        case .MonthNumber:
            return self.stringWithFormat("MM")
        case .Day:
            return self.stringWithFormat("dd")
        case .Hour24:
            return self.stringWithFormat("HH")
        case .Seconds:
            return self.stringWithFormat("mm")
        }
    }
    
    subscript(component: DatePrintComponent) -> String {
        return printWithComponent(component)
    }
}