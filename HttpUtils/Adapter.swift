//
//  Adapter.swift
//  HttpUtils
//
//  Created by season on 2019/6/18.
//  Copyright © 2019 season. All rights reserved.
//

import Foundation

/// 适配器
public struct Adapter {
    
    /// 网络请求响应的配置配置
    public var config: ConfigProtocol
    
    /// 图形界面的配置
    public var hud: HUDProtocol?
    
    /// 过程配置
    public var process: ProcessProtocol
    
    /// 初始化方法
    public init(config: ConfigProtocol = Config(), hud: HUDProtocol? = nil, process: ProcessProtocol = Process()) {
        self.config = config
        self.hud = hud
        self.process = process
    }
}
