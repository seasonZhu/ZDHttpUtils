//
//  CallbackHandler.swift
//  ZDHttpUtilsDemo
//
//  Created by season on 2018/9/19.
//  Copyright © 2018年 season. All rights reserved.
//

import Foundation

/// 请求结果回调
public typealias ResponseResultHandle<T> = (ResponseResult<T>) -> Void

/// 网络请求响应结果
///
/// - success: 响应成功
/// - failure: 响应失败
public enum ResponseResult<T> {
    case success(Success)
    case failure(Failure)
    
    /// 成功的结构
    public struct Success {
        var codableModel: T?
        var data: Data?
        var jsonString: String?
        var httpURLResponse: HTTPURLResponse?
    }
    
    /// 失败的结构体
    public struct Failure {
        var cache: T?
        var data: Data?
        var otherError: HttpUtils.OtherError?
        var error: Error?
        var httpURLResponse: HTTPURLResponse?
    }
}

extension ResponseResult {
    
    /// 返回的模型
    public var model: T? {
        switch self {
        case .success(let success):
            return success.codableModel
        case .failure(let failure):
            return failure.cache
        }
    }
    
    /// 返回的HTTPURLResponse
    public var httpURLResponse: HTTPURLResponse? {
        switch self {
        case .success(let success):
            return success.httpURLResponse
        case .failure(let failure):
            return failure.httpURLResponse
        }
    }
    
    /// 返回的原始数据
    public var data: Data? {
        switch self {
        case .success(let success):
            return success.data
        case .failure(let failure):
            return failure.data
        }
    }
    
    /// 返回的json字符串
    public var jsonString: String? {
        switch self {
        case .success(let success):
            return success.jsonString
        case .failure:
            return nil
        }
    }
    
    /// 返回的错误
    public var error: Error? {
        switch self {
        case .success:
            return nil
        case .failure(let failure):
            return failure.error ?? failure.otherError
        }
    }
}


// MARK: - 上传回调

/// 上传数据流 [文件名: 数据]的字典
public typealias UploadStream = [String: Data]

/// 上传结果的回调,回调的是上传的网址,上传是否成功true表示成功,false表示失败, error和[String: Any]?
public typealias UploadResultCallback = (URL?, Bool, Error?, [String: Any]?) -> Void

/// 上传进度的回调,回调的是上传的网址,上传进度
public typealias UploadProgressCallback = (URL?, Progress) -> Void

/// 上传的回调
public class UploadCallbackHandler {
    /// 初始化方法
    public init() {}
    
    /// 设置回调线程
    /// 如果不进行设置,Alamofire中是往主线程回调的
    /// - Parameter queue: 回调线程
    /// - Returns: 对象自己
    public func setQueue(_ queue: DispatchQueue?) -> Self {
        self.queue = queue
        return self
    }
    
    /// 设置回调进度线程
    /// 如果不进行设置,Alamofire中是往主线程回调的
    /// - Parameter queue: 回调线程
    /// - Returns: 对象自己
    public func setProgressQueue(_ progressQueue: DispatchQueue?) -> Self {
        self.progressQueue = progressQueue
        return self
    }
    
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
    
    /// 上传结果回调属性
    var result: UploadResultCallback?
    
    /// 上传进度回调属性
    var progress: UploadProgressCallback?
    
    /// 回调的线程
    var queue: DispatchQueue?
    
    /// 回调进度的线程
    var progressQueue: DispatchQueue?
}

// MARK: - 下载回调

/// 下载成功结果的回调,回调的是文件临时路径(临时路径一般没有使用),文件保存路径和下载文件的二进制
public typealias DownloadSuccessCallback = (URL?, URL?, Data?) -> Void

/// 下载失败结果的回调,回调的是文件临时数据 文件临时路径(临时路径一般没有使用),Error和statusCode
public typealias DownloadFailureCallback = (Data?, URL?, Error?, Int?) -> Void

/// 下载进度的回调,回调的是下载进度
public typealias DownloadProgressCallback = (Progress) -> Void

/// 下载回调
public class DownloadCallbackHandler {
    /// 初始化方法
    public init() {}
    
    /// 设置回调线程
    /// 如果不进行设置,Alamofire中是往主线程回调的
    /// - Parameter queue: 回调线程
    /// - Returns: 对象自己
    public func setQueue(_ queue: DispatchQueue?) -> Self {
        self.queue = queue
        return self
    }
    
    /// 设置回调进度线程
    /// 如果不进行设置,Alamofire中是往主线程回调的
    /// - Parameter queue: 回调线程
    /// - Returns: 对象自己
    public func setProgressQueue(_ progressQueue: DispatchQueue?) -> Self {
        self.progressQueue = progressQueue
        return self
    }
    
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
    
    /// 回调的线程
    var queue: DispatchQueue?
    
    /// 回调进度的线程
    var progressQueue: DispatchQueue?
}
