//
//  BaseDao.swift
//  ZDHttpUtilsDemo
//
//  Created by season on 2018/9/21.
//  Copyright © 2018年 season. All rights reserved.
//

import Alamofire
import ObjectMapper

class BaseDao<ApiUrl: HttpUrlProtocol> {
    
    let httpConfig: HttpConfig
    
    let userAgentInfo: String = UIWebView(frame: CGRect.zero).stringByEvaluatingJavaScript(from: "navigator.userAgent") ?? "Unknown"
    
    var sessionManager: SessionManager
    
    var headers = ["Content-Type": "application/json"]
    
    init(httpConfig: HttpConfig, sessionManager: SessionManager? = nil) {
        
        self.httpConfig = httpConfig
        
        //  处理Header
        headers.merge(SessionManager.defaultHTTPHeaders) { (str1, str2) -> String in return str1 }
        
        //  配置Session
        let config = URLSessionConfiguration.default
        //  配置超时时间
        config.timeoutIntervalForRequest = httpConfig.timeOut

        /*
         我跪在这里了 一旦不是使用SessionManager.default 而是自己使用构造器进行请求 就跪了
         load failed with error Error Domain=NSURLErrorDomain Code=-999 "cancelled"
         
         Most likely you should be checking if there is an implementation of authentication challenge delegate method and check if its calling NSURLSessionAuthChallengeCancelAuthenticationChallenge.
         
         感觉和设置安全设置与SSL有关 但是目前又不知道怎么回事
         */
        
        //sessionManager = Alamofire.SessionManager(configuration: config)
        
        //sessionManager = SessionManager.default
        
        self.sessionManager = sessionManager ?? SessionManager.default
    }
}

extension BaseDao {
    
    //MARK:- get请求
    func get<T: Mappable>(moduleUrl: String,
                          parameters: Parameters? = nil,
                          interceptHandle: InterceptHandle,
                          callbackHandler: CallbackHandler<T>) {
        HttpUtils.request(sessionManage: sessionManager, method: .get, url: ApiUrl.baseUrl + moduleUrl, parameters: parameters, headers: headers, interceptHandle: interceptHandle, callbackHandler: callbackHandler)
    }
    
    //MARK:- 内部的post请求, 使用header时候 需要注意是否需要签名
    func post<T: Mappable>(moduleUrl: String,
                          parameters: Parameters? = nil,
                          interceptHandle: InterceptHandle,
                          callbackHandler: CallbackHandler<T>) {
        HttpUtils.request(sessionManage: sessionManager, method: .post, url: ApiUrl.baseUrl + moduleUrl, parameters: parameters, headers: headers, interceptHandle: interceptHandle, callbackHandler: callbackHandler)
    }
}

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
    
    static let timeout45s: SessionManager? = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 45
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        let delegate = SessionDelegate()
        let session = URLSession.init(configuration: configuration, delegate: delegate, delegateQueue: nil)
        return SessionManager(session: session, delegate: delegate)
    }()
}
