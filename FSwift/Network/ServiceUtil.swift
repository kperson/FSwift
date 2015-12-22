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

enum RXOverflowStrategy {
    
    case DropFirst
    case DropList
    case Reject
    
}


class RXBuffer<ItemType> : RXSubscription {
    
    typealias T = ItemType
    let maxSize:Int
    let strategy: RXOverflowStrategy
    private var queue:[T] = []
    private var subscriber: RXSubscriberContainer<T>
    private (set)var totalDemand = 0
    private (set)var isCancelled: Bool = false
    
    init(maxSize: Int, subscriber: RXSubscriberContainer<T>, strategy: RXOverflowStrategy) {
        self.maxSize = maxSize
        self.strategy = strategy
        self.subscriber = subscriber
    }
    
    func next(item: T) {
        if isOpen {
            if totalDemand > 0 {
                subscriber.onNext(item)
                totalDemand = totalDemand - 1
            }
            else {
                if maxSize < queue.count {
                    queue.append(item)
                }
                else {
                    applyOverflowStrategy(item)
                }
            }
        }
    }
    
    
    func error(err: ErrorType) {
        if isOpen {
            subscriber.onError(err)
        }
    }
    
    
    func complete() {
        if isOpen {
            subscriber.onComplete()
        }
    }
    
    func requestMore(n: Int) {
        if isOpen {
            totalDemand = totalDemand + n
            matchDemand()
        }
    }
    
    func cancel() {
        isCancelled = true
    }
    
    var isOpen: Bool {
        return !isCancelled
    }
    
    private func applyOverflowStrategy(item: T) {
        switch strategy {
        case .DropFirst:
            queue.removeAtIndex(0)
            queue.append(item)
        case .DropList:
            queue.removeLast()
            queue.append(item)
        case .Reject: Void()
        }
    }
    
    private func matchDemand() {
        while totalDemand > 0 && !queue.isEmpty {
            let item = queue.removeFirst()
            subscriber.onNext(item)
            totalDemand = totalDemand - 1
        }
    }
}

class RXSubscriberContainer<ItemType> : RXSubcriber {
    
    typealias T = ItemType
    private var onNextHandler:(T -> Void)
    private var onErrorHandler:(ErrorType -> Void)
    private var onCompleteHandler:(() -> Void)
    private var onSubscribeHandler:((RXSubscription) -> Void)

    
    init<A: RXSubcriber where A.T == ItemType>(sub: A) {
        onSubscribeHandler = { s in sub.onSubscribe(s) }
        onNextHandler = { e in sub.onNext(e) }
        onErrorHandler = { e in sub.onError(e) }
        onCompleteHandler = { sub.onComplete() }
    }
    
    func onSubscribe(s: RXSubscription) {
        onSubscribeHandler(s)
    }
    
    func onNext(elem: T) {
        onNextHandler(elem)
    }
    
    func onError(err: ErrorType) {
        onErrorHandler(err)
    }
    
    func onComplete() {
        onCompleteHandler()
    }
    
}


class RXSubscriberFunctionContainer<ItemType> : RXSubcriber {
    
    typealias T = ItemType
    
    var onNextHandler:(T -> Void)?
    var onErrorHandler:(ErrorType -> Void)?
    var onCompleteHandler:(() -> Void)?
    var onSubscribeHandler:((RXSubscription) -> Void)?
    
    
    func onSubscribe(s: RXSubscription) {
        onSubscribeHandler?(s)
    }
    
    func onNext(elem: T) {
        onNextHandler?(elem)
    }
    
    func onError(err: ErrorType) {
        onErrorHandler?(err)
    }
    
    func onComplete() {
        onCompleteHandler?()
    }
    
}

class RXBufferedPublisher<ItemType> : RXPublisher {
    
    typealias T = ItemType
    private var buffer:RXBuffer<T>?
    let maxBufferSize:Int
    let overflowStrategy:RXOverflowStrategy
    var startCommand: () -> Void = { _ in }
    
    init(maxBufferSize: Int = 100, overflowStrategy: RXOverflowStrategy = RXOverflowStrategy.Reject) {
        self.maxBufferSize = maxBufferSize
        self.overflowStrategy = overflowStrategy
    }
    
    func subscribe<A: RXSubcriber where A.T == T>(sub: A) {
        let containerSubscriber = RXSubscriberContainer(sub: sub)
        let b = RXBuffer(maxSize: maxBufferSize, subscriber: containerSubscriber, strategy: overflowStrategy)
        buffer = b
        startCommand = { b.requestMore(1) }
        sub.onSubscribe(b)
    }
    
    func next(item: ItemType) {
        buffer?.next(item)
    }
    
    func error(err: ErrorType) {
        buffer?.error(err)
    }
    
    func complete() {
        buffer?.complete()
    }
    
    func start() {
        startCommand()
    }
    
}


class Source<T>  {
    
    private let p: RXBufferedPublisher<T>
    
    init(queue: NSOperationQueue, maxBufferSize: Int = 100, overflowStrategy: RXOverflowStrategy = RXOverflowStrategy.Reject) {
        self.p = RXBufferedPublisher<T>(maxBufferSize: maxBufferSize, overflowStrategy: overflowStrategy)
        let q = RXBufferedPublisher<String>()
        q.filter { x in x.characters.count > 2 }.map { z in z.characters.count }
    }
    
    var publisher:RXBufferedPublisher<T> {
        return p
    }
}




extension RXBufferedPublisher {
    
    func map<Q>(handler: (ItemType) -> Q) -> RXBufferedPublisher<Q> {
        let pipe = RXBufferedPublisher<Q>(maxBufferSize: maxBufferSize, overflowStrategy: overflowStrategy)
        
        let connecterContainer = RXSubscriberFunctionContainer<ItemType>()
        connecterContainer.onNextHandler = { x in
            pipe.next(handler(x))
            
        }
        connecterContainer.onErrorHandler = { err in pipe.error(err) }
        connecterContainer.onCompleteHandler = { pipe.complete() }
        connecterContainer.onCompleteHandler = { pipe.complete() }
        
        subscribe(connecterContainer)
        return pipe
    }
    
    func forEach(handler: (ItemType) -> Void) -> RXBufferedPublisher<Void> {
        return map(handler)
    }
    
    func filter(check: (ItemType) -> Bool) -> RXBufferedPublisher<ItemType> {
        let pipe = RXBufferedPublisher<ItemType>(maxBufferSize: maxBufferSize, overflowStrategy: overflowStrategy)
        
        let connecterContainer = RXSubscriberFunctionContainer<ItemType>()
        var subscription: RXSubscription?
        connecterContainer.onNextHandler = { x in
            if(check(x)) {
                pipe.next(x)
            }
            else {
                subscription?.requestMore(1)
            }
        }
        connecterContainer.onErrorHandler = { err in pipe.error(err) }
        connecterContainer.onCompleteHandler = { pipe.complete() }
        connecterContainer.onSubscribeHandler = { sub in
            subscription = sub
        }
        
        subscribe(connecterContainer)
        return pipe
    }
    
}


protocol RXSubscription {
    
    func requestMore(n: Int)
    func cancel()
    
}

protocol RXSubcriber {
 
    typealias T
    func onSubscribe(s: RXSubscription)
    func onNext(elem: T)
    func onError(err: ErrorType)
    func onComplete()
    
}

protocol RXPublisher  {
    
    typealias T
    func subscribe<A: RXSubcriber where A.T == T>(sub: A)
    
}