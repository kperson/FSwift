//
//  Service.swift
//  FSwift
//
//  Created by Maxime Ollivier on 1/28/15.
//  Copyright (c) 2015 Kelton. All rights reserved.
//

import Foundation

public protocol Codable {
    init?(decoder:Decoder)
}

public protocol GETable:Codable {
    class func getPathWithId(id:String) -> String
}

public protocol POSTable {
    class func postPath() -> String
    func postCoder() -> Coder
}

public struct Successful {
    public init() {
        
    }
}

private var _root = ""

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
    
    // MARK: GET
    
    public class func getObjectWithId<T:GETable>(id:String, type:T.Type, var headers: Dictionary<String, AnyObject> = [:]) -> Future<T> {
        let url = root + T.getPathWithId(id)
        return requestObject(type, url: url, requestMethod: RequestMethod.GET, coder:nil , headers: headers)
    }
    
    // MARK: POST
    
    public class func postObject<T:POSTable>(object:T, var headers: Dictionary<String, AnyObject> = [:]) -> Future<Successful> {
        let url = root + T.postPath()
        return requestDecoder(url, requestMethod: RequestMethod.POST, coder: object.postCoder(), headers: headers).map {decoder -> (Try<Successful>) in
            return Try.Success(Successful())
        }
    }
    
    // MARK: Objects
    
    public class func requestObject<T:Codable>(type:T.Type, url:String, requestMethod: RequestMethod, coder: Coder?, var headers: Dictionary<String, AnyObject>) -> Future<T> {
        return requestDecoder(url, requestMethod: requestMethod, coder: coder, headers: headers).map {decoder -> (Try<T>) in
            if let object = T(decoder: decoder) {
                return Try.Success(object)
            } else {
                return Try.Failure(NSError(domain: "com.service", code: 0, userInfo: ["message":"Could not create object"]))
            }
        }
    }
    
    // MARK: JSON Decoder
    
    public class func requestDecoder(url:String, requestMethod: RequestMethod, coder: Coder?, var headers: Dictionary<String, AnyObject>) -> Future<Decoder> {
        headers["Accept"] = "application/json"
        headers["Content-Type"] = "application/json"
        return requestData(url, requestMethod: requestMethod, body: coder?.jsonData ?? emptyBody, headers: headers).map {data -> (Try<Decoder>) in
            return Decoder.decoderWithJsonData(data)
        }
    }
    
    // MARK: Data
    
    public class func requestData(url:String, requestMethod: RequestMethod, body: NSData, headers: Dictionary<String, AnyObject>) -> Future<NSData> {
        return request(url, requestMethod: requestMethod, body: body, headers: headers).map {response in
            if response.isSuccessful {
                return Try.Success(response.body)
            } else {
                return Try.Failure(NSError(response: response))
            }
        }
    }
    
    
}

extension NSError {
    
    convenience init(response:RequestResponse) {
        self.init(domain: "com.service", code: 0, userInfo: ["message":"Response status \(response.statusCode)","requestResponce":response])
    }
    
    var requestResponse:RequestResponse? {
        return userInfo?["requestResponce"] as? RequestResponse
    }
    
}




