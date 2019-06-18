//
//  BaseDao.swift
//  ZDHttpUtilsDemo
//
//  Created by season on 2018/9/21.
//  Copyright © 2018年 season. All rights reserved.
//

import Alamofire


/// 基础Dao层 其实BaseDao与BaseViewModel已经涉及到业务层面了
public class BaseDao<ApiUrl: HttpUrlProtocol> {
    private let requestUtils: RequestUtils
    
    /// 初始化方法
    ///
    /// - Parameter httpConfig: 请求配置 如果传入有值,就是自定义的请求 如果没有传入就使用default
    public init(httpConfig: HttpConfig? = nil) {
        if let config = httpConfig {
            requestUtils = RequestUtils(httpConfig: config)
        }else {
            requestUtils = RequestUtils.default
        }
    }
    
    /// 基本请求
    ///
    /// - Parameters:
    ///   - method: 请求方式
    ///   - api: 业务接口
    ///   - parameters: 请求参数
    ///   - interceptHandle: 拦截回调
    ///   - callbackHandler: 结果回调
    public func request<T: Mappable>(method: HTTPMethod, api: String, parameters: Parameters? = nil, interceptHandle: InterceptHandle, callbackHandler: CallbackHandler<T>) {
        requestUtils.request(method: method, url: ApiUrl.base + api, parameters: parameters, interceptHandle: interceptHandle, callbackHandler: callbackHandler)
    }
    
    /// get请求
    ///
    /// - Parameters:
    ///   - api: 业务接口
    ///   - parameters: 请求参数
    ///   - interceptHandle: 拦截回调
    ///   - callbackHandler: 结果回调
    public func get<T: Mappable>(api: String,
                          parameters: Parameters? = nil,
                          interceptHandle: InterceptHandle,
                          callbackHandler: CallbackHandler<T>) {
        requestUtils.get(url: ApiUrl.base + api, parameters: parameters, interceptHandle: interceptHandle, callbackHandler: callbackHandler)
    }
    
    /// post请求
    ///
    /// - Parameters:
    ///   - api: 业务接口
    ///   - parameters: 请求参数
    ///   - interceptHandle: 拦截回调
    ///   - callbackHandler: 结果回调
    public func post<T: Mappable>(api: String,
                           parameters: Parameters? = nil,
                           interceptHandle: InterceptHandle,
                           callbackHandler: CallbackHandler<T>) {
        requestUtils.post(url: ApiUrl.base + api, parameters: parameters, interceptHandle: interceptHandle, callbackHandler: callbackHandler)
    }
    
    /// 上传请求
    ///
    /// - Parameters:
    ///   - api: 业务接口
    ///   - uploadStream: 上传的数据流
    ///   - parameters: 请求参数
    ///   - size: 文件的长宽
    ///   - mimeType: 文件类型
    ///   - callbackHandler: 结果回调
    public func upload(api: String,
                uploadStream: UploadStream,
                parameters: Parameters? = nil,
                size: CGSize?,
                mimeType: MimeType,
                callbackHandler: UploadCallbackHandler) {
        requestUtils.upload(url: ApiUrl.base + api, uploadStream: uploadStream, size: size, mimeType: mimeType, callbackHandler: callbackHandler)
    }
    
    /// 文件路径上传
    ///
    /// - Parameters:
    ///   - filePath: 文件路径
    ///   - api: 业务接口
    ///   - method: 请求方式,默认是post
    ///   - headers: 请求头
    ///   - callbackHandler: 上传回调
    public func uploadFromeFilePath(filePath: String,
                             to api: String,
                             method: HTTPMethod = .post,
                             headers: HTTPHeaders? = nil,
                             callbackHandler: UploadCallbackHandler) {
        requestUtils.uploadFromeFilePath(filePath: filePath, to: ApiUrl.base + api, callbackHandler: callbackHandler)
    }
    
