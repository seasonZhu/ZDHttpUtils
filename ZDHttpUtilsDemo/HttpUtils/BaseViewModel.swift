//
//  BaseViewModel.swift
//  ZDHttpUtilsDemo
//
//  Created by season on 2018/9/21.
//  Copyright © 2018年 season. All rights reserved.
//

import Foundation

class BaseViewModel {
    
    /// 拦截句柄 可以子类中进行重写
    var interceptHandle: InterceptHandle {
        return InterceptHandle.Builder().constructor
    }
    
    deinit {
        print("\(String(describing: type(of: self))) 销毁了")
    }
}

extension BaseViewModel {
    /// 如果想使用ViewModel的类方法,那么需要配置化InterceptHandle的静态变量 😁
    static let defaultInterceptHandle = InterceptHandle.Builder().constructor
}
