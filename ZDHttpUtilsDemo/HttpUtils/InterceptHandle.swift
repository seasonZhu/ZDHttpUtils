//
//  InterceptHandle.swift
//  ZDHttpUtilsDemo
//
//  Created by season on 2018/9/19.
//  Copyright © 2018年 season. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import SwiftyJSON

protocol InterceptHandleProtocol: class {
    
    func onNetworkIsNotReachableHandler(type: NetworkType)
    
    func onBeforeHandler(method: HTTPMethod, url: String, parameters: Parameters?) -> Bool
    
    func onAfterHandler(url: String, response: DataResponse<JSON>?)
    
    func onDataInterceptHandler(data: Data?) -> Bool
    
    func onResponseErrorHandler(error: Error?)
    
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
    
    /// 是否显示Loading
    private var isShowLoading = false
    
    ///  loading的文字
    private var loadingText: String?
    
    ///  是否进行吐司
    private var isShowToast = false
        
    ///  请求的tag
    private var tag: String?
    
    //MARK:- 构造器
    
    /// 便利构造函数
    public convenience init() {
        self.init(isBeforeHandler: false, isAfterHandler: false, isDataIntercept: false, isShowLoading: false, loadingText: nil, isShowToast: true, tag: nil)
    }
    
    /// 如果需要进行配置 请使用这个
    init(isBeforeHandler: Bool = false,
         isAfterHandler: Bool = false,
         isDataIntercept: Bool = false,
         isShowLoading: Bool = false,
         loadingText: String? = nil,
         isShowToast: Bool = true,
         tag: String? = nil) {
        
        self.isBeforeHandler = isBeforeHandler
        self.isAfterHandler = isAfterHandler
        self.isDataIntercept = isDataIntercept
        self.isShowLoading = isShowLoading
        self.loadingText = loadingText
        self.isShowToast = isShowToast
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
    func onBeforeHandler(method: HTTPMethod, url: String, parameters: Parameters?) -> Bool {
        if isShowLoading && !isBeforeHandler {
            if let text = loadingText {
                //带文字的菊花转
            } else {
                //不带文字的菊花转
            }
        }
        
        //  打印请求API
        #if DEBUG
        print("HttpUtils ## API Request ## \(method) ## \(url) ## params=\(String(describing: parameters))")
        #endif
        
        return isBeforeHandler
    }
    
    //MARK:- 后置拦截
    func onAfterHandler(url: String, response: DataResponse<JSON>?) {
        if isShowLoading {
            //  隐藏菊花转
        }
        
        if isAfterHandler {
            return
        }
        
        #if DEBUG
        print("HttpUtils ## API Response ## \(String(describing: url)) ## data=\(String(describing: response))")
        #endif
    }
    
    //MARK:- 数据拦截
    func onDataInterceptHandler(data: Data?) -> Bool {
        
        guard let unwrapedData = data,
            let JSONDict = try? JSONSerialization.jsonObject(with: unwrapedData, options:[]),
            let dict = JSONDict as? [String: Any] else {
            return isDataIntercept
        }
        
        if let code = dict[ResponseKey.share.code] as? Int {
            //  通过状态码进行 登录过期 账号被挤 等操作
            if code == 0 {
                showToast("网络请求成功了")
            }
        }
        
        return isDataIntercept
    }
    
    //MARK:- 响应结果拦截 主要针对失败
    func onResponseErrorHandler(error: Error?) {
        if isShowToast, let _ = error {
            showToast("网络请求失败")
        }
    }
    
    //MARK:- 链式编程
    
    ///  是否展示吐司
    func setIsShowToast(_ isShowToast: Bool) -> Self {
        self.isShowToast = isShowToast
        return self
    }
    
    /// 设置请求的Tag
    func setTag(tag: String?) -> Self{
        self.tag = tag
        return self
    }
}

//MARK:- 配置化构造方法
extension InterceptHandle {
    
    //MARK:- 配置化构造器
    private convenience init(builder: Builder) {
        self.init(isBeforeHandler: builder.isBeforeHandler,
                  isAfterHandler: builder.isAfterHandler,
                  isDataIntercept: builder.isDataIntercept,
                  isShowLoading: builder.isShowLoading,
                  loadingText: builder.loadingText,
                  isShowToast: builder.isShowToast,
                  tag: builder.tag)
    }
    
    //MARK:- 配置化文件
    class Builder {
        ///  是否进行前置拦截, 默认是false 不进行前置拦截,可配置
        var isBeforeHandler = false
        
        /// 是否进行后置拦截,默认是false,不进行后置拦截,可配置,即请求完成后都进行ApiResponse的打印
        var isAfterHandler = false
        
        /// 是否进行获取到的数据拦截,默认是false,不进行数据拦截,可配置,即请求到的数据都进行第一次的处理json
        var isDataIntercept = false
        
        /// 是否显示Loading
        var isShowLoading = false
        
        ///  loading的文字
        var loadingText: String?
        
        ///  是否进行吐司
        var isShowToast = false
        
        ///  请求的tag
        var tag: String?
        
        //MARK:- 链式编程
        func setIsDataIntercept(_ isDataIntercept: Bool) -> Self {
            self.isDataIntercept = isDataIntercept
            return self
        }
        
        func setIsShowLoading(_ isShowLoading: Bool) -> Self {
            self.isShowLoading = isShowLoading
            return self
        }
        
        func setLoadingText(_ loadingText: String?) -> Self {
            self.loadingText = loadingText
            return self
        }
        
        func setIsBeforeHandler(_ isBeforeHandler: Bool) -> Self {
            self.isBeforeHandler = isBeforeHandler
            return self
        }
        
        func setIsAfterHandler(_ isAfterHandler: Bool) -> Self {
            self.isAfterHandler = isAfterHandler
            return self
        }
        
        ///  是否展示吐司
        func setIsShowToast(_ isShowToast: Bool) -> Self {
            self.isShowToast = isShowToast
            return self
        }
        
        /// 设置请求的Tag
        func setTag(tag: String?) -> Self{
            self.tag = tag
            return self
        }
        
        //MARK:- 两种构造器方法
        func construction() -> InterceptHandle {
            return InterceptHandle(builder: self)
        }
        
        var constructor: InterceptHandle {
            return InterceptHandle(builder: self)
        }
    }
    
}
