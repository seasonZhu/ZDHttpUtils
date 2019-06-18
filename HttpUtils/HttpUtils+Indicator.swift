//
//  HttpUtils+Indicator.swift
//  HttpUtils
//
//  Created by season on 2019/6/18.
//  Copyright © 2019 season. All rights reserved.
//

import Foundation

//MARK:- 系统状态栏上的网络请求转圈
extension HttpUtils {
    
    /// 菊花转开始
    static func indicatorRun() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    /// 菊花转停止
    static func indicatorStop() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
