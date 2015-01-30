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

private var root = ""
private var authenticationHeader:(@autoclosure() -> (Dictionary<String, AnyObject>)) = [:]

public class Service: ServiceUtil {
    
    // MARK: Global set up
    
    public class func setRoot(newRoot:String) {
        root = newRoot
    }
    
    public class func setAuthenticationHeader(newAuthenticationHeader:(@autoclosure() -> (Dictionary<String, AnyObject>))) {
       authenticationHeader = newAuthenticationHeader
    }
    
    // MARK: Get an object
    
    public class func get<T:Restful>(type:T.Type, id:String) -> Future<T> {
        let url = root + T.getPath() + "/" + id
        return getObject(url, type:type)
    }
    
    // MARK: Get Object
    
    public class func getObject<T:Restful>(url:String, type:T.Type) -> Future<T> {
        return getDecoder(url, headers: authenticationHeader()).map {decoder -> (Try<T>) in
            if let object = T(decoder: decoder) {
                return Try.Success(object)
            } else {
                return Try.Failure(NSError(domain: "com.service", code: 0, userInfo: ["message":"Could not create object"]))
            }
        }
    }
    
    
    // MARK: Get Decoder
    
    private class func getDecoder(url:String, headers: Dictionary<String, AnyObject> = [:]) -> Future<JSONDecoder> {
        return getData(url, headers: authenticationHeader()).map {data -> (Try<JSONDecoder>) in
            return JSONDecoder.decoderWithJsonData(data)
        }
    }
    
    // MARK: Get data
    
    private class func getData(url:String, headers: Dictionary<String, AnyObject> = [:]) -> Future<NSData> {
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
        return nil //TODO: create error if invalid code
    }
    
}