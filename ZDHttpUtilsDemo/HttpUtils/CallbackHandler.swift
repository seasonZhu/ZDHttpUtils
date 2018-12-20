//
//  CallbackHandler.swift
//  ZDHttpUtilsDemo
//
//  Created by season on 2018/9/19.
//  Copyright © 2018年 season. All rights reserved.
//

import Foundation
import ObjectMapper

/// 基本请求回调协议

/// 请求响应成功的回调, 回调的结果是遵守Mappable协议的模型,模型数组,响应的原始数据,响应原始数据的json字符串,以及HTTPURLResponse
public typealias ResponseSuccessCallback<MODEL: Mappable> = (MODEL?, [MODEL]?, Data?, String?, HTTPURLResponse?) -> ()

/// 请求响应失败的回调,回调的结果是响应的原始数据,Error,以及HTTPURLResponse
public typealias ResponseFailureCallback = (Data?, Error?, HTTPURLResponse?) -> ()

/// 请求响应的信息回调,回调的是一个错误枚举,返回错误类型
public typealias ResponseMessageCallback = (MessageTyep?) -> ()

/// 响应回调的协议
protocol CallbackHandlerProtocol {
    
    associatedtype M: Mappable
    
    var success: ResponseSuccessCallback<M>? { get set }
    
    var failure: ResponseFailureCallback? { get set }
    
    var message: ResponseMessageCallback? { get set }
    
    var keyPath: String? { get set }
    
    var isArray: Bool { get set }
}

// MARK: - 请求回调

/// 基本请求回调
public class CallbackHandler<T: Mappable>: CallbackHandlerProtocol {
    
    typealias M = T

    /// 初始化方法
    public init() {}
    
    /// 设置直达路径,需要在两个on方法前进行设置,否则结果会有误
    ///
    /// - Parameter keyPath: 直达路径
    /// - Returns: 对象自己
    @discardableResult
    public func setKeyPath(_ keyPath: String) -> Self {
        self.keyPath = keyPath
        return self
    }
    
    /// 获取的是否是模型数组,需要在两个on方法前进行设置,否则结果会有误
    /// 由于ObjectMapper解析的原因,必须告诉它你解析的是模型数组还是模型
    /// - Parameter isArray: 是否是模型数组
    /// - Returns: 对象自己
    @discardableResult
    public func setIsArray(_ isArray: Bool) -> Self {
        self.isArray = isArray
        return self
    }
    
    /// 成功的回调
    ///
    /// - Parameter callback: 回调的数据
    /// - Returns: 对象自己
    @discardableResult
    public func onSuccess(_ success: ResponseSuccessCallback<T>?) -> Self {
        self.success = success
        return self
    }
    
    /// 失败的回调
    ///
    /// - Parameter callback: 回调数据
    /// - Returns: 对象自己
    @discardableResult
    public func onFailure(_ failure: ResponseFailureCallback?)  -> Self {
        self.failure = failure
        return self
    }
    
    /// 信息的回调
    ///
    /// - Parameter message: 回调信息
    /// - Returns: 对象自己
    public func onMessage(_ message: ResponseMessageCallback?) -> Self {
        self.message = message
        return self
    }
    
    /// 成功回调属性
    var success: ResponseSuccessCallback<T>?
    
    /// 失败回调属性
    var failure: ResponseFailureCallback?
    
    /// 信息
    var message: ResponseMessageCallback?
    
    /// 路径
    var keyPath: String?
    
    /// 是否是数组
    var isArray: Bool = false
}

// MARK: - 上传回调

/// 上传数据流 [文件名: 数据]的字典
public typealias UploadStream = [String: Data]

/// 上传结果的回调,回调的是上传的网址,上传是否成功true表示成功,false表示失败, error和[String: Any]?
public typealias UploadResultCallback = (URL?, Bool, Error?, [String: Any]?) -> ()

/// 上传进度的回调,回调的是上传的网址,上传进度
public typealias UploadProgressCallback = (URL?, Progress) -> ()

/// 上传的回调
public class UploadCallbackHandler {
    /// 初始化方法
    public init() {}
    
    /// 上传结果的回调
    ///
    /// - Parameter callback: 回调的数据
    /// - Returns: 对象自己
    @discardableResult
    public func onUploadResult(_ callback: @escaping UploadResultCallback) -> Self {
        result = callback
        return self
    }
    
    /// 上传进度的回调
    ///
    /// - Parameter callback: 回调数据
    /// - Returns: 对象自己
    public func onUploadProgress(_ callback: @escaping UploadProgressCallback) -> Self {
        progress = callback
        return self
    }
    
    /// 信息的回调
    ///
    /// - Parameter message: 回调信息
    /// - Returns: 对象自己
    public func onMessage(_ message: ResponseMessageCallback?) -> Self {
        self.message = message
        return self
    }
    
    /// 上传结果回调属性
    var result: UploadResultCallback?
    
    /// 上传进度回调属性
    var progress: UploadProgressCallback?
    
    /// 信息
    var message: ResponseMessageCallback?
}

// MARK: - 下载回调

/// 下载成功结果的回调,回调的是文件临时路径(临时路径一般没有使用),文件保存路径和下载文件的二进制
public typealias DownloadSuccessCallback = (URL?, URL?, Data?) -> ()

/// 下载失败结果的回调,回调的是文件临时数据 文件临时路径(临时路径一般没有使用),Error和statusCode
public typealias DownloadFailureCallback = (Data?, URL?, Error?, Int?) -> ()

/// 下载进度的回调,回调的是下载进度
public typealias DownloadProgressCallback = (Progress) -> ()

/// 下载回调
public class DownloadCallbackHandler {
    /// 初始化方法
    public init() {}
    
    /// 成功的回调
    ///
    /// - Parameter callback: 回调的数据
    /// - Returns: 对象自己
    @discardableResult
    public func onSuccess(_ callback: @escaping DownloadSuccessCallback) -> Self {
        success = callback
        return self
    }
    
    /// 失败的回调
    ///
    /// - Parameter callback: 回调数据
    /// - Returns: 对象自己
    public func onFailure(_ callback: @escaping DownloadFailureCallback) -> Self {
        failure = callback
        return self
    }
    
    /// 信息的回调
    ///
    /// - Parameter message: 回调信息
    /// - Returns: 对象自己
    public func onMessage(_ message: ResponseMessageCallback?) -> Self {
        self.message = message
        return self
    }
    
    /// 下载进度的回调
    ///
    /// - Parameter callback: 回调数据
    /// - Returns: 对象自己
    public func onDownloadProgress(_ callback: @escaping DownloadProgressCallback) -> Self {
        progress = callback
        return self
    }
    
    /// 成功回调属性
    var success: DownloadSuccessCallback?
    
    /// 失败回调属性
    var failure: DownloadFailureCallback?
    
    /// 下载进度回调属性
    var progress: DownloadProgressCallback?
    
    /// 信息
    var message: ResponseMessageCallback?
}

