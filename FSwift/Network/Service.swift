//
//  Service.swift
//  FSwift
//
//  Created by Maxime Ollivier on 1/28/15.
//  Copyright (c) 2015 Kelton. All rights reserved.
//

import Foundation

public protocol Restful {
    init?(decoder:Decoder)
    class func getPath() -> String
}

public protocol Authentication {
    func headerForPath(path:String) -> Dictionary<String,AnyObject>
}

private var _root = ""
private var _authentication:Authentication?

public class Service: ServiceUtil {
    
    // MARK: Global set up
    
    public class var root:String {
        get {
            return _root
        }
        set(value) {
            _root = value
        }
    }
    
    public class var authentication:Authentication? {
        get {
           return _authentication
        }
        set(value) {
            _authentication = value
        }
    }
    
    // MARK: Authentication
    
    // MARK: Get an object
    
    public class func get<T:Restful>(type:T.Type, id:String) -> Future<T> {
        let url = root + T.getPath() + "/" + id
        return getObject(url, type:type)
    }
    
    // MARK: Get Object
    
    public class func getObject<T:Restful>(url:String, type:T.Type) -> Future<T> {
        let header = authentication?.headerForPath(url) ?? [:]
        
        return getDecoder(url, headers: header).map {decoder -> (Try<T>) in
            if let object = T(decoder: decoder) {
                return Try.Success(object)
            } else {
                return Try.Failure(NSError(domain: "com.service", code: 0, userInfo: ["message":"Could not create object"]))
            }
        }
    }
    
    // MARK: Get Decoder
    
    public class func getDecoder(url:String, var headers: Dictionary<String, AnyObject> = [:]) -> Future<JSONDecoder> {
        headers["Accept"] = "application/json"
        return getData(url, headers: headers).map {data -> (Try<JSONDecoder>) in
            return JSONDecoder.decoderWithJsonData(data)
        }
    }
    
    // MARK: Get data
    
    public class func getData(url:String, headers: Dictionary<String, AnyObject> = [:]) -> Future<NSData> {
        return get(url, headers: headers).map {response in
            if let error = self.isResponseCodeValid(response) {
                return Try.Failure(error)
            } else {
                return Try.Success(response.body)
            }
        }
    }
    
    // MARK: Response status code check
    
    private class func isResponseCodeValid(response:RequestResponse) -> NSError? {
        switch response.statusCode {
        case 0...399:
            return nil
        case 403:
            return NSError(domain: "com.service", code: 1, userInfo: ["message":"Forbidden"])
        default:
            return NSError(domain: "com.service", code: 0, userInfo: ["message":"Status code \(response.statusCode)", "details":response.bodyAsText])
        }
    }
    
}