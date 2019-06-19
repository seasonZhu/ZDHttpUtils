//
//  Adapter+HUD.swift
//  HttpUtils
//
//  Created by season on 2019/6/18.
//  Copyright © 2019 season. All rights reserved.
//

import Foundation

public protocol HUDProtocol {
    
    var waitMessage: String? { set get }
    
    var successMessage: String? { set get }
    
    var errorMessage: String? { set get }
    
    func showWait()
    
    func showNetworkStatus(status: NetworkType)
    
    func showError(error: Error?)
    
    func showMessage(message: String)
    
    func clear()
}

extension Adapter {
    public struct HUD: HUDProtocol {
        
        /// 默认
        public static let `default` = HUD()
        
        /// 等待的文字描述
        public var waitMessage: String?
        
        /// 成功的文字描述
        public var successMessage: String?
        
        /// 错误的文字描述
        public var errorMessage: String?
        
        /// 初始化方法
        public init(waitMessage: String? = nil, successMessage: String? = nil, errorMessage: String? = nil) {
            self.waitMessage = waitMessage
            self.successMessage = successMessage
            self.errorMessage = errorMessage
        }
        
        /// 等待界面
        public func showWait() {
            Hud.showWait(message: waitMessage, autoClear: false)
        }
        
        /// 展示网络状态
        ///
        /// - Parameter status: 网络状态
        public func showNetworkStatus(status: NetworkType) {
            Hud.showMessage(message: status.description)
        }
        
        /// 展示错误
        ///
        /// - Parameter error: Error
        public func showError(error: Error? = nil) {
            if let errorMessage = errorMessage {
                Hud.showMessage(message: errorMessage)
            }else {
                Hud.showMessage(message: error.debugDescription)
            }
        }
        
        /// 展示信息
        ///
        /// - Parameter message: 信息
        public func showMessage(message: String) {
            Hud.showMessage(message: message)
        }
        
        /// 清除
        public func clear() {
            Hud.clear()
        }
    }
}
