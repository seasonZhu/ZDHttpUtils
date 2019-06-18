//
//  HttpUtils.swift
//  HttpUtils
//
//  Created by season on 2019/6/18.
//  Copyright © 2019 season. All rights reserved.
//

import Foundation
import Alamofire

/// 网络请求单元
public class HttpUtils {
    
    /// 基本请求
    ///
    /// - Parameters:
    ///   - sessionManager: Alamofire.SessionManager
    ///   - method: 请求方法
    ///   - url: 请求网址
    ///   - parameters: 请求字段
    ///   - encoding: 请求字段编码方式
    ///   - headers: 请求头
    ///   - adapter: 配置器
    ///   - responseResultHandle: 回调响应结果
    public static func request<T: Codable>(sessionManager: SessionManager = SessionManager.default,
                                           method: HTTPMethod,
                                           url: URLConvertible,
                                           parameters: Parameters? = nil,
                                           encoding: ParameterEncoding = URLEncoding.default,
                                           headers: HTTPHeaders? = nil,
                                           adapter: Adapter = Adapter(),
                                           responseResultHandle: @escaping ResponseResultHandle<T>) {
        
        //  前置拦截 如果没有前置拦截,打印请求Api
        if adapter.process.isBeforeHandler {
            #if DEBUG
            print("前置拦截,无法进行网络请求")
            #endif
            return
        }
        
        //  打印请求API
        if !NetworkLogger.shared.isLogging {
            print("HttpUtils ## API Request ## \(method) ## \(url) ## parameters = \(parameters ?? [:])")
        }
        
        //  检查网络
        guard NetworkListener.shared.isReachable else {
            print("没有网络!")
            let failure = ResponseResult<T>.Failure(cache: nil, data: nil, otherError: .networkNotReachable, error: nil, httpURLResponse: nil)
            responseResultHandle(.failure(failure))
            
            //  网络的拦截
            if adapter.process.isNotReachableHandler {
                // 展示网络拦截的弹窗
                adapter.hud?.showNetworkStatus(status: NetworkListener.shared.status)
            }

            //  响应缓存
            if adapter.process.isUseCache {
                responseCacheHandler(url: url, responseResultHandle: responseResultHandle)
            }
            
            return
        }
        
        //  菊花转
        indicatorRun()
        adapter.hud?.showWait()
        
        let dataRequset = sessionManager.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers).validate(statusCode: adapter.config.statusCodes ?? defaultStatusCodes).validate(contentType: adapter.config.contentTypes ?? defaultContentTypes)
        
