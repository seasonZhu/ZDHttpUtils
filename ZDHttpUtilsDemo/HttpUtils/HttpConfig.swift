//
//  HttpConfig.swift
//  ZDHttpUtilsDemo
//
//  Created by season on 2018/9/19.
//  Copyright © 2018年 season. All rights reserved.
//

import UIKit
import Toast_Swift

/// 网络请求配置项
class HttpConfig {
    
    //MARK:- 配置可以根据需求进行增删
    
    /// 超时配置
    let timeOut: TimeInterval
    
    /// 是否需要加密签名的配置
    let isNeedSign: Bool
    
    //MARK:- 配置构造器
    private init(builder: Builder) {
        self.timeOut = builder.timeOut
        self.isNeedSign = builder.isNeedSign
    }
    
    /// 详细构造器
    class Builder {
        
        //  超时时间
        var timeOut: TimeInterval = 10
        
        //  是否需要签名
        var isNeedSign = false
        
        func setTimeOut(_ timeOut: TimeInterval) -> Self {
            self.timeOut = timeOut
            return self
        }
        
        func isNeedSign(_ isNeedSign: Bool) -> Self {
            self.isNeedSign = isNeedSign
            return self
        }
        
        func construction() -> HttpConfig {
            return HttpConfig(builder: self)
        }
        
        var constructor: HttpConfig {
            return HttpConfig(builder: self)
        }
    }
}


//MARK:- 吐司显示
func showToast(_ message: String) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return
    }
    appDelegate.window?.rootViewController?.view.makeToast(message)
}
