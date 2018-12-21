//
//  U17Request.swift
//  ZDHttpUtilsDemo
//
//  Created by season on 2018/12/21.
//  Copyright © 2018 season. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

/// U17Request
///
/// - home: 表示一个Api
enum U17Request: HttpRequestConvertible {
    
    /// 首页请求
    case home(_ model: ReflectProtocol)
    
    /// RequestConvertible的具体实现
    
    static let baseUrl = "http://app.u17.com"
    
    var method: HTTPMethod {
        switch self {
        case .home:
            return .post
        }
    }
    
    var encoding: ParameterEncoding {
        switch self {
        case .home:
            return URLEncoding.default
        }
    }
    
    var header: HTTPHeaders? {
        switch self {
        case .home:
            return ["json": "test"]
        }
    }
    
    var api: String {
        switch self {
        case .home:
            return "/v3/appV3_3/ios/phone/comic/boutiqueListNew"
        }
    }
    
    /// URLRequestConvertible的具体实现
    
    func asURLRequest() throws -> URLRequest {
        let url = try U17Request.baseUrl.asURL()
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(api))
        urlRequest.httpMethod = method.rawValue
        
        // 增加自定义的请求头
        if let header = self.header {
            for (key, value) in header {
                urlRequest.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        urlRequest = try encoding.encode(urlRequest, with: parameters)
        
        return urlRequest
    }
    
    ///  这个其实可以集成到协议中 也可以不集成, 这里我没有集成 因为这个值是通过枚举中的model转换而成的
    
    var parameters: Parameters? {
        switch self {
        case .home(let model):
            return model.toDictionary
        }
    }
}

/// 传入的U17Request的模型, 最终会转为字典
struct U17RequestModel: ReflectProtocol {
    var sexType = ""
    var key = ""
    var target = ""
    var version = ""
    var v = ""
    var model = ""
    var device_id = ""
    var time = ""
}
