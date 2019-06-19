//
//  RequestUtils.swift
//  ZDHttpUtilsDemo
//
//  Created by season on 2018/12/4.
//  Copyright © 2018 season. All rights reserved.
//

import Foundation
import Alamofire

/// 网络请求RequestUtils
public class RequestUtils {
    
    /// 请求参数设置
    let httpConfig: HttpConfig
    
    /// Alamofire.SessionManager
    let sessionManager: SessionManager
    
    /// 请求头
    var headers: HTTPHeaders = [:]
    
    /// 默认的网络请求实体
    public static let `default` = RequestUtils()

    /// 自定义的初始化方法
    /// 对外
    /// - Parameter HttpConfig: 请求参数设置
    public init(httpConfig: HttpConfig) {
        
        self.httpConfig = httpConfig
        
        //  headers的处理
        var headers = ["Content-Type": "application/json"]
        headers.merge(httpConfig.addHeads) { (current, new) -> String in return new }
        headers.merge(SessionManager.defaultHTTPHeaders) { (current, new) -> String in return new }
        print("headers: \(headers)")
        self.headers = headers
        
        //  处理SessionManager
        let manager: SessionManager = {
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = httpConfig.timeout
            configuration.httpAdditionalHeaders = headers
            return SessionManager(configuration: configuration)
        }()
        
        //  处理CA证书相关
        if let trustPolicy = httpConfig.trustPolicy, let p12Path = httpConfig.p12Path, let p12password = httpConfig.p12password {
            HttpUtils.challenge(sessionManage: manager, trustPolicy: trustPolicy, p12Path: p12Path, p12password: p12password)
        }
        
        SessionManager.custom = manager
        sessionManager = SessionManager.custom
    }
    
    /// RequestUtils.default的初始化方法,私有的初始化方法
    private init() {
        let httpConfig = HttpConfig.Builder().setServerTrustPolicyManager(HttpsServerTrustPolicy.manager).constructor
        self.httpConfig = httpConfig
        
        //  为了初始化的时候加入serverTrustPolicyManager，我必须创建一个SessionManager
        let manager: SessionManager = {
            let configuration = URLSessionConfiguration.default
            configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
            return SessionManager(configuration: configuration, serverTrustPolicyManager: httpConfig.serverTrustPolicyManager)
        }()
        
        SessionManager.main = manager
        sessionManager = SessionManager.main
    }
    
    deinit {
        #if DEBUG
        print("FawNetUtils被销毁了")
        #endif
    }
}

// MARK: - 请求方法,回调为基本数据类型
extension RequestUtils {
    
    /// 基本请求
    ///
    /// - Parameters:
    ///   - method: 请求方式
    ///   - url: 请求网址
    ///   - parameters: 请求参数
    ///   - interceptHandle: 拦截回调
    ///   - callbackHandler: 结果回调
    public func request<T: Codable>(method: HTTPMethod? = nil, url: URLConvertible, parameters: Parameters? = nil, adapter: Adapter = Adapter.default, responseResultHandle: @escaping ResponseResultHandle<T>) {
        /// 自定义的请求
        HttpUtils.request(sessionManager: sessionManager, method: method ?? httpConfig.requestType, url: url, parameters: parameters, headers: headers, adapter: adapter, responseResultHandle: responseResultHandle)
    }
    
    /// get请求
    ///
    /// - Parameters:
    ///   - url: 请求网址
    ///   - parameters: 请求参数
    ///   - interceptHandle: 拦截回调
    ///   - callbackHandler: 结果回调
    public func get<T: Codable>(url: URLConvertible, parameters: Parameters? = nil, adapter: Adapter = Adapter.default, responseResultHandle: @escaping ResponseResultHandle<T>) {
        HttpUtils.request(sessionManager: sessionManager, method: .get, url: url, parameters: parameters, headers: headers, adapter: adapter, responseResultHandle: responseResultHandle)
    }
    
    /// post请求
    ///
    /// - Parameters:
    ///   - url: 请求网址
    ///   - parameters: 请求参数
    ///   - interceptHandle: 拦截回调
    ///   - callbackHandler: 结果回调
    public func post<T: Codable>(url: URLConvertible, parameters: Parameters? = nil, adapter: Adapter = Adapter.default, responseResultHandle: @escaping ResponseResultHandle<T>) {
        HttpUtils.request(sessionManager: sessionManager, method: .post, url: url, parameters: parameters, headers: headers, adapter: adapter, responseResultHandle: responseResultHandle)
    }
}

// MARK: - 文件上传请求
extension RequestUtils {
    
    /// 上传请求
    ///
    /// - Parameters:
    ///   - url: 请求网址
    ///   - uploadStream: 上传的数据流
    ///   - parameters: 请求参数
    ///   - size: 文件的长宽
    ///   - mimeType: 文件类型
    ///   - callbackHandler: 结果回调
    public func upload(url: URLConvertible,
                       uploadStream: UploadStream,
                       parameters: Parameters? = nil,
                       size: CGSize? = nil,
                       mimeType: MimeType,
                       callbackHandler: UploadCallbackHandler) {
        HttpUtils.uploadData(sessionManager: sessionManager, url: url, uploadStream: uploadStream, parameters: parameters, headers: headers, size: size, mimeType: mimeType, callbackHandler: callbackHandler)
    }
    
    /// 文件路径上传
    ///
    /// - Parameters:
    ///   - filePath: 文件路径
    ///   - url: 请求网址
    ///   - method: 请求方式,默认是post
    ///   - headers: 请求头
    ///   - callbackHandler: 上传回调
    public func uploadFromeFilePath(filePath: String,
                                    to url: URLConvertible,
                                    method: HTTPMethod = .post,
                                    headers: HTTPHeaders? = nil,
                                    callbackHandler: UploadCallbackHandler) {
        HttpUtils.uploadFromeFilePath(sessionManager: sessionManager, filePath: filePath, to: url, method: method, headers: headers, callbackHandler: callbackHandler)
    }
}

// MARK: - 文件下载请求
extension RequestUtils {
    
    /// 下载请求
    ///
    /// - Parameters:
    ///   - url: 请求网址
    ///   - parameters: 请求参数
    ///   - callbackHandler: 结果回调
    /// - Returns: 下载任务字典
    @discardableResult
    public func download(url: URLConvertible, parameters: Parameters? = nil, callbackHandler: DownloadCallbackHandler) -> DownloadRequestTask? {
        return HttpUtils.downloadData(sessionManager: sessionManager, url: url, parameters: parameters, headers: headers, callbackHandler: callbackHandler)
    }
    
    /// 通过url暂停下载任务
    ///
    /// - Parameter url: 请求网址
    public static func suspendDownloadRequest(url: URLConvertible) {
        HttpUtils.suspendDownloadRequest(url: url)
    }
    
    /// 通过url继续下载任务
    ///
    /// - Parameter url: 请求网址
    public static func resumeDownloadRequest(url: URLConvertible) {
        HttpUtils.resumeDownloadRequest(url: url)
    }
    
    /// 通过url取消下载任务
    ///
    /// - Parameter url: 请求网址
    public static func cancelDownloadRequest(url: URLConvertible) {
        HttpUtils.cancelDownloadRequest(url: url)
    }
}

// MARK: - 一个是自定义的sessionManager.其目的是为了让FawNetUtils中的sessionManager活着
extension SessionManager {
    
    /// 自定义的sessionManager
    static var custom: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        return SessionManager(configuration: configuration)
    }()
    
    /// 主要的sessionManager
    static var main: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        return SessionManager(configuration: configuration)
    }()
}

