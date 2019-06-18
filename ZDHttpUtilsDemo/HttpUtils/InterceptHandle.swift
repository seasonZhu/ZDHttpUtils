//
//  InterceptHandle.swift
//  ZDHttpUtilsDemo
//
//  Created by season on 2018/9/19.
//  Copyright © 2018年 season. All rights reserved.
//

import Foundation
import Alamofire

/// 拦截回调协议
protocol InterceptHandleProtocol {
    
    func onNetworkIsNotReachableHandler(type: NetworkType)
    
    func onBeforeHandler(method: HTTPMethod, url: String, parameters: Any) -> Bool
    
    func onAfterHandler(url: String, response: DataResponse<JSON>?)
    
    func onDataInterceptHandler(data: Data?, httpResponse: HTTPURLResponse?) -> Bool
    
    func onValidationHandler(requst: DataRequest) -> DataRequest
    
    func onResponseErrorHandler(error: Error?)
    
    func onCacheHandler() -> Bool
    
}

/// 拦截句柄
public class InterceptHandle: InterceptHandleProtocol {
    
    //MARK:- 属性设置
    
    ///  是否进行前置拦截, 默认是false 不进行前置拦截,可配置
    private var isBeforeHandler = false
    
    /// 是否进行后置拦截,默认是false,不进行后置拦截,可配置,即请求完成后都进行ApiResponse的打印
    private var isAfterHandler = false
    
    /// 是否进行获取到的数据拦截,默认是false,不进行数据拦截,可配置,即请求到的数据都进行第一次的处理json
    private var isDataIntercept = false
    
    /// 是否进行acceptableStatusCodes和acceptableContentTypes的校验
    private var isValidation = false
    
    /// 是否显示Loading
    private var isShowLoading = false
    
    ///  loading的文字
    private var loadingText: String?
    
    ///  是否进行吐司
    private var isShowToast = false
    
    ///  是否进行缓存设置
    private var isCache = true
        
    ///  请求的tag
    private var tag: String?
    
    ///  默认的状态码校验
    private let defaultStatusCodes = Array(200..<300)
    
    ///  默认的ContentTypes校验
    private let defaultContentTypes = ["*/*"]
    
    ///  设置的状态码校验
    private var statusCodes: [Int]?
    
    ///  设置的ContentTypes校验
    private var contentTypes: [String]?
    
    //MARK:- 构造器
    
    /// 便利构造函数
    public convenience init() {
        self.init(isBeforeHandler: false, isAfterHandler: false, isDataIntercept: false, isValidation: false, isShowLoading: true, isShowToast: true, isCache: true)
    }
    
    
    /// 自定义拦截配置初始化
    ///
    /// - Parameters:
    ///   - isBeforeHandler: 前置拦截
    ///   - isAfterHandler: 后置拦截
    ///   - isDataIntercept: 数据拦截
    ///   - isShowLoading: 是否显示菊花转
    ///   - loadingText: 菊花转的时候是否显示文字
    ///   - isShowToast: 是否启用toast
    ///   - isCache: 是否缓存json数据
    ///   - tag: 标签
    public init(isBeforeHandler: Bool = false,
                isAfterHandler: Bool = false,
                isDataIntercept: Bool = false,
                isValidation: Bool = false,
                isShowLoading: Bool = false,
                loadingText: String? = nil,
                isShowToast: Bool = true,
                isCache: Bool = true,
                statusCodes: [Int]? = nil,
                contentTypes: [String]? = nil,
                tag: String? = nil) {
        
        self.isBeforeHandler = isBeforeHandler
        self.isAfterHandler = isAfterHandler
        self.isDataIntercept = isDataIntercept
        self.isValidation = isValidation
        self.isShowLoading = isShowLoading
        self.loadingText = loadingText
        self.isShowToast = isShowToast
        self.isCache = isCache
        self.statusCodes = statusCodes
        self.contentTypes = contentTypes
        self.tag = tag
    }
    
    //MARK:- 协议
    
    //MARK:- 没有网络的拦截
    func onNetworkIsNotReachableHandler(type: NetworkType) {
        if isShowToast {
            showToast(type.description)
        }
    }
    
    //MARK:- 前置拦截
    func onBeforeHandler(method: HTTPMethod, url: String, parameters: Any) -> Bool {
        if isShowLoading && !isBeforeHandler {
            //let data: ActivityData
            if let _ = loadingText {
                //data = ActivityData(message: text, type: .lineSpinFadeLoader, textColor: nil)
                //带文字的菊花转
            } else {
                //不带文字的菊花转
                //data = ActivityData(message: nil, type: .lineSpinFadeLoader, textColor: nil)
            }
            //NVActivityIndicatorPresenter.sharedInstance.startAnimating(data, nil)
            showActivity()
        }
        
        //  打印请求API
        print("HttpUtils ## API Request ## \(method) ## \(url) ## parameters = \(String(describing: parameters))")
        
        return isBeforeHandler
    }
    
    //MARK:- 后置拦截
    func onAfterHandler(url: String, response: DataResponse<JSON>?) {
        if isShowLoading {
            //  隐藏菊花转
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                //NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
                hideActivity()
            }
        }
        
        if isAfterHandler {
            return
        }
        
