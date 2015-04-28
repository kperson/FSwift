//
//  ViewController.swift
//  FSwift-Sample-iOS7
//
//  Created by Kelton Person on 4/28/15.
//  Copyright (c) 2015 Kelton Person. All rights reserved.
//

import UIKit
import FSwift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        println(300.milliseconds)
        
        future {
            Try.Success("hello")
        }.onSuccess { word in
            println(word)
            
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

