//
//  Adapter+Process.swift
//  HttpUtils
//
//  Created by season on 2019/6/18.
//  Copyright © 2019 season. All rights reserved.
//

import Foundation

public protocol ProcessProtocol {
    
    var isNotReachableHandler: Bool { get }
    
    var isBeforeHandler: Bool { get }
    
    var isAfterHandler: Bool { get }
    
    var isUseCache: Bool { get }
}

extension Adapter {
    public struct Process: ProcessProtocol {
        
        /// 是否拦截没有网络
        public var isNotReachableHandler: Bool
        
        /// 是否进行请求的前置拦截
        public var isBeforeHandler: Bool
        
        /// 是否进行请求完成 响应回调之前的拦截
        public var isAfterHandler: Bool
        
        /// 是否使用缓存策略
        public var isUseCache: Bool
        
        /// 初始化方法
        public init(isNotReachableHandler: Bool = true, isBeforeHandler: Bool = false, isAfterHandler: Bool = false, isUseCache: Bool = true) {
            self.isNotReachableHandler = isNotReachableHandler
            self.isBeforeHandler = isBeforeHandler
            self.isAfterHandler = isAfterHandler
            self.isUseCache = isUseCache
        }
    }
}
