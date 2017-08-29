//
//  UIControlExtension.swift
//  FSwift
//
//  Created by Kelton Person on 10/24/14.
//  Copyright (c) 2014 Kelton. All rights reserved.
//

import Foundation
import UIKit

open class ControlAction: NSObject {
    
    let f: (UIControl) -> ()
    let contol: UIControl
    let controlEvents: UIControlEvents
    
    public init(f: @escaping (UIControl) -> (), control: UIControl, controlEvents: UIControlEvents) {
        self.f = f
        self.contol = control
        self.controlEvents = controlEvents
        super.init()
        self.contol.addTarget(self, action: #selector(ControlAction.selectionAction), for: self.controlEvents)
    }
    
    @objc func selectionAction(){
        self.f(self.contol)
    }
    
    open func removeAction() {
        self.contol.removeTarget(self, action: #selector(ControlAction.selectionAction), for: self.controlEvents)
    }
    
}

extension UIControl {
    
    func addTargetAction(_ controlEvents: UIControlEvents,  _ f: @escaping (UIControl) -> ()) -> ControlAction {
        return ControlAction(f: f, control: self, controlEvents: controlEvents)
    }
    
}
