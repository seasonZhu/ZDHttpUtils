//
//  NetworkListener.swift
//  ZDHttpUtilsDemo
//
//  Created by season on 2018/9/17.
//  Copyright © 2018年 season. All rights reserved.
//

import Foundation
import Alamofire

public enum NetworkType: CustomStringConvertible {
    
    case
    unknow,
    notReachable,
    wifi,
    mobile
    
    public var description: String {
        switch self {
        case .unknow: return "未知"
        case .notReachable: return "没有网络"
        case .wifi: return "wifi网络"
        case .mobile: return "手机网络"
        }
    }
}

extension NetworkType {
    //MARK:- 获取网络状态
    fileprivate static func getType(by reachabilityStatus: NetworkReachabilityManager.NetworkReachabilityStatus) -> NetworkType {
        var status: NetworkType
        switch reachabilityStatus {
        case .unknown:
            status = .unknow
        case .notReachable:
            status = .notReachable
        case .reachable(NetworkReachabilityManager.ConnectionType.ethernetOrWiFi):
            status = .wifi
        case .reachable(NetworkReachabilityManager.ConnectionType.wwan):
            status = .mobile
        }
        return status
    }
}

class NetworkListener {
    
    //MARK:- 属性设置
    
    //  监听管理器
    private let manager = NetworkReachabilityManager()!
    
    //  是否在监听
    private var isListening = false
    
    //  单例
    static let shared = NetworkListener()
    private init() {}
    
    //MARK:- 监听状态
    public var isReachable: Bool {
        return manager.isReachable
    }
    
    public var isMobile: Bool {
        return manager.isReachableOnWWAN
    }
    
    public var isWifi: Bool {
        return manager.isReachableOnEthernetOrWiFi
    }
    
    //MARK:- 开始监听
    public func startListen() {
        if isListening { return }
        
        isListening = manager.startListening()
        //LogUtils.logSimple(isListening ? "开始监听成功" : "开始监听失败")
    }
    
    //MARK:- 结束监听
    public func stopListen() {
        if isListening { return }
        
        manager.stopListening()
        //LogUtils.logSimple(isListening ? "结束监听成功" : "结束监听失败")
    }
    
    //MARK:- 获取监听的网络状态
    public var  status: NetworkType {
        let reachabilityStatus = manager.networkReachabilityStatus
        return NetworkType.getType(by: reachabilityStatus)
    }
    
    //MARK:- 刷新状态
    @discardableResult
    public func refreshStatus() -> NetworkType {
        let reachabilityStatus = manager.networkReachabilityStatus
        let newStatus = NetworkType.getType(by: reachabilityStatus)
        return newStatus
    }
    
    //MARK:- 闭包形式的状态回调
    /// 获取网络状态,一旦改变就会进行回调,可以说是全局的监听
    ///
    /// - Parameter callback: 回调
    public func listenStatus(_ callback: @escaping (_ type: NetworkType) -> ()) {
        
        manager.listener = { status in
            let status = NetworkType.getType(by: status)
            callback(status)
        }
        startListen()
    }
}
