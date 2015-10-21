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
            self.bodyText = NSString(data: body, encoding: NSUTF8StringEncoding)! as String
            return self.bodyText!
        }
    }
    
}


public enum ArrayEncodingStrategy {
    
    case PHP
    case MultiParam
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
    
    func withParams(params: Dictionary<String, AnyObject>, arrayEncodingStrategy: ArrayEncodingStrategy = ArrayEncodingStrategy.MultiParam) -> String {
        let endpoint = self.hasPrefix("?") ? self :  self + "?"
       return  endpoint + (NSString(data: ServiceUtil.asParams(params, arrayEncodingStrategy: arrayEncodingStrategy), encoding: NSUTF8StringEncoding)! as String)
    }
    
}


public class ServiceUtil {
    
    public class func asJson(obj: AnyObject) -> NSData? {
        do  {
            return try NSJSONSerialization.dataWithJSONObject(obj, options: NSJSONWritingOptions.PrettyPrinted)
        }
        catch {
            return nil
        }
    }

    public class func asParamsStr(params: Dictionary<String, AnyObject>, arrayEncodingStrategy: ArrayEncodingStrategy = ArrayEncodingStrategy.MultiParam) -> String {
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
                    if arrayEncodingStrategy == ArrayEncodingStrategy.MultiParam {
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
        
        let str = pairs.joinWithSeparator("&")
        return str
    }
    
    public class func asParams(params: Dictionary<String, AnyObject>, arrayEncodingStrategy: ArrayEncodingStrategy = ArrayEncodingStrategy.MultiParam) -> NSData {
        return asParamsStr(params, arrayEncodingStrategy: arrayEncodingStrategy).dataUsingEncoding(NSUTF8StringEncoding)!
    }
    
    public class func delete(url:String, body: NSData = emptyBody, headers: Dictionary<String, AnyObject> = [:]) -> Future<RequestResponse> {
        return request(url, requestMethod: RequestMethod.DELETE, body: body, headers: headers)
    }

    public class func get(url:String, headers: Dictionary<String, AnyObject> = [:]) -> Future<RequestResponse> {
        return request(url, requestMethod: RequestMethod.GET, body: emptyBody, headers: headers)
    }
    
    public class func post(url:String, body: NSData = emptyBody, headers: Dictionary<String, AnyObject> = [:]) -> Future<RequestResponse> {
        return request(url, requestMethod: RequestMethod.POST, body: body, headers: headers)
    }
    
    public class func put(url:String, body: NSData = emptyBody, headers: Dictionary<String, AnyObject> = [:]) -> Future<RequestResponse> {
        return request(url, requestMethod: RequestMethod.PUT, body: body, headers: headers)
    }
    
    public class func options(url:String, headers: Dictionary<String, AnyObject> = [:]) -> Future<RequestResponse> {
        return request(url, requestMethod: RequestMethod.OPTIONS, body: emptyBody, headers: headers)
    }
    
    public class func request(url:String, requestMethod: RequestMethod, body: NSData, headers: Dictionary<String, AnyObject>) -> Future<RequestResponse> {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = requestMethod.rawValue
        request.HTTPBody = body
        
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
        
        let task = session.dataTaskWithRequest(request, completionHandler: { data, response, error -> Void in
            if error != nil {
              promise.completeWith(error!)
            }
            else {
                let httpResponse = response as! NSHTTPURLResponse
                
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
    
    public class func request(url:String, requestMethod: RequestMethod, body: NSData, headers: [String : AnyObject]) -> Chunker {
        
        let req = NSMutableURLRequest(URL: NSURL(string: url)!)
        req.timeoutInterval = 2000.years
        req.HTTPMethod = requestMethod.rawValue
        req.HTTPBody = body
        return Chunker(request: req)
    }
    
    public class func delete(url:String, body: NSData = emptyBody, headers: [String : AnyObject] = [:]) -> Chunker  {
        return request(url, requestMethod: RequestMethod.DELETE, body: body, headers: headers)
    }
    
    public class func get(url:String, headers: [String : AnyObject] = [:]) -> Chunker {
        return request(url, requestMethod: RequestMethod.GET, body: emptyBody, headers: headers)
    }
    
    public class func post(url:String, body: NSData = emptyBody, headers: [String : AnyObject] = [:]) -> Chunker  {
        return request(url, requestMethod: RequestMethod.POST, body: body, headers: headers)
    }
    
    public class func put(url:String, body: NSData = emptyBody, headers: [String : AnyObject] = [:]) -> Chunker  {
        return request(url, requestMethod: RequestMethod.PUT, body: body, headers: headers)
    }
    
    public class func options(url:String, headers: [String : AnyObject] = [:]) -> Chunker  {
        return request(url, requestMethod: RequestMethod.OPTIONS, body: emptyBody, headers: headers)
    }
    
}


public struct DataChunk<T> {
    
    public let data: T
    
}


public enum ChunkedMessagePart<T> {
    
    case ChunkedStarted(NSURLResponse)
    case ChunkedMessage(DataChunk<T>)
    case ChunkedEnd
    case ChunkedError(NSError)
    
    public func map<B>(t: (T) -> B) -> ChunkedMessagePart<B> {
        switch self {
        case .ChunkedMessage(let chunk):
            let newChunk = DataChunk<B>(data: t(chunk.data))
            return ChunkedMessagePart<B>.ChunkedMessage(newChunk)
        case .ChunkedStarted(let response):
            return ChunkedMessagePart<B>.ChunkedStarted(response)
        case .ChunkedEnd:
            return ChunkedMessagePart<B>.ChunkedEnd
        case .ChunkedError(let error):
            return ChunkedMessagePart<B>.ChunkedError(error)
        }
    }
}


public func rtStream(s: Stream<ChunkedMessagePart<NSData>>) -> Stream<ChunkedMessagePart<NSData>> {
    
    let stream = Stream<ChunkedMessagePart<NSData>>()
    var i = 0
    s.subscribe { x in
        switch x {
        case ChunkedMessagePart.ChunkedMessage(_):
            if i != 0 {
                stream.publish(x)
            }
            i++
        default:
            stream.publish(x)
        }
    }
    return stream
    
}

public class Chunker : NSObject {
    
    public let stream = Stream<ChunkedMessagePart<NSData>>()
    private var connection: NSURLConnection?
    
    public init(request: NSURLRequest) {
        super.init()
        connection = NSURLConnection(request: request, delegate: self, startImmediately: true)
    }
    
    public func connection(didReceiveResponse: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {
        stream.publish(ChunkedMessagePart.ChunkedStarted(response))
    }
    
    public func connection(connection: NSURLConnection!, didReceiveData conData: NSData!) {
        stream.publish(ChunkedMessagePart.ChunkedMessage(DataChunk(data: conData)))
    }
    
    public func connection(connection: NSURLConnection!, didFailWithError error: NSError) {
        stream.publish(ChunkedMessagePart.ChunkedError(error))
    }
    
    public func connectionDidFinishLoading(connection: NSURLConnection!) {
        stream.publish(ChunkedMessagePart.ChunkedEnd)
    }
    
    public func close() {
        connection?.cancel()
    }
    
}