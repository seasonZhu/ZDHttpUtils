//
//  HttpUtils.swift
//  ZDHttpUtilsDemo
//
//  Created by season on 2018/9/19.
//  Copyright © 2018年 season. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import Alamofire_SwiftyJSON
import ObjectMapper

public class HttpUtils {
    public static func request<T: Mappable>(sessionManage: SessionManager = SessionManager.default,
                                            method: HTTPMethod,
                                            url:String,
                                            parameters: Parameters? = nil,
                                            headers: HTTPHeaders? = nil,
                                            interceptHandle: InterceptHandle,
                                            callbackHandler: CallbackHandler<T>) {
        
        //  前置拦截 如果没有前置拦截,打印请求Api
        if interceptHandle.onBeforeHandler(method: method, url: url, parameters: parameters) {
            print("前置拦截,无法进行网络请求")
            return
        }
        
        //  检查网络
        guard NetworkListener.shared.isReachable else {
            print("没有网络!")
            
            //  没有网络的拦截
            interceptHandle.onNetworkIsNotReachableHandler(type: NetworkListener.shared.status)
            
            //  响应缓存
            responseCache(url: url, callbackHandler: callbackHandler)
            
            return
        }
        
        //  菊花转
        indicatorRun()
        
        let dataRequset =  sessionManage.request(url, method: method, parameters: parameters, headers: headers)
        
        //  如果里面设置了后置拦截 就不进行打印
        dataRequset.responseSwiftyJSON { (response) in
            //  菊花转结束
            indicatorStop()
            
            //  后置拦截 打印漂亮的Json
            interceptHandle.onAfterHandler(url: url, response: response)
            
            //  缓存数据
            HttpCacheManager.write(data: response.data, by: url, callback: { (isOK) in
                print("写入\(isOK ? "成功" : "失败")")
            })
        }
        
        //  结果进行回调
        if let keyPath = callbackHandler.keyPath {
            if callbackHandler.isArray {
                dataRequset.responseArray(keyPath: keyPath) { (response: DataResponse<[T]>) in
                    responseArrayCallbackHandler(response: response, interceptHandle: interceptHandle, callbackHandler: callbackHandler)
                }
            }else {
                dataRequset.responseObject(keyPath: keyPath) { (response: DataResponse<T>) in
                    responseCallbackHandler(response: response, interceptHandle: interceptHandle, callbackHandler: callbackHandler)
                }
            }
        }else {
            dataRequset.responseObject { (response: DataResponse<T>) in
                responseCallbackHandler(response: response, interceptHandle: interceptHandle, callbackHandler: callbackHandler)
            }
        }
        
    }
    
    //  模型响应
    private static func responseCallbackHandler<T: Mappable>(response: DataResponse<T>, interceptHandle: InterceptHandle, callbackHandler: CallbackHandler<T>) {
        
        //  如果对数据进行拦截,那么直接return 不会回调数据
        if interceptHandle.onDataInterceptHandler(data: response.data) {
            return
        }
        
        
        //  响应请求结果回调
        switch response.result {
            
        //  响应成功
        case .success(let value):
            callbackHandler.success?(value, nil)
        //  响应失败
        case .failure(let error):
            callbackHandler.failure?(nil, error)
            interceptHandle.onResponseErrorHandler(error: error)
        }
    }
    
    //  模型数组响应
    private static func responseArrayCallbackHandler<T: Mappable>(response: DataResponse<[T]>, interceptHandle: InterceptHandle, callbackHandler: CallbackHandler<T>) {
        
        if interceptHandle.onDataInterceptHandler(data: response.data) {
            return
        }
        
        //  响应请求结果回调
        switch response.result {
            
        //  响应成功
        case .success(let value):
            callbackHandler.success?(nil, value)
        //  响应失败
        case .failure(let error):
            callbackHandler.failure?(response.data, error)
            interceptHandle.onResponseErrorHandler(error: error)
        }
    }
    
    //  缓存响应 没有网络的时候触发
    private static func responseCache<T: Mappable>(url: String, callbackHandler: CallbackHandler<T>) {
        if callbackHandler.isArray {
            //  目前保存的data是包含所有的JSON信息的 即data保存的是Top格式 所以转换需要一点小手段
            if let JSONDict = HttpCacheManager.getCacheDict(url: url), let dicts = JSONDict[ResponseKey.share.result] as? [[String: Any]] {
                let cache = Mapper<T>().mapArray(JSONArray: dicts)
                callbackHandler.success?(nil, cache)
            }
        }else {
            if let JSONString = HttpCacheManager.getCacheString(url: url) {
                let cache = T(JSONString: JSONString)
                callbackHandler.success?(cache, nil)
            }
        }
    }
}

/// 上传闭包
typealias UploadResult = (_ uploadUrl: URL?, _ isSuccess: Bool, _ resultDict: [String: Any]?) -> ()

/// 上传进度闭包
typealias UploadProgress = (_ uploadUrl: URL?, _ progress: Progress) -> ()

/// 上传数据流
typealias UploadStream = [String: Data]

//MARK:- 上传的网络请求
extension HttpUtils {
    
    /// 文件上传
    ///
    /// - Parameters:
    ///   - url: 请求的url
    ///   - uploadStream: 上传流
    ///   - params: 请求字段
    ///   - size: 如果是图片 图片大小
    ///   - mimeType: 媒体类型
    ///   - uploadResult: 上传结果回调
    ///   - uploadProgress: 上传进度回调
    class func uploadData(url: String,
                          uploadStream: UploadStream,
                          params: Parameters? = nil,
                          size: CGSize?,
                          mimeType: MimeType,
                          uploadResult: @escaping UploadResult,
                          uploadProgress: @escaping UploadProgress) {
        //  请求头的设置
        var headers = ["Content-Type": "multipart/form-data;charset=UTF-8"]
        
        if let mediaSize = size {
            headers.merge(["width":"\(mediaSize.width)","height":"\(mediaSize.height)"]) { (old, new) in new }
        }
        
        //  菊花转
        indicatorRun()
        
        //  开始请求
        Alamofire.upload(multipartFormData: { multipartFormData in
            
            //  是否有请求字段
            if let parameters = params as? [String: String]{
                for (key, value) in parameters {
                    if let data = value.data(using: .utf8) {
                        multipartFormData.append(data, withName: key)
                    }
                }
            }
            
            //  数据上传
            for (key, value) in uploadStream {
                multipartFormData.append(value, withName: key, fileName: key + mimeType.getDefaultFileName(), mimeType: mimeType.getMimeTypeString())
            }
        },
                         to: url,
                         headers: headers,
                         encodingCompletion: { encodingResult in
                            
                            //  菊花转结束
                            indicatorStop()
                            
                            //  响应请求结果
                            switch encodingResult {
                            case .success(let uploadRequest, _ , let streamFileURL):
                                
                                uploadRequest.responseJSON(completionHandler: { (response) in
                                    switch response.result {
                                    case .success(let value):
                                        uploadResult(streamFileURL, true, value as? [String: Any])
                                    case .failure(_):
                                        uploadResult(streamFileURL, false ,nil)
                                    }
                                })
                                
                                uploadRequest.uploadProgress(queue: DispatchQueue.global(qos: .utility)) { progress in
                                    uploadProgress(streamFileURL, progress)
                                }
                                
                            case .failure(_):
                                uploadResult(nil, false, nil)
                                
                            }
        })
        
    }
}

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
