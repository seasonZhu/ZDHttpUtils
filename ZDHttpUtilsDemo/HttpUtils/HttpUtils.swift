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
    
    /// 基于ObjectMapper泛型返回的网络请求
    ///
    /// - Parameters:
    ///   - sessionManage: Alamofire.SessionManage
    ///   - method: 请求方式
    ///   - url: 请求网址
    ///   - parameters: 请求字段
    ///   - headers: 请求头
    ///   - interceptHandle: 拦截回调
    ///   - callbackHandler: 结果回调
    public static func request<T: Mappable>(sessionManage: SessionManager = SessionManager.default,
                                            method: HTTPMethod,
                                            url: String,
                                            parameters: Parameters? = nil,
                                            headers: HTTPHeaders? = nil,
                                            interceptHandle: InterceptHandle,
                                            callbackHandler: CallbackHandler<T>) {
        
        //  前置拦截 如果没有前置拦截,打印请求Api
        if interceptHandle.onBeforeHandler(method: method, url: url, parameters: parameters) {
            #if DEBUG
            print("前置拦截,无法进行网络请求")
            #endif
            return
        }
        
        //  检查网络
        guard NetworkListener.shared.isReachable else {
            #if DEBUG
            print("没有网络!")
            #endif
            
            //  没有网络的拦截
            interceptHandle.onNetworkIsNotReachableHandler(type: NetworkListener.shared.status)
            
            //  响应缓存
            if interceptHandle.onCacheHandler() {
                responseCache(url: url, callbackHandler: callbackHandler)
            }
            
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
            if interceptHandle.onCacheHandler() {
                HttpCacheManager.write(data: response.data, by: url, callback: { (isOK) in
                    #if DEBUG
                    print("写入JSON缓存\(isOK ? "成功" : "失败")")
                    #endif
                })
            }
        }
        
        //  结果进行回调
        if let keyPath = callbackHandler.keyPath {
            if callbackHandler.isArray {
                dataRequset.responseArray(keyPath: keyPath) { (responseArray: DataResponse<[T]>) in
                    responseArrayCallbackHandler(responseArray: responseArray, interceptHandle: interceptHandle, callbackHandler: callbackHandler)
                }
            }else {
                dataRequset.responseObject(keyPath: keyPath) { (responseObject: DataResponse<T>) in
                    responseObjectCallbackHandler(responseObject: responseObject, interceptHandle: interceptHandle, callbackHandler: callbackHandler)
                }
            }
        }else {
            dataRequset.responseObject { (responseObject: DataResponse<T>) in
                responseObjectCallbackHandler(responseObject: responseObject, interceptHandle: interceptHandle, callbackHandler: callbackHandler)
            }
        }
        
    }
    
    /// 响应模型处理
    ///
    /// - Parameters:
    ///   - responseObject: 响应对象
    ///   - callbackHandler: 回调
    private static func responseObjectCallbackHandler<T: Mappable>(responseObject: DataResponse<T>, interceptHandle: InterceptHandle, callbackHandler: CallbackHandler<T>) {
        
        //  如果对数据进行拦截,那么直接return 不会回调数据
        if interceptHandle.onDataInterceptHandler(data: responseObject.data, httpResponse: responseObject.response) {
            return
        }
        
        //  data -> jsonString
        let jsonString: String?
        if let data = responseObject.data {
            jsonString = String(data: data, encoding: .utf8)
        }else {
            jsonString = nil
        }
        
        //  响应请求结果回调
        switch responseObject.result {
            
        //  响应成功
        case .success(let value):
            callbackHandler.success?(value, nil, responseObject.data, jsonString, responseObject.response)
        //  响应失败
        case .failure(let error):
            callbackHandler.failure?(responseObject.data, error, responseObject.response)
            interceptHandle.onResponseErrorHandler(error: error)
        }
    }
    
    /// 响应模型数组处理
    ///
    /// - Parameters:
    ///   - responseObject: 响应对象
    ///   - callbackHandler: 回调
    private static func responseArrayCallbackHandler<T: Mappable>(responseArray: DataResponse<[T]>, interceptHandle: InterceptHandle, callbackHandler: CallbackHandler<T>) {
        
        if interceptHandle.onDataInterceptHandler(data: responseArray.data, httpResponse: responseArray.response) {
            return
        }
        
        //  data -> jsonString
        let jsonString: String?
        if let data = responseArray.data {
            jsonString = String(data: data, encoding: .utf8)
        }else {
            jsonString = nil
        }
        
        //  响应请求结果回调
        switch responseArray.result {
            
        //  响应成功
        case .success(let value):
            callbackHandler.success?(nil, value, responseArray.data, jsonString, responseArray.response)
        //  响应失败
        case .failure(let error):
            callbackHandler.failure?(responseArray.data, error, responseArray.response)
            interceptHandle.onResponseErrorHandler(error: error)
        }
    }
    
    
    /// 响应缓存回调
    ///
    /// - Parameters:
    ///   - url: 请求网址
    ///   - callbackHandler: 回调
    private static func responseCache<T: Mappable>(url: String, callbackHandler: CallbackHandler<T>) {
        if callbackHandler.isArray {
            //  目前保存的data是包含所有的JSON信息的 即data保存的是Top格式 所以转换需要一点小手段
            if let JSONDict = HttpCacheManager.getCacheDict(url: url), let dicts = JSONDict[MappingTable.share.result] as? [[String: Any]] {
                let cache = Mapper<T>().mapArray(JSONArray: dicts)
                callbackHandler.success?(nil, cache, nil, nil, nil)
            }else {
                callbackHandler.message?("读取缓存失败")
            }
        }else {
            if let JSONString = HttpCacheManager.getCacheString(url: url) {
                let cache = T(JSONString: JSONString)
                callbackHandler.success?(cache, nil, nil, nil, nil)
            }else {
                callbackHandler.message?("读取缓存失败")
            }
        }
    }
}

