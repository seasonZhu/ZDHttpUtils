//
//  CallbackHandler.swift
//  ZDHttpUtilsDemo
//
//  Created by season on 2018/9/19.
//  Copyright © 2018年 season. All rights reserved.
//

import Foundation
import ObjectMapper

protocol CallbackHandlerProtocol {
    var success: ((Mappable?, [Mappable]?)-> ())? { get set }
    
    var failure: ((Data?, Error?) -> ())? { get set }
    
    var message: ((String?) -> ())? { get set }
    
    var keyPath: String? { get set }
    
    var isArray: Bool { get set }
}


/// 结果回调句柄
public class CallbackHandler<T: Mappable>: CallbackHandlerProtocol {
    
    public var success: ((Mappable?, [Mappable]?)-> ())?
    
    public var failure: ((Data?, Error?) -> ())?
    
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
