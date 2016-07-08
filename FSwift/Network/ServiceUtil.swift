//
//  ServiceUtil.swift
//  FSwift
//
//  Created by Kelton Person on 11/15/14.
//  Copyright (c) 2014 Kelton. All rights reserved.
//

import Foundation

let emptyBody:Data =  "".data(using: String.Encoding.utf8, allowLossyConversion: false)!


public class RequestResponse {
    
    public let statusCode: Int
    public let body: Data
    public let headers: Dictionary<String, AnyObject>
    
    private var bodyText: String?

    init(statusCode: Int, body: Data, headers: Dictionary<String, AnyObject>) {
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
    
    func withParams(_ params: Dictionary<String, AnyObject>, arrayEncodingStrategy: ArrayEncodingStrategy = ArrayEncodingStrategy.multiParam) -> String {
        let endpoint = self.hasPrefix("?") ? self :  self + "?"
       return  endpoint + (NSString(data: ServiceUtil.asParams(params, arrayEncodingStrategy: arrayEncodingStrategy), encoding: String.Encoding.utf8.rawValue)! as String)
    }
    
}


public class ServiceUtil {
    
    public class func asJson(_ obj: AnyObject, jsonWriteOptions: JSONSerialization.WritingOptions = JSONSerialization.WritingOptions()) -> Data? {
        do  {
            return try JSONSerialization.data(withJSONObject: obj, options: jsonWriteOptions)
        }
        catch {
            return nil
        }
    }

