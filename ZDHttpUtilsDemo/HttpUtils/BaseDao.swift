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
        
        //  headers的处理
        
        //  这个方法不仅可以更新 也可以进行键值对的添加
        headers.updateValue(userAgentInfo, forKey: "User-Agent")
        headers.updateValue("season", forKey: "developer")
        
        //  如果需要进行签名 这里需要进行
        if httpConfig.isNeedSign {
            headers.updateValue("season".swiftMd5, forKey: "token")
        }
        
        //  处理Header merge的用法 点进去看详细的
        headers.merge(SessionManager.defaultHTTPHeaders) { (current, new) -> String in return current }
        
        //print("defaultHTTPHeaders: \(SessionManager.defaultHTTPHeaders)")
        #if DEBUG
        print("headers: \(headers)")
        #endif
        
        //  赋值sessionManager
        self.sessionManager = sessionManager ?? SessionManager.default
        
        /*----------- 下面是坑爹的点 ----------*/
        
        //  配置Session
        let config = URLSessionConfiguration.default
        //  配置超时时间
        config.timeoutIntervalForRequest = httpConfig.timeOut
        
        let unuserableSesssionManager = SessionManager(configuration: config)
        
        /*
         我跪在这里了 一旦不是使用SessionManager.default 而是自己使用构造器进行请求 就跪了
         load failed with error Error Domain=NSURLErrorDomain Code=-999 "cancelled"
         
         Most likely you should be checking if there is an implementation of authentication challenge delegate method and check if its calling NSURLSessionAuthChallengeCancelAuthenticationChallenge.
         
         感觉和设置安全设置与SSL有关 但是目前又不知道怎么回事
         
         20180926更新: 这个Isusse是普遍存在的:
         不能在方法里面进行这些设置，sessionManager在退出方法后便被回收，设置自然不起作用，正确的方法是要保持一个公有的sessionManager变量，这样就不会被回收。即要改写为静态变量的设置
         如果不想写静态变量,可以像我下面写manager一样进行写 但是在点击的瞬间还是会报错,不过会请求到结果
         */
        
        let manager: SessionManager = {
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = httpConfig.timeOut
            configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
            return SessionManager(configuration: configuration)
        }()
    }
    
    deinit {
        #if DEBUG
        print("\(String(describing: type(of: BaseDao.self))) 销毁了")
        #endif
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
    func get<T: Mappable>(moduleUrl: String,
                          parameters: Parameters? = nil,
                          interceptHandle: InterceptHandle,
                          callbackHandler: CallbackHandler<T>) {
        HttpUtils.request(sessionManage: sessionManager, method: .get, url: ApiUrl.base + moduleUrl, parameters: parameters, headers: headers, interceptHandle: interceptHandle, callbackHandler: callbackHandler)
    }
    
    //MARK:- 内部post请求,网址后面追加参数,使用header时候 需要注意是否需要签名, 如果需要签名 则需要对heads进行处理
    func post<T: Mappable>(moduleUrl: String,
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
    
    //MARK:- 内部post请求,使用header时候 需要注意是否需要签名, 如果需要签名 则需要对heads进行处理
    func post<T: Mappable>(moduleUrl: String,
                          parameters: Parameters? = nil,
                          interceptHandle: InterceptHandle,
                          callbackHandler: CallbackHandler<T>) {
        HttpUtils.request(sessionManage: sessionManager, method: .post, url: ApiUrl.base + moduleUrl, parameters: parameters, headers: headers, interceptHandle: interceptHandle, callbackHandler: callbackHandler)
    }
}

// MARK: - SessionManager实例的静态写法
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