// MARK: - 上传的网络请求
extension HttpUtils {
    // 文件上传
    ///
    /// - Parameters:
    ///   - sessionManage: Alamofire.SessionManager
    ///   - url: 请求网址
    ///   - uploadStream: 上传的数据流
    ///   - parameters: 请求字段
    ///   - headers: 请求头
    ///   - size: 文件的size 长宽
    ///   - mimeType: 文件类型 详细看FawMimeType枚举
    ///   - callbackHandler: 上传回调
    public static func uploadData(sessionManager: SessionManager = SessionManager.default,
                          url: String,
                          uploadStream: UploadStream,
                          parameters: Parameters? = nil,
                          headers: HTTPHeaders? = nil,
                          size: CGSize?,
                          mimeType: MimeType,
                          callbackHandler: UploadCallbackHandler) {
        
        print("HttpUtils ## API Request ## post ## \(url) ## parameters = \(String(describing: parameters))")
        
        //  请求头的设置
        var uploadHeaders = ["Content-Type": "multipart/form-data;charset=UTF-8"]
        if let unwappedHeaders = headers {
            uploadHeaders.merge(unwappedHeaders) { (current, new) -> String in return current }
        }
        
        //  如果有多媒体的宽高信息,就加入headers中
        if let mediaSize = size {
            uploadHeaders.updateValue("\(mediaSize.width)", forKey: "width")
            uploadHeaders.updateValue("\(mediaSize.height)", forKey: "height")
        }
        
        //  菊花转
        indicatorRun()
        
        //  开始请求
        sessionManager.upload(multipartFormData: { multipartFormData in
            
            //  表单处理
            
            //  是否有请求字段
            if let params = parameters as? [String: String] {
                for (key, value) in params {
                    if let data = value.data(using: .utf8) {
                        multipartFormData.append(data, withName: key)
                    }
                }
            }
            
            //  数据上传
            for (key, value) in uploadStream {
                multipartFormData.append(value, withName: key, fileName: key + mimeType.fileName, mimeType: mimeType.type)
            }
        },
                              to: url,
                              headers: uploadHeaders,
                              encodingCompletion: { encodingResult in
                                
                                //  菊花转结束
                                indicatorStop()
                                
                                print("HttpUtils ## API Response ## \(String(describing: url)) ## data = \(String(describing: encodingResult))")
                                
                                //  响应请求结果
                                switch encodingResult {
                                case .success(let uploadRequest, _ , let streamFileURL):
                                    
                                    uploadRequest.responseJSON(completionHandler: { (response) in
                                        switch response.result {
                                        case .success(let value):
                                            callbackHandler.result?(streamFileURL, true, nil, value as? [String: Any])
                                        case .failure(let error):
                                            callbackHandler.result?(streamFileURL, false, error ,nil)
                                        }
                                    })
                                    
                                    uploadRequest.uploadProgress(queue: DispatchQueue.global(qos: .utility)) { progress in
                                        callbackHandler.progress?(streamFileURL, progress)
                                    }
                                    
                                case .failure(let error):
                                    callbackHandler.result?(nil, false, error, nil)
                                }
        })
        
    }
    
