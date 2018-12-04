//
//  HttpUrlProtocol.swift
//  ZDHttpUtilsDemo
//
//  Created by season on 2018/9/21.
//  Copyright © 2018年 season. All rights reserved.
//

import Foundation

/// 针对url的配置的协议 有默认实现 可以在扩展中写多个不同的base而针对不同的环境
protocol HttpUrlProtocol {
    static var base: String { get }
}

// MARK: - 默认实现
extension HttpUrlProtocol {
    static var base: String {
        return "http://sun.topray-media.cn"
    }
}
