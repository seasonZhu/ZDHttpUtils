//
//  NetworkLogger.swift
//  ZDHttpUtilsDemo
//
//  Created by season on 2019/4/1.
//  Copyright © 2019 season. All rights reserved.
//

import Foundation
import Alamofire


/// Logger的打印等级
///
/// - off: 关闭
/// - debug(用的最多): HTTP method, URL, header fields, & request body for requests, and status code, URL, header fields, response string, & elapsed time for responses
/// - info: HTTP method & URL for requests, and status code, URL, & elapsed time for responses
/// - warn: HTTP method & URL for requests, and status code, URL, & elapsed time for responses, but only for failed requests
/// - error: 同.warning
/// - fatal: 同.off
public enum NetworkLoggerLevel {
    case off
    case debug
    case info
    case warn
    case error
    case fatal
}


/// 网络请求日志
public class NetworkLogger {

    /// 单例
    public static let shared = NetworkLogger()
    
    public var isLogging = false
    
    private init() {
        level = .debug
        startDates = [URLSessionTask: Date]()
    }
    
    /// 打印等级
    public var level: NetworkLoggerLevel
    
    /// 规则
    public var filterPredicate: NSPredicate?
    
    /// 任务与时间字典
    private var startDates: [URLSessionTask: Date]
    
    /// 析构函数
    deinit {
        stopLogging()
    }
    
    /// 开始打印
    public func startLogging() {
        stopLogging()
        
        isLogging = true
        
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(
            self,
            selector: #selector(NetworkLogger.networkRequestDidStart(notification:)),
            name: Notification.Name.Task.DidResume,
            object: nil
        )
        
        notificationCenter.addObserver(
            self,
            selector: #selector(NetworkLogger.networkRequestDidComplete(notification:)),
            name: Notification.Name.Task.DidComplete,
            object: nil
        )
    }
    
    /// 停止打印
    public func stopLogging() {
        isLogging = false
        NotificationCenter.default.removeObserver(self)
    }
    
    
}

private extension NetworkLogger {
    
    /// 网络请求开始
    ///
    /// - Parameter notification: 通知
    @objc
    func networkRequestDidStart(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let task = userInfo[Notification.Key.Task] as? URLSessionTask,
            let request = task.originalRequest,
            let httpMethod = request.httpMethod,
            let requestURL = request.url
            else {
                return
        }
        
        if let filterPredicate = filterPredicate, filterPredicate.evaluate(with: request) {
            return
        }
        
        startDates[task] = Date()
        
        switch level {
        case .debug:
            logDivider()
            
            print("\(httpMethod) '\(requestURL.absoluteString)':")
            
            if let httpHeadersFields = request.allHTTPHeaderFields {
                logHeaders(headers: httpHeadersFields)
            }
            
            if let httpBody = request.httpBody, let httpBodyString = String(data: httpBody, encoding: .utf8) {
                print(httpBodyString)
            }
        case .info:
            logDivider()
            
            print("\(httpMethod) '\(requestURL.absoluteString)'")
        default:
            break
        }
    }
    
    /// 网络请求结束
    ///
    /// - Parameter notification: 通知
    @objc
    func networkRequestDidComplete(notification: Notification) {
        guard let sessionDelegate = notification.object as? SessionDelegate,
            let userInfo = notification.userInfo,
            let task = userInfo[Notification.Key.Task] as? URLSessionTask,
            let request = task.originalRequest,
            let httpMethod = request.httpMethod,
            let requestURL = request.url
            else {
                return
        }
        
        if let filterPredicate = filterPredicate, filterPredicate.evaluate(with: request) {
            return
        }
        
        var elapsedTime: TimeInterval = 0.0
        
        if let startDate = startDates[task] {
            elapsedTime = Date().timeIntervalSince(startDate)
            startDates[task] = nil
        }
        
        if let error = task.error {
            switch level {
            case .debug, .info, .warn, .error:
                logDivider()
                
                print("[Error] \(httpMethod) '\(requestURL.absoluteString)' [\(String(format: "%.04f", elapsedTime)) s]:")
                print(error)
            default:
                break
            }
        } else {
            guard let response = task.response as? HTTPURLResponse else {
                return
            }
            
            switch level {
            case .debug:
                logDivider()
                
                print("\(String(response.statusCode)) '\(requestURL.absoluteString)' [\(String(format: "%.04f", elapsedTime)) s]:")
                
                logHeaders(headers: response.allHeaderFields)
                
                guard let data = sessionDelegate[task]?.delegate.data else { break }
                
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
                    
                    if let prettyString = String(data: prettyData, encoding: .utf8) {
                        print(prettyString)
                    }
                } catch {
                    if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                        print(string)
                    }
                }
            case .info:
                logDivider()
                
                print("\(String(response.statusCode)) '\(requestURL.absoluteString)' [\(String(format: "%.04f", elapsedTime)) s]")
            default:
                break
            }
        }
    }
    
    /// 打印"---------------------"
    func logDivider() {
        print("---------------------")
    }
    
    /// 打印请求头
    ///
    /// - Parameter headers: 请求头
    func logHeaders(headers: [AnyHashable : Any]) {
        print("Headers: [")
        for (key, value) in headers {
            print("  \(key) : \(value)")
        }
        print("]")
    }
}
