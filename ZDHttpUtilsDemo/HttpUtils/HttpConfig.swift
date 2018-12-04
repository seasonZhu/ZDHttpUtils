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
    
    //MARK:- 配置构造器
    private init(builder: Builder) {
        self.timeout = builder.timeout
        self.isNeedSign = builder.isNeedSign
        self.addHeads = builder.addHeads
        self.requestType = builder.requestType
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
