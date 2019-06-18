//
//  ViewController.swift
//  ZDHttpUtilsDemo
//
//  Created by season on 2018/9/14.
//  Copyright © 2018年 season. All rights reserved.
//

import UIKit
import Alamofire
import HttpUtils


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        
        modelChangeByFastlane()
        
        URLComponentsUse()
        
        //HttpRequestConvertibleUse()
        
        httpsCatificationSetting()
        
        /*
         打包脚本
         fastlane pg version:1.0.0 build:10 scheme:ZDHttpUtilsDemo displayName:HttpUtils mode:Debug/Release/Sit/Sit-Release changelog:打包测试
         */
    }
    
    @objc
    func newRequestToTop() {
        let adapter = Adapter(config: Adapter.Config(keyPath: "list"), hud: Adapter.HUD())
        HttpUtils.request(sessionManager: SessionManager.default, method: .post, url: "http://sun.topray-media.cn/tz_inf/api/topics", adapter: adapter) { (result: ResponseResult<[ListItem]>) in
            print(result.model)
        }
    }
    
    //MARK:- 搭建界面
    private func setUpUI() {
        let requestToTopButton = UIButton(frame: CGRect(x:  0, y: 44, width: view.bounds.width, height: 44))
        requestToTopButton.setTitle("请求到顶层", for: .normal)
        requestToTopButton.backgroundColor = UIColor.lightGray
        requestToTopButton.addTarget(self, action: #selector(requestToTop), for: .touchUpInside)
        view.addSubview(requestToTopButton)
        
        let requestToRootButton = UIButton(frame: CGRect(x:  0, y: 88, width: view.bounds.width, height: 44))
        requestToRootButton.setTitle("请求到底层", for: .normal)
        requestToRootButton.backgroundColor = UIColor.lightGray
        requestToRootButton.addTarget(self, action: #selector(requestToRoot), for: .touchUpInside)
        view.addSubview(requestToRootButton)
        
        let u17Button = UIButton(frame: CGRect(x:  0, y: 132, width: view.bounds.width, height: 44))
        u17Button.setTitle("有妖气请求", for: .normal)
        u17Button.backgroundColor = UIColor.lightGray
        u17Button.addTarget(self, action: #selector(requestU17), for: .touchUpInside)
        view.addSubview(u17Button)
        
        let basicButton = UIButton(frame: CGRect(x:  0, y: 176, width: view.bounds.width, height: 44))
        basicButton.setTitle("基本类型使用本地字符串JSON尝试", for: .normal)
        basicButton.backgroundColor = UIColor.lightGray
        basicButton.addTarget(self, action: #selector(requesJSONStringToModel), for: .touchUpInside)
        view.addSubview(basicButton)
        
        let uploadButton = UIButton(frame: CGRect(x:  0, y: 220, width: view.bounds.width, height: 44))
        uploadButton.setTitle("文件通过[String: Data]格式进行上传", for: .normal)
        uploadButton.backgroundColor = UIColor.lightGray
        uploadButton.addTarget(self, action: #selector(requestUpload), for: .touchUpInside)
        view.addSubview(uploadButton)
        
        let uploadByfilePathButton = UIButton(frame: CGRect(x:  0, y: 264, width: view.bounds.width, height: 44))
        uploadByfilePathButton.setTitle("文件路径进行上传", for: .normal)
        uploadByfilePathButton.backgroundColor = UIColor.lightGray
        uploadByfilePathButton.addTarget(self, action: #selector(requestUploadByFilePath), for: .touchUpInside)
        view.addSubview(uploadByfilePathButton)
        
        let downloadPDFButton = UIButton(frame: CGRect(x:  0, y: 308, width: view.bounds.width, height: 44))
        downloadPDFButton.setTitle("PDF下载", for: .normal)
        downloadPDFButton.backgroundColor = UIColor.lightGray
        downloadPDFButton.addTarget(self, action: #selector(requestDownloadPDF), for: .touchUpInside)
        view.addSubview(downloadPDFButton)
        
        let downloadQQDmgButton = UIButton(frame: CGRect(x:  0, y: 352, width: view.bounds.width, height: 44))
        downloadQQDmgButton.setTitle("QQDmg下载", for: .normal)
        downloadQQDmgButton.backgroundColor = UIColor.lightGray
        downloadQQDmgButton.addTarget(self, action: #selector(requestDownloadQQDmg), for: .touchUpInside)
        view.addSubview(downloadQQDmgButton)
        
        let margin: CGFloat = 10
        let buttonTitles = ["暂停QQ.dmg下载", "恢复QQ.dmg下载", "取消QQ.dmg下载"]
        let buttonCount = CGFloat(buttonTitles.count)
        let buttonWidth = (view.bounds.width - (buttonCount + 1) * margin) / buttonCount
        
        for (index, title) in buttonTitles.enumerated() {
            let button = UIButton(frame: CGRect(x: CGFloat(index + 1) * margin + CGFloat(index) * buttonWidth, y: 400, width: buttonWidth, height: 30))
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
            button.setTitleColor(UIColor.white, for: .normal)
            button.tag = index + 1000
            button.backgroundColor = UIColor.lightGray
            button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
            view.addSubview(button)
        }
        
    }
    
    /// 下载的暂停/继续/取消
    ///
    /// - Parameter button: 按钮
    @objc
    func buttonAction(_ button: UIButton) {
        if button.tag == 1000 {
            RequestUtils.suspendDownloadRequest(url: "https://dldir1.qq.com/qqfile/QQforMac/QQ_V6.4.0.dmg")
        }
        
        if button.tag == 1001 {
            RequestUtils.resumeDownloadRequest(url: "https://dldir1.qq.com/qqfile/QQforMac/QQ_V6.4.0.dmg")
        }
        
        if button.tag == 1002 {
            RequestUtils.cancelDownloadRequest(url: "https://dldir1.qq.com/qqfile/QQforMac/QQ_V6.4.0.dmg")
            
            
            let cerPath = Bundle.main.path(forResource: "server_formal", ofType: "cer")
            let p12path = Bundle.main.path(forResource: "client", ofType: "p12")
            let p12password = "123456"
            
//            SessionManager.serverTrust.request("https://dssp.dstsp.com:50080/dssp/v1/nac/vr/voiceRecognition", method: .post).response { (response) in
//                print(response)
//                print(response.response?.statusCode ?? -9999)
//            }
            
            /*
            //SessionManager.serverTrust.delegate.sessionDidReceiveChallenge = nil/* { (session, challenge) in
                
                var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
                var credential: URLCredential?
                
                /*if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                    let host = challenge.protectionSpace.host
                    if
                        let serverTrustPolicy = qServerTrustPolicyManager.serverTrustPolicy(forHost: host),
                        let serverTrust = challenge.protectionSpace.serverTrust
                    {
                        if serverTrustPolicy.evaluate(serverTrust, forHost: host) {
                            disposition = .useCredential
                            credential = URLCredential(trust: serverTrust)
                        } else {
                            disposition = .cancelAuthenticationChallenge
                        }
                    }
                }else */if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate {
                    print("客户端证书验证")
                    
                    guard let identityAndTrust = try? ClientTrustPolicy.extractIdentity(p12Path: p12path!, p12password: p12password) else {
                        return (.cancelAuthenticationChallenge, nil)
                    }
                    
                    let urlCredential = URLCredential(identity: identityAndTrust.identityRef, certificates: identityAndTrust.certArray as? [Any], persistence: URLCredential.Persistence.forSession)
                    
                    return (.useCredential, urlCredential)
                    
                }
                
                return (disposition, credential)
            }*/
             */
        }
    }

    //MARK:- 通过fastlane进行模式区分
    private func modelChangeByFastlane() {
        let text = Bundle.main.infoDictionary?["BaseUrl"] as? String
        
        let msg: String
        #if DEBUG
        msg = "debug"
        #elseif SIT
        msg = "sit"
        #elseif SITRelease
        msg = "sit-release"
        #else
        msg = "release"
        #endif
        
        let modelLabel = UILabel(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - 100, width: view.bounds.width, height: 44))
        modelLabel.textAlignment = .center
        modelLabel.textColor = UIColor.black
        modelLabel.text = msg
        view.addSubview(modelLabel)
    }
    
    //MARK:- URLComponents的简单使用
    private func URLComponentsUse() {
        let urlComponents = URLComponents(url: URL.init(string: "tz_inf/api/topics")!, resolvingAgainstBaseURL: true)
        let url = urlComponents?.url(relativeTo: URL.init(string: "http://sun.topray-media.cn/"))
        //  这个不能打断点在这里看url是啥 要去控制台打po看url?.absoluteString是完整的网址, 而且这个url是没什么卵用的,要用其absoluteString
        print(url)
        print(url?.absoluteString)
        
        Alamofire.request(url!.absoluteString, method: .post).responseJSON { (responseJSON) in
            print(responseJSON)
        }
    }
    
//    private func HttpRequestConvertibleUse() {
//
//        let requestModel = U17RequestModel(sexType: "2",
//                                           key: "fabe6953ce6a1b8738bd2cabebf893a472d2b6274ef7ef6f6a5dc7171e5cafb14933ae65c70bceb97e0e9d47af6324d50394ba70c1bb462e0ed18b88b26095a82be87bc9eddf8e548a2a3859274b25bd0ecfce13e81f8317cfafa822d8ee486fe2c43e7acd93e9f19fdae5c628266dc4762060f6026c5ca83e865844fc6beea59822ed4a70f5288c25edb1367700ebf5c78a27f5cce53036f1dac4a776588cd890cd54f9e5a7adcaeec340c7a69cd986:::open",
//                                           target: "U17_3.0",
//                                           version: "3.3.3",
//                                           v: "3320101",
//                                           model: "Simulator",
//                                           device_id: "29B09615-E478-4320-8E6A-55B1DE48CB36",
//                                           time: "\(Int32(Date().timeIntervalSince1970))")
//
//        typealias ResponseU17 = Response<U17Data>
//
//        let callbackHandler = CallbackHandler<ResponseU17>()
//
//        callbackHandler.success = { model, models, data, jsonString, httpResponse in
//            guard let unwrapedModel = model else { return }
//            print(unwrapedModel)
//        }
//
//        callbackHandler.failure = { data, error, _ in
//            print(String(describing: data), String(describing: error))
//        }
//
//        HttpUtils.request(request: U17Request.home(requestModel), interceptHandle: InterceptHandle(), callbackHandler: callbackHandler)
//
//    }
    
    //MARK:- 这是一个Https的双向认证,会走HttpUtils的sessionDidReceiveChallenge的方法
    private func httpsCatificationSetting() {
        
        //pre ("https://dssp.dstsp.com:443/dssp/v1/core/")
        //pro ("https://sit-dssp.dstsp.com/dssp/v1/core/")
        /*.setUrl("https://dssp.dstsp.com:443/dssp/v1/core/findappStartupInterfaceAvailableToApp")*/
        /*.setUrl("https://dssp.dstsp.com:443/dssp/v1/core/login/userName")*/
        let cerPath = Bundle.main.path(forResource: "server_formal", ofType: "cer")
        let p12path = Bundle.main.path(forResource: "client", ofType: "p12")
        let p12password = "123456"
        
        // 需要把证书先添加进来
        
        let requestUtils = RequestUtils(httpConfig: HttpConfig.Builder().setRequestType(.post).setCertification(trustPolicy: HttpsServerTrustPolicy.default, p12Path: p12path, p12password: p12password).constructor)
        requestUtils.request(url: "https://dssp.dstsp.com:50080/dssp/v1/nac/vr/voiceRecognition",
                             adapter: Adapter()) { (result: ResponseResult<ResponseBase<Int>>) in
                                print(result.model)
        }
        
//        HttpsServerTrustPolicy.manager = ServerTrustPolicyManager(policies: ["dssp.dstsp.com": ServerTrustPolicy.pinCertificates(certificates: ServerTrustPolicy.certificates(), validateCertificateChain: true, validateHost: true)])
//
//        RequestUtils.default.post(url: "https://dssp.dstsp.com:50080/dssp/v1/nac/vr/voiceRecognition", interceptHandle: InterceptHandle(), callbackHandler: CallbackHandler<ResponseBase<Int>>()
//            .onSuccess({ (model, models, data, jsonString, httpResponse) in
//                print(jsonString)
//            }).onFailure({ (data, error, httpResponse) in
//                guard let unwrappedData = data, let jsonString = String(data: unwrappedData, encoding: .utf8), let unwrappedError = error, let nsError = unwrappedError as? NSError else {
//                    return
//                }
//                //  这个地方虽然走的是失败,但是statusCode为200 其实是回传的data转的jsonString是一个xml的字符串,其实客户端与服务端是通的
//                print(jsonString)
//                print(unwrappedError)
//                print(nsError)
//                print(httpResponse?.statusCode ?? 0)
//            }))
        
        //  我严格按照Alamofire中的文档说明进行编写认证策略,结果还是有问题,需要找找原因与反思一下
        SessionManager.serverTrust.request("https://dssp.dstsp.com:50080/dssp/v1/nac/vr/voiceRecognition", method: .post).response { (response) in
            print(response)
            print(response.response?.statusCode ?? -9999)
        }
    }
}

extension ViewController {
    //MARK:- 到顶层的模型请求
    @objc
    func requestToTop() {
        let adapter = Adapter(hud: Adapter.HUD())
        HttpUtils.request(sessionManager: SessionManager.default, method: .post, url: "http://sun.topray-media.cn/tz_inf/api/topics", adapter: adapter) { (result: ResponseResult<ExampleModelName>) in
            print(result.model)
        }
    }
    
    //MARK:- 到底层的模型请求
    @objc
    func requestToRoot() {
        let adapter = Adapter(config: Adapter.Config(keyPath: "list"), hud: Adapter.HUD())
        HttpUtils.request(sessionManager: SessionManager.default, method: .post, url: "http://sun.topray-media.cn/tz_inf/api/topics", adapter: adapter) { (result: ResponseResult<[ListItem]>) in
            print(result.model)
        }
    }
    
    //MARK:- 有妖气的网络请求 返回非常的复杂
    @objc
    func requestU17() {
        let parameters = ["sexType":"2",
                          "key":"fabe6953ce6a1b8738bd2cabebf893a472d2b6274ef7ef6f6a5dc7171e5cafb14933ae65c70bceb97e0e9d47af6324d50394ba70c1bb462e0ed18b88b26095a82be87bc9eddf8e548a2a3859274b25bd0ecfce13e81f8317cfafa822d8ee486fe2c43e7acd93e9f19fdae5c628266dc4762060f6026c5ca83e865844fc6beea59822ed4a70f5288c25edb1367700ebf5c78a27f5cce53036f1dac4a776588cd890cd54f9e5a7adcaeec340c7a69cd986:::open",
                          "target":"U17_3.0",
                          "version":"3.3.3",
                          "v":"3320101",
                          "model":"Simulator",
                          "device_id":"29B09615-E478-4320-8E6A-55B1DE48CB36",
                          "time":"\(Int32(Date().timeIntervalSince1970))",]
        
        let adapter = Adapter(hud: Adapter.HUD())
        HttpUtils.request(method: .post, url: "http://app.u17.com/v3/appV3_3/ios/phone/comic/boutiqueListNew", parameters: parameters, adapter: adapter) { (result: ResponseResult<CoableU17Root>) in
            print(result.model)
        }
    }
    
    @objc
    func requesJSONStringToModel() {

        let decoder = JSONDecoder()
        
        let JSONString = "{\"list\": \"-1\", \"code\": 200, \"message\": \"hello\"}"
        let jsonStringData = JSONString.data(using: .utf8)!
        // 字符串映射为Bool类型
        let stringModel = try? decoder.decode(ResponseBase<String>.self, from: jsonStringData)
        print(stringModel)

        // 转为Int类型
        let JSONIntString = "{\"list\": -1, \"code\": 200, \"message\": \"hello\"}"
        let jsonIntStringData = JSONIntString.data(using: .utf8)!
        let intModel = try? decoder.decode(ResponseBase<Int>.self, from: jsonIntStringData)
        print(intModel)
    }
    
    @objc
    func requestUpload() {
        
        let parameters = [
            "vin": "",
            "userId": "",
            "question": "测试数据",
            "scene": "其他问题",
            "contact": "123456"
        ]
        
        let data = UIImage(named: "weibo_icon")!.jpegData(compressionQuality: 1.0)!
        let uploadStream = ["weibo_icon": data]
        
        RequestUtils(httpConfig: HttpConfig.Builder().constructor).upload(url: "http://sit-dssp.dstsp.com:50001/dssp/v1/core/appQuestion/commit", uploadStream: uploadStream, parameters: parameters, size: nil, mimeType: .image("jpg"), callbackHandler: UploadCallbackHandler().onUploadResult({ (url, isSuccess, error, dict) in
            print(dict)
            print("上传\(isSuccess ? "成功" : "失败")了")
        }).onUploadProgress({ (url, progress) in
            print(progress)
        }))
    }
    
    @objc
    func requestUploadByFilePath() {
        RequestUtils(httpConfig: HttpConfig.Builder().constructor).uploadFromeFilePath(filePath: HttpUtils.CacheManager.getFilePath(url: "http://app.u17.com/v3/appV3_3/ios/phone/comic/boutiqueListNew"), to: "http://sit-dssp.dstsp.com:50001/dssp/v1/core/appQuestion/commit", callbackHandler: UploadCallbackHandler().onUploadResult({ (url, isSuccess, error, dict) in
            print(dict)
            print("上传\(isSuccess ? "成功" : "失败")了")
        }).onUploadProgress({ (url, progress) in
            print(progress)
        }))
    }
    
    @objc
    func requestDownloadPDF() {
        let downloadTask = RequestUtils.default
        
        downloadTask.download(url: "https://dssp.dstsp.com/ow/static/manual/usermanual.pdf", callbackHandler: DownloadCallbackHandler().onSuccess({ (tempUrl, fileUrl, data) in
            
            print("fileUrl: \(fileUrl)")
            print("data: \(data)")
        }).onFailure({ (data, tempUrl, error, statusCode) in
            print("tempUrl: \(tempUrl)")
        }).onDownloadProgress({ (progress) in
            print(progress)
        }))
    }
    
    @objc
    func requestDownloadQQDmg() {
        let downloadTask = RequestUtils(httpConfig: HttpConfig.Builder().constructor)
        
        downloadTask.download(url: "https://dldir1.qq.com/qqfile/QQforMac/QQ_V6.4.0.dmg", callbackHandler: DownloadCallbackHandler().onSuccess({ (tempUrl, fileUrl, data) in
            print("tempUrl: \(tempUrl)")
            print("fileUrl: \(fileUrl)")
            print("data: \(data)")
        }).onFailure({ (data, tempUrl, error, statusCode) in
            print("tempUrl: \(tempUrl)")
        }).onDownloadProgress({ (progress) in
            print(progress)
        }))
    }
}

// MARK: - 按照文档写了一个认证策略管理器,完全都不能用
extension SessionManager {
    static let serverTrust: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        let serverTrustPolicyManager = ServerTrustPolicyManager(policies: ["dssp.dstsp.com": ServerTrustPolicy.disableEvaluation])
        return SessionManager(configuration: configuration, serverTrustPolicyManager: serverTrustPolicyManager)
    }()
}


struct ResponseBase<T: Codable>: Codable {
    var list: T?
    var code: Int?
    var message: String?
}
