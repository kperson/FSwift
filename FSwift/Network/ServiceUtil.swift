//
//  ServiceUtil.swift
//  FSwift
//
//  Created by Kelton Person on 11/15/14.
//  Copyright (c) 2014 Kelton. All rights reserved.
//

import Foundation

let emptyBody:NSData =  "".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!


public class RequestResponse {
    
    public let statusCode: Int
    public let body: NSData
    public let headers: Dictionary<String, AnyObject>
    
    private var bodyText: String?

    init(statusCode: Int, body: NSData, headers: Dictionary<String, AnyObject>) {
        self.statusCode = statusCode
        self.body = body
        self.headers = headers
    }
    
    public var bodyAsText: String {
        if let bodyT = self.bodyText {
            return bodyT
        }
        else {
            self.bodyText = NSString(data: body, encoding: NSUTF8StringEncoding)!
            return self.bodyText!
        }
    }
    
}

public enum RequestMethod : String {
    
    case POST = "POST"
    case GET = "GET"
    case DELETE = "DELETE"
    case PUT = "PUT"
    case OPTION = "OPTION"
    
}

public extension String {
    
    func withParams(params: Dictionary<String, AnyObject>) -> String {
        let endpoint = self.hasPrefix("?") ? self :  self + "?"
       return  endpoint + NSString(data: ServiceUtil.asParams(params), encoding: NSUTF8StringEncoding)!
    }
    
}


public class ServiceUtil {
    
    public class func asJson(obj: AnyObject) -> NSData? {
        var error: NSError?
        return NSJSONSerialization.dataWithJSONObject(obj, options: NSJSONWritingOptions.PrettyPrinted, error: &error)
    }

    public class func asParamsStr(params: Dictionary<String, AnyObject>) -> String {
        var pairs:[String] = []
        for (key, value) in params {
            if let v = value as? Dictionary<String, AnyObject> {
                for (subKey, subValue) in v {
                    let escapedFormat = CFURLCreateStringByAddingPercentEscapes(nil, subValue.description, nil, "!*'();:@&=+$,/?%#[]", CFStringBuiltInEncodings.UTF8.rawValue)
                    pairs.append("\(key)[\(subKey)]=\(escapedFormat)")
                }
            }
            else if let v = value as? [AnyObject] {
                for subValue in v {
                    let escapedFormat = CFURLCreateStringByAddingPercentEscapes(nil, subValue.description, nil, "!*'();:@&=+$,/?%#[]", CFStringBuiltInEncodings.UTF8.rawValue)
                    pairs.append("\(key)[]=\(escapedFormat)")
                }
            }
            else {
                let escapedFormat = CFURLCreateStringByAddingPercentEscapes(nil, value.description, nil, "!*'();:@&=+$,/?%#[]", CFStringBuiltInEncodings.UTF8.rawValue)
                
                pairs.append( "\(key)=\(escapedFormat)")
            }
        }
        let str = "&".join(pairs)
        return str
    }
    
    public class func asParams(params: Dictionary<String, AnyObject>) -> NSData {
        return asParamsStr(params).dataUsingEncoding(NSUTF8StringEncoding)!
    }
    
    public class func delete(url:String, body: NSData = emptyBody, headers: Dictionary<String, AnyObject> = [:]) -> Future<RequestResponse> {
        return ServiceUtil.request(url, requestMethod: RequestMethod.DELETE, body: body, headers: headers)
    }

    public class func get(url:String, headers: Dictionary<String, AnyObject> = [:]) -> Future<RequestResponse> {
        return ServiceUtil.request(url, requestMethod: RequestMethod.GET, body: emptyBody, headers: headers)
    }
    
    public class func post(url:String, body: NSData = emptyBody, headers: Dictionary<String, AnyObject> = [:]) -> Future<RequestResponse> {
        return ServiceUtil.request(url, requestMethod: RequestMethod.POST, body: body, headers: headers)
    }
    
    public class func put(url:String, body: NSData = emptyBody, headers: Dictionary<String, AnyObject> = [:]) -> Future<RequestResponse> {
        return ServiceUtil.request(url, requestMethod: RequestMethod.PUT, body: body, headers: headers)
    }
    
    public class func option(url:String, headers: Dictionary<String, AnyObject> = [:]) -> Future<RequestResponse> {
        return ServiceUtil.request(url, requestMethod: RequestMethod.OPTION, body: emptyBody, headers: headers)
    }
    
    public class func request(url:String, requestMethod: RequestMethod, body: NSData, headers: Dictionary<String, AnyObject>) -> Future<RequestResponse> {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let session = NSURLSession.sharedSession()
        //let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        request.HTTPMethod = requestMethod.rawValue
        request.HTTPBody = body
        
        for (headerKey, headerValue) in headers {
            if let multiHeader = headerValue as? [String] {
                for str in multiHeader {
                    request.addValue(str, forHTTPHeaderField: headerKey)
                }
            }
            else {
                request.addValue(headerValue as? String, forHTTPHeaderField: headerKey)
            }
        }
        
        let future = Future<RequestResponse>()
        var error: NSError
        
        let task = session.dataTaskWithRequest(request, completionHandler: { data, response, error -> Void in
            if error != nil {
              future.bridgeFailure(error)
            }
            else {
                let httpResponse = response as NSHTTPURLResponse
                
                var responseHeaders:Dictionary<String, AnyObject> = [:]
                for (headerKey, headerValue) in httpResponse.allHeaderFields {
                    responseHeaders[headerKey as String] = headerValue
                }
                
                future.bridgeSuccess(RequestResponse(statusCode: httpResponse.statusCode, body: data, headers: responseHeaders))
            }
        })
        
        task.resume()
        return future
    }
    
}