    /// 下载请求
    ///
    /// - Parameters:
    ///   - api: 业务接口
    ///   - parameters: 请求参数
    ///   - callbackHandler: 结果回调
    /// - Returns: 下载任务字典
    @discardableResult
    public func download(api: String, parameters: Parameters? = nil, callbackHandler: DownloadCallbackHandler) -> DownloadRequestTask? {
        return requestUtils.download(url: ApiUrl.base + api, parameters: parameters, callbackHandler: callbackHandler)
    }
    
    /// 通过url暂停下载任务
    ///
    /// - Parameter api: 业务接口
    public func suspendDownloadRequest(api: String) {
        RequestUtils.suspendDownloadRequest(url: ApiUrl.base + api)
    }
    
    /// 通过url继续下载任务
    ///
    /// - Parameter api: 业务接口
    public func resumeDownloadRequest(api: String) {
        RequestUtils.resumeDownloadRequest(url: ApiUrl.base + api)
    }
    
    /// 通过url取消下载任务
    ///
    /// - Parameter api: 业务接口
    public func cancelDownloadRequest(api: String) {
        RequestUtils.cancelDownloadRequest(url: ApiUrl.base + api)
    }
    
    deinit {
        print("\(String(describing: type(of: self))) 销毁了")
    }
}

/*
class BaseDao<ApiUrl: HttpUrlProtocol> {
 
    let httpConfig: HttpConfig
 
    let userAgentInfo: String = UIWebView(frame: CGRect.zero).stringByEvaluatingJavaScript(from: "navigator.userAgent") ?? "Unknown"
 
    let sessionManager: SessionManager
 
    var headers = ["Content-Type": "application/json"]
 
    init(httpConfig: HttpConfig) {
 
        self.httpConfig = httpConfig
 
        //  headers的处理
        var headers = ["Content-Type": "application/json"]
        headers.merge(httpConfig.addHeads) { (current, new) -> String in return new }
 
        //  这个方法不仅可以更新 也可以进行键值对的添加
        headers.updateValue(userAgentInfo, forKey: "User-Agent")
        headers.updateValue("season", forKey: "developer")
 
        //  如果需要进行签名 这里需要进行
        if httpConfig.isNeedSign {
            headers.updateValue("season".swiftMd5, forKey: "token")
        }
 
        //  处理Header merge的用法 点进去看详细的
        headers.merge(SessionManager.defaultHTTPHeaders) { (current, new) -> String in return new }
        self.headers = headers
        print("headers: \(headers)")
 
        //  处理SessionManager
        let manager: SessionManager = {
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = httpConfig.timeout
            configuration.httpAdditionalHeaders = headers
            return SessionManager(configuration: configuration)
        }()
        SessionManager.custom = manager
        self.sessionManager = SessionManager.custom
 
        /*----------- 下面是坑爹的点 ----------*/
        /*
         //  配置Session
         let config = URLSessionConfiguration.default
         //  配置超时时间
         config.timeoutIntervalForRequest = httpConfig.timeout
 
         let unuserableSesssionManager = SessionManager(configuration: config)
 
         /*
         我跪在这里了 一旦不是使用SessionManager.default 而是自己使用构造器进行请求 就跪了
         load failed with error Error Domain=NSURLErrorDomain Code=-999 "cancelled"
 
         Most likely you should be checking if there is an implementation of authentication challenge delegate method and check if its calling NSURLSessionAuthChallengeCancelAuthenticationChallenge.
 
         感觉和设置安全设置与SSL有关 但是目前又不知道怎么回事
 
         20180926更新: 这个issue是普遍存在的:
         不能在方法里面进行这些设置，sessionManager在退出方法后便被回收，设置自然不起作用，正确的方法是要保持一个公有的sessionManager变量，这样就不会被回收。即要改写为静态变量的设置
         如果不想写静态变量,可以像我下面写manager一样进行写 但是在点击的瞬间还是会报错,不过会请求到结果
         */
 
         let manager: SessionManager = {
         let configuration = URLSessionConfiguration.default
         configuration.timeoutIntervalForRequest = httpConfig.timeout
         configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
         return SessionManager(configuration: configuration)
         }()
         */
    }
 
    deinit {
        print("\(String(describing: type(of: BaseDao.self))) 销毁了")
    }
}