        print("HttpUtils ## API Response ## \(String(describing: url)) ## data = \(String(describing: response))")
        
    }
    
    //MARK:- 数据拦截
    func onDataInterceptHandler(data: Data?, httpResponse: HTTPURLResponse?) -> Bool {
        
        //  协议层的statusCode处理
        guard let response = httpResponse else {
            return isDataIntercept
        }
        
        if !SuccessCodes.nums.contains(response.statusCode) && isValidation {
            //  statusCode -> 转描述
        }
        
        //  业务层的处理
        guard let unwrapedData = data,
            let JSONDict = try? JSONSerialization.jsonObject(with: unwrapedData, options:[]),
            var dict = JSONDict as? [String: Any] else {
            return isDataIntercept
        }
        
        if let code = dict[MappingTable.share.code] as? Int,
            !SuccessCodes.nums.contains(code),
            let msg = dict[MappingTable.share.message] as? String {
            showToast(msg)
        } else if let status = dict[MappingTable.share.status] as? String,
            !SuccessCodes.strings.contains(status),
            let msg = dict[MappingTable.share.message] as? String {
            showToast(msg)
        }
        
        return isDataIntercept
    }
    
    //MARK:- statusCode与contentTypes校验
    func onValidationHandler(requst: DataRequest) -> DataRequest {
        if isValidation {
            return requst.validate(statusCode: statusCodes ?? defaultStatusCodes).validate(contentType: contentTypes ?? defaultContentTypes)
        }else{
            return requst
        }
    }
    
    //MARK:- 缓存配置
    func onCacheHandler() -> Bool {
        return isCache
    }
    
    //MARK:- 响应结果拦截 主要针对失败
    func onResponseErrorHandler(error: Error?) {
        if isShowToast, let _ = error {
            showToast(error.debugDescription)
        }
    }
}

//MARK:- 配置化构造方法
extension InterceptHandle {
    
    //MARK:- 配置化构造器
    private convenience init(builder: Builder) {
        self.init(isBeforeHandler: builder.isBeforeHandler,
                  isAfterHandler: builder.isAfterHandler,
                  isDataIntercept: builder.isDataIntercept,
                  isValidation: builder.isValidation,
                  isShowLoading: builder.isShowLoading,
                  loadingText: builder.loadingText,
                  isShowToast: builder.isShowToast,
                  isCache: builder.isCache,
                  statusCodes: builder.statusCodes,
                  contentTypes: builder.contentTypes,
                  tag: builder.tag)
    }
    
    //MARK:- 配置化文件
    public class Builder {
        ///  是否进行前置拦截, 默认是false 不进行前置拦截,可配置
        var isBeforeHandler = false
        
        /// 是否进行后置拦截,默认是false,不进行后置拦截,可配置,即请求完成后都进行ApiResponse的打印
        var isAfterHandler = false
        
        /// 是否进行获取到的数据拦截,默认是false,不进行数据拦截,可配置,即请求到的数据都进行第一次的处理json
        var isDataIntercept = false
        
        /// 是否进行acceptableStatusCodes和acceptableContentTypes的校验
        var isValidation = false
        
        /// 是否显示Loading
        var isShowLoading = false
        
        ///  loading的文字
        var loadingText: String?
        
        ///  是否进行吐司
        var isShowToast = false
        
        ///  是否进行缓存设置
        var isCache = true
        
        ///  请求的tag
        var tag: String?
        
        ///  设置的状态码校验
        var statusCodes: [Int]?
        
        ///  设置的ContentTypes校验
        var contentTypes: [String]?
        
        //MARK:- 链式编程
        
        ///  是否数据拦截
        @discardableResult
        public func setIsDataIntercept(_ isDataIntercept: Bool) -> Self {
            self.isDataIntercept = isDataIntercept
            return self
        }
        
        ///  是否显示loading画面
        @discardableResult
        public func setIsShowLoading(_ isShowLoading: Bool) -> Self {
            self.isShowLoading = isShowLoading
            return self
        }
        
        ///  是否显示loading文字.必须使用Hud
        @discardableResult
        public func setLoadingText(_ loadingText: String?) -> Self {
            self.loadingText = loadingText
            return self
        }
        
        ///  是否前置拦截
        @discardableResult
        public func setIsBeforeHandler(_ isBeforeHandler: Bool) -> Self {
            self.isBeforeHandler = isBeforeHandler
            return self
        }
        
        ///  是否后置拦截
        @discardableResult
        public func setIsAfterHandler(_ isAfterHandler: Bool) -> Self {
            self.isAfterHandler = isAfterHandler
            return self
        }
        
        ///  是否进行acceptableStatusCodes和acceptableContentTypes的校验
        @discardableResult
        public func setIsValidation(_ isValidation: Bool) -> Self {
            self.isValidation = isValidation
            return self
        }
        
        ///  是否展示吐司
        @discardableResult
        public func setIsShowToast(_ isShowToast: Bool) -> Self {
            self.isShowToast = isShowToast
            return self
        }
        
        ///  是否进行缓存配置
        @discardableResult
        public func setIsCache(_ isCache: Bool) -> Self {
            self.isCache = isCache
            return self
        }
        
        /// 设置请求的Tag
        @discardableResult
        public func setTag(tag: String?) -> Self{
            self.tag = tag
            return self
        }
        
        ///  设置的状态码校验
        @discardableResult
        public func setStatusCodes(statusCodes: [Int]?) -> Self{
            self.statusCodes = statusCodes
            return self
        }
        
        ///  设置的ContentTypes校验
        @discardableResult
        public func setContentTypes(contentTypes: [String]?) -> Self{
            self.contentTypes = contentTypes
            return self
        }
        
        //MARK:- 两种构造器方法
        
        /// 构造器
        ///
        /// - Returns: 拦截器
        public func construction() -> InterceptHandle {
            return InterceptHandle(builder: self)
        }
        
        /// 拦截器计算属性
        public var constructor: InterceptHandle {
            return InterceptHandle(builder: self)
        }
    }
    
}

extension InterceptHandle {
    
    /// 协议层的成功范围
    struct SuccessCodes {
        static let nums = 200..<300
        static let strings = "200"..<"300"
    }
}
