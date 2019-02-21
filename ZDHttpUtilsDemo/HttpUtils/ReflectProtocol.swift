//
//  ReflectProtocol.swift
//  ZDHttpUtilsDemo
//
//  Created by season on 2018/11/2.
//  Copyright © 2018 season. All rights reserved.
//

import Foundation

/*
 这个类用于将一个层级的模型映射为字典,主要用于网络请求,将模型转为parameters字典,当然你完全可以使用ObjectMapper的toJSON方法实现.
 不过那样写起来特别的麻烦.这个只用类或者结构体遵守该协议可以调用了.
 注意之前使用这个方法出现过模型有值但是转为空字典的情况,由于使用的都是系统方法而且使用了guard去守护,目前不知道为什么
 */

/// 反射协议
public protocol ReflectProtocol {
    var toDictionary: [String: Any] { get }
    
    func reflectToDictionary() -> [String: Any]
}

// MARK: - 反射协议的默认实现
public extension ReflectProtocol {
    
    /// 反射为字典的计算属性
    var toDictionary: [String: Any] {
        return reflectToDictionary()
    }
    
    /// 反射为字典
    ///
    /// - Returns: 字典
    func reflectToDictionary() -> [String: Any] {
        let mirror = Mirror(reflecting: self)
        var dictionary = [String: Any]()
        for item in mirror.children {
            guard let key = item.label else {
                continue
            }
            
            let value = unwrap(any: item.value)
            if String(describing: value) == "nil" {
                continue
            }
            
            dictionary[key] = value
        }
        
        return dictionary
    }
    
    /// optional解包
    ///
    /// - Parameter any: Any
    /// - Returns: 解包后的Any
    private func unwrap(any: Any) -> Any {
        let mirror = Mirror(reflecting: any)
        
        guard let type = mirror.displayStyle else { return any }
        
        if type != .optional { return any }
        
        if mirror.children.count == 0 { return any }
        
        let (_, some) = mirror.children.first!
        
        return some
    }
}
