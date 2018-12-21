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
    
    /// api
    var api: String { get }
}

/// Http请求转换器 (协议合成) 该协议给枚举使用 详细例子请看U17Request
public typealias HttpRequestConvertible = RequestConvertible & URLRequestConvertible
