//
//  HttpConfig.swift
//  ZDHttpUtilsDemo
//
//  Created by season on 2018/9/19.
//  Copyright © 2018年 season. All rights reserved.
//

import UIKit
import Alamofire

/// 网络请求配置项
public class HttpConfig {
    
    //MARK:- 配置可以根据需求进行增删
    
    /// 超时配置
    let timeout: TimeInterval
    
    /// 是否需要加密签名的配置
    let isNeedSign: Bool
    
    /// 添加请求头
    let addHeads: HTTPHeaders
    
    /// 请求方式
    let requestType: HTTPMethod
    
    /// 服务器认证策略
    var trustPolicy: HttpsServerTrustPolicy?
    
    /// p12证书路径
    var p12Path: String?
    
    /// p12证书的密码
    var p12password: String?
    
    /// 设置服务器认证策略管理器
    var serverTrustPolicyManager: ServerTrustPolicyManager?
    
    //MARK:- 配置构造器
    init(builder: Builder) {
        self.timeout = builder.timeout
        self.isNeedSign = builder.isNeedSign
        self.addHeads = builder.addHeads
        self.requestType = builder.requestType
        self.trustPolicy = builder.trustPolicy
        self.p12Path = builder.p12Path
        self.p12password = builder.p12password
        self.serverTrustPolicyManager = builder.serverTrustPolicyManager
    }
    
    /// 详细构造器
    public class Builder {
        
        /// 超时时间
        var timeout: TimeInterval = 15
        
        /// 是否需要签名
        var isNeedSign = false
        
        /// 添加请求头
        var addHeads: HTTPHeaders = [:]
        
        /// 请求方式
        var requestType: HTTPMethod = .get
        
        /// 服务器认证策略
        var trustPolicy: HttpsServerTrustPolicy?
        
        /// p12证书路径
        var p12Path: String?
        
        /// p12证书的密码
        var p12password: String?
        
        /// 设置服务器认证策略管理器
        var serverTrustPolicyManager: ServerTrustPolicyManager?
        
        public init() {}
        
        /// 设置超时时间
        ///
        /// - Parameter timeout: 超时时间
        /// - Returns: 对象自己
        @discardableResult
        public func setTimeout(_ timeout: TimeInterval) -> Self {
            self.timeout = timeout
            return self
        }
        
        /// 设置是否需要签名
        ///
        /// - Parameter isNeedSign: 是否需要签名
        /// - Returns: 对象自己
        @discardableResult
        public func isNeedSign(_ isNeedSign: Bool) -> Self {
            self.isNeedSign = isNeedSign
            return self
        }
        
        /// 设置是否需要添加headers
        ///
        /// - Parameter addHeads: headers
        /// - Returns: 对象自己
        @discardableResult
        public func addHeads(_ addHeads: HTTPHeaders) -> Self {
            addHeads.forEach { (key, value) in
                self.addHeads[key] = value
            }
            return self
        }
        
        /// 设置请求类型
        ///
        /// - Parameter requestType: 请求类型
        /// - Returns: 对象自己
        @discardableResult
        public func setRequestType(_ requestType: HTTPMethod) -> Self {
            self.requestType = requestType
            return self
        }
        
        /// 设置CA证书 这个是自定义策略
        /// 因为 trustPolicy/p12Path/p12password 三个是关联的,所以并没有进行单个的链式,而是一次性链式,这样比较统一
        /// - Parameters:
        ///   - trustPolicy: 服务器的认证策略
        ///   - p12Path: p12证书路径
        ///   - p12password: p12证书的密码
        /// - Returns: 对象自己
        @discardableResult
        public func setCertification(trustPolicy: HttpsServerTrustPolicy?, p12Path: String?, p12password: String?) -> Builder {
            self.trustPolicy = trustPolicy
            self.p12Path = p12Path
            self.p12password = p12password
            return self
        }
        
        /// 设置Alamofire的内置的策略
        ///
        /// - Parameter serverTrustPolicyManager: ServerTrustPolicyManager
        /// - Returns: 对象自己
        @discardableResult
        public func setServerTrustPolicyManager(_ serverTrustPolicyManager: ServerTrustPolicyManager?) -> Builder {
            self.serverTrustPolicyManager = serverTrustPolicyManager
            return self
        }
        
        /// 配置构造器
        ///
        /// - Returns: 配置对象
        public func construction() -> HttpConfig {
            return HttpConfig(builder: self)
        }
        
        /// 配置构造器的计算属性
        public var constructor: HttpConfig {
            return HttpConfig(builder: self)
        }
    }
}
