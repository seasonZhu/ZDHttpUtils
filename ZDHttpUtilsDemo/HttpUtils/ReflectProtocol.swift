//
//  ReflectProtocol.swift
//  ZDHttpUtilsDemo
//
//  Created by season on 2018/11/2.
//  Copyright © 2018 season. All rights reserved.
//

import Foundation

/*
 这个类用于将模型映射为字典,当然你完全可以使用ObjectMapper的toJSON方法实现.
 不过那样写起来特别的麻烦.这个只用类或者结构体继承就可以调用了.
 注意之前使用这个方法的使用出现过模型有值但是转为空字典的情况,由于使用的都是系统方法而且使用了guard去守护,目前不知道为什么
 */
///
protocol ReflectProtocol {
    func reflectToDictory() -> [String: Any]
}

extension ReflectProtocol {
    func reflectToDictory() -> [String: Any] {
        let mirror = Mirror.init(reflecting: self)
        var dictory = [String: Any]()
        for item in mirror.children {
            guard let key = item.label else {
                continue
            }
            
            let value = unwrap(any: item.value)
            if String(describing: value) == "nil" {
                continue
            }
            
            dictory[key] = value
        }
        
        return dictory
    }
    
    private func unwrap(any: Any) -> Any {
        let mi = Mirror(reflecting: any)
        
        guard let type = mi.displayStyle else { return any }
        
        if type != .optional { return any }
        
        if mi.children.count == 0 { return any }
        
        let (_, some) = mi.children.first!
        return some
    }
}
