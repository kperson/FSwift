//
//  ViewController.swift
//  FSwiftDemo
//
//  Created by Maxime Ollivier on 1/28/15.
//  Copyright (c) 2015 FSwift. All rights reserved.
//

import UIKit
import FSwift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Service.setRoot("...")
        Service.setAuthenticationHeader(["Some header":"Some key"])
        
        Service.get(Item.self, id: "1234").onSuccess { item in
            println(item)
        }
        
    }

}

class Item:Restful {
    
    var id:String?
    var name:String?
    
    required init?(decoder:Decoder) {
        self.name = decoder["name"].string
        self.id = decoder["id"].string
    }
    
    class func getPath() -> String {
        return "/items"
    }
    
}