    /// 通过文件路径进行上传
    ///
    /// - Parameters:
    ///   - sessionManager: Alamofire.SessionManager
    ///   - filePath: 文件路径字符串
    ///   - url: 请求网址
    ///   - method: 请求方法
    ///   - headers: 请求头
    ///   - callbackHandler: 上传回调
    public static func uploadFromeFilePath(sessionManager: SessionManager = SessionManager.default,
                                           filePath: String,
                                           to url: String,
                                           method: HTTPMethod = .post,
                                           headers: HTTPHeaders? = nil,
                                           callbackHandler: UploadCallbackHandler) {
        let fileUrl = URL(fileURLWithPath: filePath)
        
        let uploadRequest = Alamofire.upload(fileUrl, to: url)
        
        //  上传进度
        uploadRequest.uploadProgress(queue: DispatchQueue.global(qos: .utility)) { (progress) in
            callbackHandler.progress?(fileUrl, progress)
        }
        
        //  上传结果
        uploadRequest.responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success(let value):
                callbackHandler.result?(fileUrl, true, nil, value as? [String: Any])
            case .failure(let error):
                callbackHandler.result?(fileUrl, false, error ,nil)
            }
        })
    }
    
}

// MARK: - 下载的网络请求
extension HttpUtils {
    /// 文件下载
    ///
    /// - Parameters:
    ///   - sessionManager: Alamofire.SessionManage
    ///   - url: 请求网址
    ///   - parameters: 请求字段
    ///   - headers: 请求头
    ///   - callbackHandler: 下载回调
    public static func downloadData(sessionManager: SessionManager = SessionManager.default,
                                    url: String,
                                    parameters: Parameters? = nil,
                                    headers: HTTPHeaders? = nil,
                                    callbackHandler: DownloadCallbackHandler) {
        //  创建路径
        let destination: DownloadRequest.DownloadFileDestination = { temporaryURL, response in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent(response.suggestedFilename ?? "temp.tmp")
            //两个参数表示如果有同名文件则会覆盖，如果路径中文件夹不存在则会自动创建
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        //  状态栏的菊花转开始
        indicatorRun()
        
        print("HttpUtils ## API Request ## \(url) ## parameters = \(String(describing: parameters))")
        
        //  如果有临时数据那么就断点下载
        if let resumData = HttpCacheManager.getResumeData(url: url) {
            sessionManager.download(resumingWith: resumData, to: destination).responseData { (responseData) in
                
                //  状态栏的菊花转结束
                indicatorStop()
                
                print("HttpUtils ## API Response ## \(String(describing: url)) ## data = \(String(describing: responseData))")
                
                //  响应请求结果
                switch responseData.result {
                case .success(let value):
                    callbackHandler.success?(responseData.temporaryURL, responseData.destinationURL, value)
                    try? FileManager.default.removeItem(atPath: HttpCacheManager.getFilePath(url: url))
                case .failure(let error):
                    callbackHandler.failure?(responseData.resumeData, responseData.temporaryURL, error, responseData.response?.statusCode)
                    
                    //  将请求失败而下载的部分数据存下来,下次进行
                    HttpCacheManager.write(data: responseData.resumeData, by: url, callback: { (isOK) in
                        print("写入下载失败而下载的部分数据缓存\(isOK ? "成功" : "失败")")
                    })
                }
                }.downloadProgress { (progress) in
                    callbackHandler.progress?(progress)
            }
            
            return
        }
        
        sessionManager.download(url, parameters: parameters, to: destination).responseData { (responseData) in
            
            //  状态栏的菊花转结束
            indicatorStop()
            
            print("HttpUtils ## API Response ## \(String(describing: url)) ## data = \(String(describing: responseData))")
            
            //  响应请求结果
            switch responseData.result {
            case .success(let value):
                callbackHandler.success?(responseData.temporaryURL, responseData.destinationURL, value)
            case .failure(let error):
                callbackHandler.failure?(responseData.resumeData, responseData.temporaryURL, error, responseData.response?.statusCode)
                
                //  将请求失败而下载的部分数据存下来,下次进行
                HttpCacheManager.write(data: responseData.resumeData, by: url, callback: { (isOK) in
                    print("写入下载失败而下载的部分数据缓存\(isOK ? "成功" : "失败")")
                })
            }
        }.downloadProgress { (progress) in
            callbackHandler.progress?(progress)
        }
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