    public class func asParamsStr(_ params: Dictionary<String, AnyObject>, arrayEncodingStrategy: ArrayEncodingStrategy = ArrayEncodingStrategy.multiParam) -> String {
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
                    if arrayEncodingStrategy == ArrayEncodingStrategy.multiParam {
                        pairs.append( "\(key)=\(escapedFormat)")
                    }
                    else {
                        pairs.append("\(key)[]=\(escapedFormat)")
                    }
                }
            }
            else {
                let escapedFormat = CFURLCreateStringByAddingPercentEscapes(nil, value.description, nil, "!*'();:@&=+$,/?%#[]", CFStringBuiltInEncodings.UTF8.rawValue)
                
                pairs.append( "\(key)=\(escapedFormat)")
            }
        }
        
        let str = pairs.joined(separator: "&")
        return str
    }
    
    public class func asParams(_ params: Dictionary<String, AnyObject>, arrayEncodingStrategy: ArrayEncodingStrategy = ArrayEncodingStrategy.multiParam) -> Data {
        return asParamsStr(params, arrayEncodingStrategy: arrayEncodingStrategy).data(using: String.Encoding.utf8)!
    }
    
    public class func delete(_ url:String, body: Data = emptyBody, headers: Dictionary<String, AnyObject> = [:]) -> Future<RequestResponse> {
        return request(url, requestMethod: RequestMethod.DELETE, body: body, headers: headers)
    }

    public class func get(_ url:String, headers: Dictionary<String, AnyObject> = [:]) -> Future<RequestResponse> {
        return request(url, requestMethod: RequestMethod.GET, body: emptyBody, headers: headers)
    }
    
    public class func post(_ url:String, body: Data = emptyBody, headers: Dictionary<String, AnyObject> = [:]) -> Future<RequestResponse> {
        return request(url, requestMethod: RequestMethod.POST, body: body, headers: headers)
    }
    
    public class func put(_ url:String, body: Data = emptyBody, headers: Dictionary<String, AnyObject> = [:]) -> Future<RequestResponse> {
        return request(url, requestMethod: RequestMethod.PUT, body: body, headers: headers)
    }
    
    public class func options(_ url:String, headers: Dictionary<String, AnyObject> = [:]) -> Future<RequestResponse> {
        return request(url, requestMethod: RequestMethod.OPTIONS, body: emptyBody, headers: headers)
    }
    
    public class func request(_ url:String, requestMethod: RequestMethod, body: Data, headers: Dictionary<String, AnyObject>) -> Future<RequestResponse> {
        var request = URLRequest(url: URL(string: url)!)
        let session = URLSession.shared
        request.httpMethod = requestMethod.rawValue
        request.httpBody = body
        
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
            if error != nil {
              promise.completeWith(error!)
            }
            else {
                let httpResponse = response as! HTTPURLResponse
                
                var responseHeaders:Dictionary<String, AnyObject> = [:]
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


public class ChunkedService {
    
    public class func request(_ url:String, requestMethod: RequestMethod, body: Data, headers: [String : AnyObject]) -> Chunker {
        
        let req = NSMutableURLRequest(url: URL(string: url)!)
        req.timeoutInterval = 2000.years
        req.httpMethod = requestMethod.rawValue
        req.httpBody = body
        return Chunker(request: req as URLRequest)
    }
    
    public class func delete(_ url:String, body: Data = emptyBody, headers: [String : AnyObject] = [:]) -> Chunker  {
        return request(url, requestMethod: RequestMethod.DELETE, body: body, headers: headers)
    }
    
    public class func get(_ url:String, headers: [String : AnyObject] = [:]) -> Chunker {
        return request(url, requestMethod: RequestMethod.GET, body: emptyBody, headers: headers)
    }
    
    public class func post(_ url:String, body: Data = emptyBody, headers: [String : AnyObject] = [:]) -> Chunker  {
        return request(url, requestMethod: RequestMethod.POST, body: body, headers: headers)
    }
    
    public class func put(_ url:String, body: Data = emptyBody, headers: [String : AnyObject] = [:]) -> Chunker  {
        return request(url, requestMethod: RequestMethod.PUT, body: body, headers: headers)
    }
    
    public class func options(_ url:String, headers: [String : AnyObject] = [:]) -> Chunker  {
        return request(url, requestMethod: RequestMethod.OPTIONS, body: emptyBody, headers: headers)
    }
    
}


public struct DataChunk<T> {
    
    public let data: T
    
}

public enum ChunkedMessagePart<T> {
    
    case chunkedStarted(URLResponse)
    case chunkedMessage(DataChunk<T>)
    case chunkedEnd
    case chunkedError(NSError)
    
    public func map<B>(_ t: (T) -> B) -> ChunkedMessagePart<B> {
        switch self {
        case .chunkedMessage(let chunk):
            let newChunk = DataChunk<B>(data: t(chunk.data))
            return ChunkedMessagePart<B>.chunkedMessage(newChunk)
        case .chunkedStarted(let response):
            return ChunkedMessagePart<B>.chunkedStarted(response)
        case .chunkedEnd:
            return ChunkedMessagePart<B>.chunkedEnd
        case .chunkedError(let error):
            return ChunkedMessagePart<B>.chunkedError(error)
        }
    }
}


public class Chunker : NSObject {
    
    public let stream = Stream<ChunkedMessagePart<Data>>()
    private var connection: NSURLConnection?
    
    public init(request: URLRequest) {
        super.init()
        connection = NSURLConnection(request: request, delegate: self, startImmediately: true)
    }
    
    public func connection(_ didReceiveResponse: NSURLConnection!, didReceiveResponse response: URLResponse!) {
        let _ = stream.publish(ChunkedMessagePart.chunkedStarted(response))
    }
    
    public func connection(_ connection: NSURLConnection!, didReceiveData conData: Data!) {
        let _ = stream.publish(ChunkedMessagePart.chunkedMessage(DataChunk(data: conData)))
    }
    
    public func connection(_ connection: NSURLConnection!, didFailWithError error: NSError) {
        let _ = stream.publish(ChunkedMessagePart.chunkedError(error))
    }
    
    public func connectionDidFinishLoading(_ connection: NSURLConnection!) {
        let _ = stream.publish(ChunkedMessagePart.chunkedEnd)
    }
    
    public func close() {
        connection?.cancel()
    }
    
}
