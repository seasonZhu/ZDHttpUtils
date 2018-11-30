//
//  CallbackHandler.swift
//  ZDHttpUtilsDemo
//
//  Created by season on 2018/9/19.
//  Copyright © 2018年 season. All rights reserved.
//

import Foundation
import ObjectMapper

/// 回调协议
protocol CallbackHandlerProtocol {
    
    associatedtype M: Mappable
    
    var success: ((M?, [M]?, HTTPURLResponse?)-> ())? { get set }
    
    var failure: ((Data?, Error?, HTTPURLResponse?) -> ())? { get set }
    
    var message: ((String?) -> ())? { get set }
    
    var keyPath: String? { get set }
    
    var isArray: Bool { get set }
}


/// 结果回调句柄
public class CallbackHandler<T: Mappable>: CallbackHandlerProtocol {
    
    typealias M = T
    
    public var success: ((T?, [T]?, HTTPURLResponse?) -> ())?
    
    public var failure: ((Data?, Error?, HTTPURLResponse?) -> ())?
    
    public var message: ((String?) -> ())?
    
    public var keyPath: String?
    
    public var isArray: Bool = false
    
    public func setKeyPath(_ keyPath: String) -> Self {
        self.keyPath = keyPath
        return self
    }
    
    public func setIsArray(_ isArray: Bool) -> Self {
        self.isArray = isArray
        return self
    }
}
