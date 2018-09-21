//
//  HttpUrlProtocol.swift
//  ZDHttpUtilsDemo
//
//  Created by season on 2018/9/21.
//  Copyright © 2018年 season. All rights reserved.
//

import Foundation

/// 针对url的配置的协议 有默认实现
protocol HttpUrlProtocol {
    static var baseUrl: String { get }
}

extension HttpUrlProtocol {
    static var baseUrl: String {
        return "http://sun.topray-media.cn"
    }
}