extension BaseDao {
 
    //MARK:- 内部get请求,网址后面追加参数
    func get<T: Mappable>(moduleUrl: String,
                          parameters: Parameters? = nil,
                          behindUrl extraParameters: String...,
        interceptHandle: InterceptHandle,
        callbackHandler: CallbackHandler<T>) {
 
        var url = ApiUrl.base + moduleUrl
        if extraParameters.count > 0 {
            url += "/" + extraParameters.joined(separator: "/")
        }
        HttpUtils.request(sessionManage: sessionManager, method: .get, url: url, parameters: parameters, headers: headers, interceptHandle: interceptHandle, callbackHandler: callbackHandler)
    }
 
    //MARK:- 内部get请求,网址后面无追加参数
    func getWithExtraParameters<T: Mappable>(moduleUrl: String,
                                             parameters: Parameters? = nil,
                                             interceptHandle: InterceptHandle,
                                             callbackHandler: CallbackHandler<T>) {
        HttpUtils.request(sessionManage: sessionManager, method: .get, url: ApiUrl.base + moduleUrl, parameters: parameters, headers: headers, interceptHandle: interceptHandle, callbackHandler: callbackHandler)
    }
 
    //MARK:- 内部post请求,使用header时候 需要注意是否需要签名, 如果需要签名 则需要对heads进行处理
    func post<T: Mappable>(moduleUrl: String,
                           parameters: Parameters? = nil,
                           interceptHandle: InterceptHandle,
                           callbackHandler: CallbackHandler<T>) {
        HttpUtils.request(sessionManage: sessionManager, method: .post, url: ApiUrl.base + moduleUrl, parameters: parameters, headers: headers, interceptHandle: interceptHandle, callbackHandler: callbackHandler)
    }
 
    //MARK:- 内部post请求,网址后面追加参数,使用header时候 需要注意是否需要签名, 如果需要签名 则需要对heads进行处理
    func postWithExtraParameters<T: Mappable>(moduleUrl: String,
                                              parameters: Parameters? = nil,
                                              behindUrl extraParameters: String...,
        interceptHandle: InterceptHandle,
        callbackHandler: CallbackHandler<T>) {
 
        var url = ApiUrl.base + moduleUrl
        if extraParameters.count > 0 {
            url += "/" + extraParameters.joined(separator: "/")
        }
        HttpUtils.request(sessionManage: sessionManager, method: .post, url: url, parameters: parameters, headers: headers, interceptHandle: interceptHandle, callbackHandler: callbackHandler)
    }
}

// MARK: -针对httpConfig中timeout进行配置化请求超时时间
extension BaseDao {
 
    /// 针对httpConfig中timeout进行配置化请求超时时间,主要是对区间进行了判断
    ///
    /// - Parameter timeout: 超时时间
    /// - Returns: SessionManager
    static func getSesssion(timeout: TimeInterval) -> SessionManager {
        switch timeout {
        case 0...5:
            return SessionManager.timeout5s
        case 6...15:
            return SessionManager.default
        case 16...30:
            return SessionManager.timeout30s
        case 31...60:
            return SessionManager.timeout60s
        case 61...120:
            return SessionManager.timeout120s
        default:
            return SessionManager.default
        }
    }
}

// MARK: - 常用的一些超时设置
extension SessionManager {
    static let timeout5s: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 5
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        return SessionManager(configuration: configuration)
    }()
 
    static let timeout30s: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        return SessionManager(configuration: configuration)
    }()
 
    static let timeout60s: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        return SessionManager(configuration: configuration)
        //let delegate = SessionDelegate()
        //let session = URLSession.init(configuration: configuration, delegate: delegate, delegateQueue: nil)
        //return SessionManager(session: session, delegate: delegate)
    }()
 
    static let timeout120s: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 120
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        return SessionManager(configuration: configuration)
        //let delegate = SessionDelegate()
        //let session = URLSession.init(configuration: configuration, delegate: delegate, delegateQueue: nil)
        //return SessionManager(session: session, delegate: delegate)
    }()
}
*/