        dataRequset.responseCodable(queue: adapter.config.queue, keyPath: adapter.config.keyPath) { (response: DataResponse<T>) in
            //  菊花转结束
            indicatorStop()
            adapter.hud?.clear()
            
            //  后置拦截 打印漂亮的Json
            if adapter.process.isAfterHandler {
                return
            }
            
            //  进行结果打印
            if !NetworkLogger.shared.isLogging {
                print("HttpUtils ## API Response ## \(url) ## data = \(String(describing: response))")
            }
            
            //  缓存数据
            if adapter.process.isUseCache {
                if let urlString = try? url.asURL().absoluteString {
                    CacheManager.write(data: response.data, by: urlString) { (isOK) in
                        #if DEBUG
                        print("写入JSON缓存\(isOK ? "成功" : "失败")")
                        #endif
                    }
                }
            }
            
            //  data -> jsonString
            let jsonString: String?
            if let data = response.data {
                jsonString = String(data: data, encoding: .utf8)
            }else {
                jsonString = nil
            }
            
            //  响应请求结果回调
            switch response.result {
                
            //  响应成功
            case .success(let value):
                let success = ResponseResult.Success(codableModel: value, data: response.data, jsonString: jsonString, httpURLResponse: response.response)
                responseResultHandle(.success(success))
                if let successMessage = adapter.hud?.successMessage {
                    adapter.hud?.showMessage(message: successMessage)
                }
                
            //  响应失败
            case .failure(let error):
                let failure = ResponseResult<T>.Failure(cache: nil, data: response.data, otherError: nil, error: error, httpURLResponse: response.response)
                responseResultHandle(.failure(failure))
                adapter.hud?.showError(error: error)
            }
        }
        
    }
    
    /// 响应缓存回调
    ///
    /// - Parameters:
    ///   - url: 请求网址
    ///   - callbackHandler: 回调
    private static func responseCacheHandler<T: Codable>(url: URLConvertible, responseResultHandle: @escaping ResponseResultHandle<T>) {
        guard let urlString = try? url.asURL().absoluteString else {
            return
        }
        
        if let data = CacheManager.getCacheData(url: urlString) {
            let cache = try? JSONDecoder().decode(T.self, from: data)
            let failure = ResponseResult<T>.Failure(cache: cache, data: data, otherError: .networkNotReachable, error: nil, httpURLResponse: nil)
            responseResultHandle(.failure(failure))
        }else {
            let failure = ResponseResult<T>.Failure(cache: nil, data: nil, otherError: .readJSONCacheFailed, error: nil, httpURLResponse: nil)
            responseResultHandle(.failure(failure))
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
                                  url: URLConvertible,
                                  uploadStream: UploadStream,
                                  parameters: Parameters? = nil,
                                  headers: HTTPHeaders? = nil,
                                  size: CGSize? = nil,
                                  mimeType: MimeType,
                                  callbackHandler: UploadCallbackHandler) {
        
        //  检查网络
        guard NetworkListener.shared.isReachable else {
            #if DEBUG
            print("没有网络!")
            #endif
            return
        }
        
        if !NetworkLogger.shared.isLogging {
            print("HttpUtils ## API Request ## post ## \(url) ## parameters = \(parameters ?? [:])")
        }
        
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
                                
                                if !NetworkLogger.shared.isLogging {
                                    print("HttpUtils ## API Response ## \(String(describing: url)) ## data = \(String(describing: encodingResult))")
                                }
                                
                                //  响应请求结果
                                switch encodingResult {
                                case .success(let uploadRequest, _ , let streamFileURL):
                                    
                                    uploadRequest.responseJSON(queue: callbackHandler.queue, completionHandler: { (response) in
                                        switch response.result {
                                        case .success(let value):
                                            callbackHandler.result?(streamFileURL, true, nil, value as? [String: Any])
                                        case .failure(let error):
                                            callbackHandler.result?(streamFileURL, false, error ,nil)
                                        }
                                    })
                                    
                                    uploadRequest.uploadProgress(queue: callbackHandler.progressQueue ?? DispatchQueue.main) { progress in
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
                                           to url: URLConvertible,
                                           method: HTTPMethod = .post,
                                           headers: HTTPHeaders? = nil,
                                           callbackHandler: UploadCallbackHandler) {
        
        //  检查网络
        guard NetworkListener.shared.isReachable else {
            #if DEBUG
            print("没有网络!")
            #endif
            return
        }
        
        //  文件路径
        let fileUrl = URL(fileURLWithPath: filePath)
        
        let uploadRequest = Alamofire.upload(fileUrl, to: url)
        
        //  上传结果
        uploadRequest.responseJSON(queue: callbackHandler.queue, completionHandler: { (response) in
            switch response.result {
            case .success(let value):
                callbackHandler.result?(fileUrl, true, nil, value as? [String: Any])
            case .failure(let error):
                callbackHandler.result?(fileUrl, false, error ,nil)
            }
        })
        
        //  上传进度
        uploadRequest.uploadProgress(queue: callbackHandler.progressQueue ?? DispatchQueue.main) { (progress) in
            callbackHandler.progress?(fileUrl, progress)
        }
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
    /// - Returns: 下载任务字典
    public static func downloadData(sessionManager: SessionManager = SessionManager.default,
                                    url: URLConvertible,
                                    parameters: Parameters? = nil,
                                    headers: HTTPHeaders? = nil,
                                    callbackHandler: DownloadCallbackHandler) -> DownloadRequestTask? {
        
        guard let url = try? url.asURL().absoluteString else {
            return nil
        }
        
        //  检查网络
        guard NetworkListener.shared.isReachable else {
            #if DEBUG
            print("没有网络!")
            #endif
            return nil
        }
        
        //  创建路径
        let destination: DownloadRequest.DownloadFileDestination = { temporaryURL, response in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent(response.suggestedFilename ?? "temp.tmp")
            //两个参数表示如果有同名文件则会覆盖，如果路径中文件夹不存在则会自动创建
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        //  状态栏的菊花转开始
        indicatorRun()
        
        if !NetworkLogger.shared.isLogging {
            print("HttpUtils ## API Request ## \(url) ## parameters = \(String(describing: parameters))")
        }
        
        //  如果有临时数据那么就断点下载
        if let resumData = CacheManager.getResumeData(url: url) {
            return downloadResumData(sessionManager: sessionManager, url: url, resumData: resumData, to: destination, callbackHandler: callbackHandler)
        }
        
        let downloadRequest = sessionManager.download(url, parameters: parameters, to: destination).responseData(queue: callbackHandler.queue) { (responseData) in
            
            //  状态栏的菊花转结束
            indicatorStop()
            
            if !NetworkLogger.shared.isLogging {
                print("HttpUtils ## API Response ## \(String(describing: url)) ## data = \(String(describing: responseData))")
            }
            
            //  响应请求结果
            switch responseData.result {
            case .success(let value):
                callbackHandler.success?(responseData.temporaryURL, responseData.destinationURL, value)
            case .failure(let error):
                callbackHandler.failure?(responseData.resumeData, responseData.temporaryURL, error, responseData.response?.statusCode)
                
                //  将请求失败而下载的部分数据存下来,下次进行
                CacheManager.write(data: responseData.resumeData, by: url) { (isOK) in
                    print("写入下载失败而下载的部分数据缓存\(isOK ? "成功" : "失败")")
                }
            }
            
            //  回调有响应,将任务移除
            downloadRequestTask.removeValue(forKey: url)
            }.downloadProgress(queue: callbackHandler.progressQueue ?? DispatchQueue.main) { (progress) in
                callbackHandler.progress?(progress)
        }
        
        downloadRequestTask.updateValue(downloadRequest, forKey: url)
        return [url: downloadRequest]
    }
    
    /// 断点续下载的方法
    /// 这个方法更多的是配合上面的方法进行使用
    /// - Parameters:
    ///   - sessionManager: Alamofire.SessionManage
    ///   - url: 请求网址
    ///   - resumData: 续下载的数据
    ///   - destination: 目的路径
    ///   - callbackHandler: 下载回调
    /// - Returns: 下载任务字典
    @discardableResult
    static func downloadResumData(sessionManager: SessionManager = SessionManager.default,
                                  url: URLConvertible,
                                  resumData: Data,
                                  to destination: DownloadRequest.DownloadFileDestination? = nil,
                                  callbackHandler: DownloadCallbackHandler) -> DownloadRequestTask {
        
        guard let url = try? url.asURL().absoluteString else {
            return [:]
        }
        
        let downloadRequest = sessionManager.download(resumingWith: resumData, to: destination).responseData(queue: callbackHandler.queue) { (responseData) in
            
            //  状态栏的菊花转结束
            indicatorStop()
            
            print("HttpUtils ## API Response ## \(String(describing: url)) ## data = \(String(describing: responseData))")
            
            //  响应请求结果
            switch responseData.result {
            case .success(let value):
                callbackHandler.success?(responseData.temporaryURL, responseData.destinationURL, value)
                try? FileManager.default.removeItem(atPath: CacheManager.getFilePath(url: url))
            case .failure(let error):
                callbackHandler.failure?(responseData.resumeData, responseData.temporaryURL, error, responseData.response?.statusCode)
                
                //  将请求失败而下载的部分数据存下来,下次进行
                CacheManager.write(data: responseData.resumeData, by: url) { (isOK) in
                    print("写入下载失败而下载的部分数据缓存\(isOK ? "成功" : "失败")")
                }
            }
            
            //  回调有响应,将任务移除
            downloadRequestTask.removeValue(forKey: url)
            
            }.downloadProgress(queue: callbackHandler.progressQueue ?? DispatchQueue.main) { (progress) in
                callbackHandler.progress?(progress)
        }
        
        downloadRequestTask.updateValue(downloadRequest, forKey: url)
        return [url: downloadRequest]
    }
}

// MARK: - 存储下载任务的字典 用于通过url获取下载任务 进而进行暂停/恢复/取消等操作
public typealias DownloadRequestTask = [String: DownloadRequest]
extension HttpUtils {
    
    public static var downloadRequestTask = DownloadRequestTask()
    
    /// 通过url暂停下载任务
    ///
    /// - Parameter url: 请求网址
    public static func suspendDownloadRequest(url: URLConvertible) {
        guard let url = try? url.asURL().absoluteString, let downloadRequest = downloadRequestTask[url] else {
            return
        }
        downloadRequest.suspend()
    }
    
    /// 通过url继续下载任务
    ///
    /// - Parameter url: 请求网址
    public static func resumeDownloadRequest(url: URLConvertible) {
        guard let url = try? url.asURL().absoluteString, let downloadRequest = downloadRequestTask[url] else {
            return
        }
        downloadRequest.resume()
    }
    
    /// 通过url取消下载任务
    ///
    /// - Parameter url: 请求网址
    public static func cancelDownloadRequest(url: URLConvertible) {
        guard let url = try? url.asURL().absoluteString, let downloadRequest = downloadRequestTask[url] else {
            return
        }
        downloadRequest.cancel()
    }
}

// MARK: - 处理CA证书相关
extension HttpUtils {
    
    /// 设置SessionManager.main的CA证书
    ///
    /// - Parameters:
    ///   - sessionManage: Alamofire.SessionManage
    ///   - trustPolicy: 服务器的认证策略
    ///   - p12Path: p12证书路径
    ///   - password: p12证书的密码
    public static func challenge(sessionManage: SessionManager, trustPolicy: HttpsServerTrustPolicy, p12Path: String, p12password: String) {
        /// 设置主sessionManager的验证回调
        sessionManage.delegate.sessionDidReceiveChallenge = { session, challenge in
            return sessionDidReceiveChallenge(trustPolicy: trustPolicy, p12Path: p12Path, p12password: p12password, session: session, challenge: challenge)
        }
    }
    
    /// sessionDidReceiveChallenge的回调
    ///
    /// - Parameters:
    ///   - trustPolicy: 服务器的认证策略
    ///   - p12Path: p12证书路径
    ///   - password: p12证书的密码
    ///   - session: URLSession
    ///   - challenge: URLAuthenticationChallenge
    /// - Returns: 回调结果
    static func sessionDidReceiveChallenge(trustPolicy: HttpsServerTrustPolicy, p12Path: String, p12password: String, session: URLSession, challenge: URLAuthenticationChallenge) -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        /// 服务器证书认证
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            print("服务器证书认证")
            
            var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
            var credential: URLCredential?
            
            let host = challenge.protectionSpace.host
            
            if let serverTrust = challenge.protectionSpace.serverTrust {
                if trustPolicy.evaluate(serverTrust, forHost: host) {
                    disposition = .useCredential
                    credential = URLCredential(trust: serverTrust)
                } else {
                    disposition = .cancelAuthenticationChallenge
                }
            }
            
            return (disposition, credential)
            
        }
            /// 客户端证书验证
        else if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate {
            print("客户端证书验证")
            
            guard let identityAndTrust = try? ClientTrustPolicy.extractIdentity(p12Path: p12Path, p12password: p12password) else {
                return (.cancelAuthenticationChallenge, nil)
            }
            
            let urlCredential = URLCredential(identity: identityAndTrust.identityRef, certificates: identityAndTrust.certArray as? [Any], persistence: URLCredential.Persistence.forSession)
            
            return (.useCredential, urlCredential)
            
        }
        
        return (.cancelAuthenticationChallenge, nil)
    }
}


extension HttpUtils {
    
    /// 默认的StatusCodes校验
    private static let defaultStatusCodes = Array(200..<300)
    
    ///  默认的ContentTypes校验
    private static let defaultContentTypes = ["*/*"]
}
