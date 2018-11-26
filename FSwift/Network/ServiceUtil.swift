//
//  ServiceUtil.swift
//  FSwift
//
//  Created by Kelton Person on 11/15/14.
//  Copyright (c) 2014 Kelton. All rights reserved.
//

import Foundation


public class RequestResponse {
    
    
    public let statusCode: Int
    public let body: Data
    public let headers: Dictionary<String, Any>
    
    private var bodyText: String?
    
    init(statusCode: Int, body: Data, headers: Dictionary<String, Any>) {
        self.statusCode = statusCode
        self.body = body
        self.headers = headers
    }
    
    public var bodyAsText: String {
        if let bodyT = self.bodyText {
            return bodyT
        }
        else {
            self.bodyText = NSString(data: body, encoding: String.Encoding.utf8.rawValue)! as String
            return self.bodyText!
        }
    }
    
}


public enum ArrayEncodingStrategy {
    
    case php
    case multiParam
}

public enum RequestMethod : String {
    
    case POST = "POST"
    case GET = "GET"
    case DELETE = "DELETE"
    case PUT = "PUT"
    case OPTIONS = "OPTIONS"
    case CONNECT = "CONNECT"
    case TRACE = "TRACE"
    case HEAD = "HEAD"
    case PATCH = "PATCH"
    
}


public extension String {
    
    func withParams(_ params: Dictionary<String, Any>, arrayEncodingStrategy: ArrayEncodingStrategy = ArrayEncodingStrategy.multiParam) -> String {
        let endpoint = self.hasPrefix("?") ? self :  self + "?"
        return  endpoint + (NSString(data: HttpService.asParams(params, arrayEncodingStrategy: arrayEncodingStrategy), encoding: String.Encoding.utf8.rawValue)! as String)
    }
    
}


public enum RequestBodyInput {
    case Data(Data)
    case InputStream(InputStream)
}

public class HttpService {
    
    public static var defaultCachePolicy: URLRequest.CachePolicy? = nil
    
    public static let emptyBody:Data =  "".data(using: String.Encoding.utf8, allowLossyConversion: false)!
    
    public class func asJson(_ obj: Any, jsonWriteOptions: JSONSerialization.WritingOptions = JSONSerialization.WritingOptions()) -> Data? {
        do  {
            return try JSONSerialization.data(withJSONObject: obj, options: jsonWriteOptions)
        }
        catch {
            return nil
        }
    }
    
    public class func asParamsStr(_ params: Dictionary<String, Any>, arrayEncodingStrategy: ArrayEncodingStrategy = ArrayEncodingStrategy.multiParam) -> String {
        var pairs:[String] = []
        for (key, value) in params {
            if let v = value as? Dictionary<String, AnyObject> {
                for (subKey, subValue) in v {
                    let escapedFormat = subValue.description!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
                    
                    pairs.append("\(key)[\(subKey)]=\(escapedFormat)")
                }
            }
            else if let v = value as? [AnyObject] {
                for subValue in v {
                    let escapedFormat = subValue.description!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
                    
                    if arrayEncodingStrategy == ArrayEncodingStrategy.multiParam {
                        pairs.append( "\(key)=\(escapedFormat)")
                    }
                    else {
                        pairs.append("\(key)[]=\(escapedFormat)")
                    }
                }
            }
            else {
                let escapedFormat = (value as AnyObject).description!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
                
                
                pairs.append( "\(key)=\(escapedFormat)")
            }
        }
        
        let str = pairs.joined(separator: "&")
        return str
    }
    
    public class func asParams(_ params: Dictionary<String, Any>, arrayEncodingStrategy: ArrayEncodingStrategy = ArrayEncodingStrategy.multiParam) -> Data {
        return asParamsStr(params, arrayEncodingStrategy: arrayEncodingStrategy).data(using: String.Encoding.utf8)!
    }
    
    public class func delete(_ url:String, body: Data = emptyBody, headers: Dictionary<String, Any> = [:]) -> Future<RequestResponse> {
        return request(url, requestMethod: RequestMethod.DELETE, bodyInput: .Data(body), headers: headers)
    }
    
    public class func get(_ url:String, headers: Dictionary<String, Any> = [:]) -> Future<RequestResponse> {
        return request(url, requestMethod: RequestMethod.GET, bodyInput: .Data(emptyBody), headers: headers)
    }
    
    public class func post(_ url:String, body: Data = emptyBody, headers: Dictionary<String, Any> = [:]) -> Future<RequestResponse> {
        return request(url, requestMethod: RequestMethod.POST, bodyInput: .Data(body), headers: headers)
    }
    
    public class func postStream(_ url:String, stream: InputStream, headers: Dictionary<String, Any> = [:]) -> Future<RequestResponse> {
        return request(url, requestMethod: RequestMethod.POST, bodyInput: .InputStream(stream), headers: headers)
    }
    
    public class func put(_ url:String, body: Data = emptyBody, headers: Dictionary<String, Any> = [:]) -> Future<RequestResponse> {
        return request(url, requestMethod: RequestMethod.PUT, bodyInput: .Data(body), headers: headers)
    }
    
    public class func putStream(_ url:String, stream: InputStream, headers: Dictionary<String, Any> = [:]) -> Future<RequestResponse> {
        return request(url, requestMethod: RequestMethod.PUT, bodyInput: .InputStream(stream), headers: headers)
    }
    
    public class func options(_ url:String, headers: Dictionary<String, Any> = [:]) -> Future<RequestResponse> {
        return request(url, requestMethod: RequestMethod.OPTIONS, bodyInput: .Data(emptyBody), headers: headers)
    }
    
    public class func request(_ url:String, requestMethod: RequestMethod, bodyInput: RequestBodyInput, headers: Dictionary<String, Any>) -> Future<RequestResponse> {
        var request = URLRequest(url: URL(string: url)!)
        if let c = HttpService.defaultCachePolicy {
            request.cachePolicy = c
        }
        let session = URLSession.shared
        request.httpMethod = requestMethod.rawValue
        switch bodyInput {
        case RequestBodyInput.Data(let d): request.httpBody = d
        case RequestBodyInput.InputStream(let i): request.httpBodyStream = i
        }
        
        for (headerKey, headerValue) in headers {
            if let multiHeader = headerValue as? [String] {
                for str in multiHeader {
                    request.addValue(str, forHTTPHeaderField: headerKey)
                }
            }
            else {
                request.addValue(headerValue as! String, forHTTPHeaderField: headerKey)
            }
        }
        
        let promise = Promise<RequestResponse>()
        
        
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            if let e = error {
                promise.completeWith(e as NSError)
            }
            else {
                let httpResponse = response as! HTTPURLResponse
                
                var responseHeaders:Dictionary<String, Any> = [:]
                for (headerKey, headerValue) in httpResponse.allHeaderFields {
                    responseHeaders[headerKey as! String] = headerValue
                }
                
                promise.completeWith(RequestResponse(statusCode: httpResponse.statusCode, body: data!, headers: responseHeaders))
            }
        })
        
        task.resume()
        return promise.future
    }
    
    
}
