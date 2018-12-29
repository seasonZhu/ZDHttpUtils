//
//  HttpRequestConvertible.swift
//  ZDHttpUtilsDemo
//
//  Created by season on 2018/12/21.
//  Copyright © 2018 season. All rights reserved.
//

import Foundation
import Alamofire

/// 请求转换器
public protocol RequestConvertible {
    
    /// baseUrl
    static var baseUrl: String { get }
    
    /// 请求方式
    var method: HTTPMethod { get }
    
    /// 编码方式
    var encoding: ParameterEncoding { get }
    
    /// 请求头
    var header: HTTPHeaders? { get }
    
    /// api
    var api: String { get }
    
    /// 认证策略
    var trustPolicy: HttpsServerTrustPolicy? { get }
    
    /// p12文件
    var p12File: P12File? { get }
}

/// Http请求转换器 (协议合成) 该协议必须由枚举遵守 详细例子请看U17Request
public typealias HttpRequestConvertible = RequestConvertible & URLRequestConvertible

/// p12文件
public struct P12File {
    public let path: String
    public let password: String
}
