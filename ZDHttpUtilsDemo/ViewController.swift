//
//  ViewController.swift
//  ZDHttpUtilsDemo
//
//  Created by season on 2018/9/14.
//  Copyright © 2018年 season. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        
        let student = Student()
        //student.name = "season"
        //student.age = 18
        
        let person = Person(sex: "man", name: "sola")
        print(student.toDictionary)
        print(person.toDictionary)
        
        modelChangeByFastlane()
        
        //URLComponentsUse()
        
        //HttpRequestConvertibleUse()
        
        httpsCatificationSetting()
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
        }
    }
    
    //MARK:- 设置请求服务的key
    private func configMappingTable() {
        MappingTable.share.result = "list"
        MappingTable.share.code = "code"
    }
    
    //MARK:- 设置u17请求服务的key
    private func configU17MappingTable() {
        MappingTable.share.result = "data"
        MappingTable.share.code = "code"
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
        
        let modelLabel = UILabel(frame: CGRect(x: 0, y: 700, width: view.bounds.width, height: 44))
        modelLabel.textAlignment = .center
        modelLabel.textColor = UIColor.black
        modelLabel.text = msg
        view.addSubview(modelLabel)
    }
    
    //MARK:- URLComponents的简单实用
    private func URLComponentsUse() {
        let urlComponents = URLComponents(url: URL.init(string: "tz_inf/api/topics")!, resolvingAgainstBaseURL: true)
        let url = urlComponents?.url(relativeTo: URL.init(string: "http://sun.topray-media.cn/"))
        //  这个不能打断点在这里看url是啥 要去控制台打po看url?.absoluteString是完整的网址, 而且这个url是没什么卵用的,要用其absoluteString
        print(url)
        print(url?.absoluteString)
        configMappingTable()
        
        Alamofire.request(url!.absoluteString, method: .post).responseJSON { (responseJSON) in
            let response = responseJSON.flatMap({ (json) -> ResponseArray<Item>? in
                let response = ResponseArray<Item>(JSON: json as! [String: Any])
                return response
            })
            print(response)
        }
    }
    
    private func HttpRequestConvertibleUse() {
        
        configU17MappingTable()
        
        let requestModel = U17RequestModel(sexType: "2",
                                           key: "fabe6953ce6a1b8738bd2cabebf893a472d2b6274ef7ef6f6a5dc7171e5cafb14933ae65c70bceb97e0e9d47af6324d50394ba70c1bb462e0ed18b88b26095a82be87bc9eddf8e548a2a3859274b25bd0ecfce13e81f8317cfafa822d8ee486fe2c43e7acd93e9f19fdae5c628266dc4762060f6026c5ca83e865844fc6beea59822ed4a70f5288c25edb1367700ebf5c78a27f5cce53036f1dac4a776588cd890cd54f9e5a7adcaeec340c7a69cd986:::open",
                                           target: "U17_3.0",
                                           version: "3.3.3",
                                           v: "3320101",
                                           model: "Simulator",
                                           device_id: "29B09615-E478-4320-8E6A-55B1DE48CB36",
                                           time: "\(Int32(Date().timeIntervalSince1970))")
        
        typealias ResponseU17 = Response<U17Data>
        
        let callbackHandler = CallbackHandler<ResponseU17>()
        
        callbackHandler.success = { model, models, data, jsonString, httpResponse in
            guard let unwrapedModel = model else { return }
            print(unwrapedModel)
        }
        
        callbackHandler.failure = { data, error, _ in
            print(String(describing: data), String(describing: error))
        }
        
        HttpUtils.request(request: U17Request.home(requestModel), interceptHandle: InterceptHandle(), callbackHandler: callbackHandler)
        
    }
    
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
                             interceptHandle: InterceptHandle(),
                             callbackHandler: CallbackHandler<ResponseBase<Int>>()
                                .onSuccess({ (model, models, data, jsonString, httpResponse) in
                                    print(jsonString ?? "jsonString is empty")
                                }).onFailure({ (data, error, httpResponse) in
                                    guard let unwrappedData = data, let jsonString = String(data: unwrappedData, encoding: .utf8), let unwrappedError = error else {
                                        return
                                    }
                                    //  这个地方虽然走的是失败,但是statusCode为200 其实是回传的data转的jsonString是一个xml的字符串,其实客户端与服务端是通的
                                    print(jsonString)
                                    print(unwrappedError)
                                    print(httpResponse?.statusCode ?? 0)
                                }))
        
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
    }
}

