//
//  Adapter+config.swift
//  HttpUtils
//
//  Created by season on 2019/6/18.
//  Copyright © 2019 season. All rights reserved.
//

import Foundation

public protocol ConfigProtocol {
    var keyPath: String? { get }
    
    var queue: DispatchQueue? { get }
    
    var statusCodes: [Int]? { get }
    
    var contentTypes: [String]? { get }
}

extension Adapter {
    public struct Config: ConfigProtocol {
        
        /// 模型的键值路径
        public let keyPath: String?
        
        /// 回调的线程
        public let queue: DispatchQueue?
        
        /// 响应码
        public let statusCodes: [Int]?
        
        /// 响应类型
        public let contentTypes: [String]?
        
        /// 初始化方法
        public init(keyPath: String? = nil, queue: DispatchQueue? = nil, statusCodes: [Int]? = nil, contentTypes: [String]? = nil) {
            self.keyPath = keyPath
            self.queue = queue
            self.statusCodes = statusCodes
            self.contentTypes = contentTypes
        }
    }
}

