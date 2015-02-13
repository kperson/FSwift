//
//  Service.swift
//  FSwift
//
//  Created by Maxime Ollivier on 1/28/15.
//  Copyright (c) 2015 Kelton. All rights reserved.
//

import Foundation

public protocol Decodable {
    init?(decoder:Decoder)
}

public protocol RESTfull {
    class var resourceName:String {get}
    class var resourceNamePlural:String {get}
    var id:String {get}
}

public protocol GETable:RESTfull, Decodable {
    
}

public protocol POSTable: GETable{
    func postCoder(coder:Coder) -> Coder
}

public protocol UPDATEable: GETable {
    func updateCoder(coder:Coder) -> Coder
}

public protocol DELETEable: RESTfull {

}

public let POSTableObjectId = ""

public struct Pointer<T:GETable>: Decodable, Printable {
    public var id:String
    
    public init?(decoder:Decoder) {
        if let string = decoder.string {
            self.id = string
        } else {
            self.id = ""
            return nil
        }
    }
    
    public var description:String {
        return "\(id)"
    }
}

public typealias Successful = Void

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
    
    public class func getObjectWithId<G:GETable>(id:String, type:G.Type, var headers: Dictionary<String, AnyObject>) -> Future<G> {
        let url = root / G.resourceNamePlural / id
        return requestObject(type, url: url, requestMethod: RequestMethod.GET, coder:nil , headers: headers)
    }
    
    public class func getObjects<G:GETable, R:RESTfull>(type:G.Type, from:R, var headers: Dictionary<String, AnyObject>) -> Future<[G]> {
        let url = root / R.resourceNamePlural / from.id / G.resourceNamePlural
        return requestObjects(type, url: url, requestMethod: RequestMethod.GET, coder:nil , headers: headers)
    }
    
    public class func getObject<G:GETable, R:RESTfull>(type:G.Type, from:R, var headers: Dictionary<String, AnyObject>) -> Future<G> {
        let url = root / R.resourceNamePlural / from.id / G.resourceName
        return requestObject(type, url: url, requestMethod: RequestMethod.GET, coder:nil , headers: headers)
    }
    
    // MARK: POST
    
    public class func postObject<P:POSTable>(object:P, var headers: Dictionary<String, AnyObject>) -> Future<P> {
        let url = root / P.resourceName
        return requestObject(P.self, url: url, requestMethod: RequestMethod.POST, coder: object.postCoder(Coder()), headers: headers)
    }
    
    public class func postObject<P:POSTable, R:RESTfull>(object:P, to:R, var headers: Dictionary<String, AnyObject>) -> Future<P> {
        let url = root / R.resourceNamePlural / to.id / P.resourceNamePlural
        return requestObject(P.self, url: url, requestMethod: RequestMethod.POST, coder: object.postCoder(Coder()), headers: headers)
    }
    
    public class func postObjectWithoutResponse<P:POSTable>(object:P, var headers: Dictionary<String, AnyObject>) -> Future<Successful> {
        let url = root / P.resourceName
        return requestDecoder(url, requestMethod: RequestMethod.POST, coder: object.postCoder(Coder()), headers: headers).map { decoder in
            return Try.Success(Successful())
        }
    }
    
    // MARK: UPDATE
    
    public class func updateObject<U:UPDATEable>(object:U, var headers: Dictionary<String, AnyObject>) -> Future<U> {
        let url = root / U.resourceNamePlural / object.id
        return requestObject(U.self, url: url, requestMethod: RequestMethod.PUT, coder: object.updateCoder(Coder()), headers: headers)
    }
    
    // MARK: DELETE
    
    public class func deleteObjectWithId<D:DELETEable>(id:String, type:D.Type, var headers: Dictionary<String, AnyObject>) -> Future<Successful> {
        let url = root / D.resourceNamePlural / id
        return requestDecoder(url, requestMethod: RequestMethod.DELETE, coder:nil, headers: headers).map { decoder in
            return Try.Success(Successful())
        }
    }
    
    // MARK: Objects
    
    public class func requestObject<T:Decodable>(type:T.Type, url:String, requestMethod: RequestMethod, coder: Coder?, var headers: Dictionary<String, AnyObject>) -> Future<T> {
        return requestDecoder(url, requestMethod: requestMethod, coder: coder, headers: headers).map {decoder -> (Try<T>) in
            if let object = T(decoder: decoder) {
                return Try.Success(object)
            } else {
                return Try.Failure(NSError(domain: "com.service", code: 0, userInfo: ["message":"Could not create object"]))
            }
        }
    }
    
    public class func requestObjects<T:Decodable>(type:T.Type, url:String, requestMethod: RequestMethod, coder: Coder?, var headers: Dictionary<String, AnyObject>) -> Future<[T]> {
        return requestDecoder(url, requestMethod: requestMethod, coder: coder, headers: headers).map {decoder -> (Try<[T]>) in
            if let array = decoder.arr {
                return Try.Success(flatMap(array) {d -> T? in T(decoder: d)})
            } else {
                return Try.Failure(NSError(domain: "com.service", code: 0, userInfo: ["message":"Expected an array"]))
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
            if response.isStatusCodeValid {
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