extension ViewController {
    //MARK:- 到顶层的模型请求
    @objc
    func requestToTop() {
        
        configMappingTable()
        
        //  直接到顶层路径进行转换
        let callbackHandler = CallbackHandler<ResponseArray<Item>>()
            .onSuccess { (model, models, data, jsonString, httpResponse) in
                // 其实一旦回调成功, model或者models中有一个必然有值,因为走success的条件是 Alamofire中.success (let value) 所以这里,知道后台返回的是JSON或者是JSON数组的话,这里完全可以隐式解包,当然使用guard守护也是不错
                guard let unwrapedModel = model else { return }
                print(unwrapedModel)
            }.onFailure { (data, error, _) in
                print(String(describing: data), String(describing: error))
            }.onMessage { (message) in
                print(message)
        }
        
        //HttpUtils.request(method: .post, url: "http://sun.topray-media.cn/tz_inf/api/topics", parameters: nil, interceptHandle: InterceptHandle(), callbackHandler: callbackHandler)
        
        
        CheckoutViewModel().getList(callbackHandler: callbackHandler)
        //CheckoutViewModel.getList(callbackHandler: callbackHandler)
    }
    
    //MARK:- 到底层的模型请求
    @objc
    func requestToRoot() {
        
        configMappingTable()
        
        //  直接到目的路径 所以泛型的类型需要进行更改
        HttpUtils.request(method: .post, url: "http://sun.topray-media.cn/tz_inf/api/topics",
                          parameters: nil,
                          interceptHandle: InterceptHandle(),
                          callbackHandler: CallbackHandler<Item>().setKeyPath("list").setIsArray(true)
                            .onSuccess({ (model, models, data, jsonString, httpResponse) in
                                guard let unwrapedModels = models else { return }
                                print(unwrapedModels)
        })
                            .onFailure({ (data, error, _ ) in
            print(String(describing: data), String(describing: error))
        })
                            .onMessage({ (message) in
            print(message)
        }))
        
    }
    
    //MARK:- 有妖气的网络请求 返回非常的复杂
    @objc
    func requestU17() {
        
        configU17MappingTable()
        
        /// 这个地方还是需要进行一次强转的,否则的话类型会是Mappable这个基类,另外可以在函数里面进行别名的使用
        typealias ResponseU17 = Response<U17Data>
        
        let callbackHandler = CallbackHandler<ResponseU17>() // CallbackHandler<U17Root>()
        
        callbackHandler.success = { model, models, data, jsonString, httpResponse in
            guard let unwrapedModel = model else { return }
            print(unwrapedModel)
        }
        
        callbackHandler.failure = { data, error, _ in
            print(String(describing: data), String(describing: error))
        }
        
        let parameters = ["sexType":"2",
                          "key":"fabe6953ce6a1b8738bd2cabebf893a472d2b6274ef7ef6f6a5dc7171e5cafb14933ae65c70bceb97e0e9d47af6324d50394ba70c1bb462e0ed18b88b26095a82be87bc9eddf8e548a2a3859274b25bd0ecfce13e81f8317cfafa822d8ee486fe2c43e7acd93e9f19fdae5c628266dc4762060f6026c5ca83e865844fc6beea59822ed4a70f5288c25edb1367700ebf5c78a27f5cce53036f1dac4a776588cd890cd54f9e5a7adcaeec340c7a69cd986:::open",
                          "target":"U17_3.0",
                          "version":"3.3.3",
                          "v":"3320101",
                          "model":"Simulator",
                          "device_id":"29B09615-E478-4320-8E6A-55B1DE48CB36",
                          "time":"\(Int32(Date().timeIntervalSince1970))",]
        
        HttpUtils.request(method: .post, url: "http://app.u17.com/v3/appV3_3/ios/phone/comic/boutiqueListNew", parameters: parameters, interceptHandle: InterceptHandle(), callbackHandler: callbackHandler)
    }
    
    @objc
    func requesJSONStringToModel() {
        
        configMappingTable()
        
        let JSONString = "{\"list\": \"-1\", \"code\": 200, \"message\": \"hello\"}"
        
        // 字符串映射为Bool类型
        let boolModel = Mapper<ResponseBase<Bool>>().map(JSONString: JSONString)
        print(boolModel)
        
        // 字符串还是映射为String类型
        let stringModel = Mapper<ResponseBase<String>>().map(JSONString: JSONString)
        print(stringModel)
        
        // 转为Int类型
        let JSONIntString = "{\"list\": -1, \"code\": 200, \"message\": \"hello\"}"
        let intModel = Mapper<ResponseBase<Int>>().map(JSONString: JSONIntString)
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
        
        let data = UIImageJPEGRepresentation(UIImage(named: "weibo_icon")!, 1.0)!
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
        RequestUtils(httpConfig: HttpConfig.Builder().constructor).uploadFromeFilePath(filePath: HttpCacheManager.getFilePath(url: "http://app.u17.com/v3/appV3_3/ios/phone/comic/boutiqueListNew"), to: "http://sit-dssp.dstsp.com:50001/dssp/v1/core/appQuestion/commit", callbackHandler: UploadCallbackHandler().onUploadResult({ (url, isSuccess, error, dict) in
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

class Student {
    var name: String?
    var age: Int?
}

extension Student: ReflectProtocol {}

struct Person {
    let sex: String
    let name: String
}

extension Person: ReflectProtocol {}
