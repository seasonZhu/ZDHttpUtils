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
        print(student.reflectToDictionary())
        print(person.reflectToDictionary())
        
        modelChangeByFastlane()
    }
    
    //MARK:- 搭建界面
    private func setUpUI() {
        let requestToTopButton = UIButton(frame: CGRect(x:  0, y: 44, width: view.bounds.width, height: 44))
        requestToTopButton.setTitle("请求到顶层", for: .normal)
        requestToTopButton.backgroundColor = UIColor.lightGray
        requestToTopButton.addTarget(self, action: #selector(requestToTop), for: .touchUpInside)
        view.addSubview(requestToTopButton)
        
        let requestToRootButton = UIButton(frame: CGRect(x:  0, y: 132, width: view.bounds.width, height: 44))
        requestToRootButton.setTitle("请求到底层", for: .normal)
        requestToRootButton.backgroundColor = UIColor.lightGray
        requestToRootButton.addTarget(self, action: #selector(requestToRoot), for: .touchUpInside)
        view.addSubview(requestToRootButton)
        
        let u17Button = UIButton(frame: CGRect(x:  0, y: 220, width: view.bounds.width, height: 44))
        u17Button.setTitle("有妖气请求", for: .normal)
        u17Button.backgroundColor = UIColor.lightGray
        u17Button.addTarget(self, action: #selector(requestU17), for: .touchUpInside)
        view.addSubview(u17Button)
        
        let basicButton = UIButton(frame: CGRect(x:  0, y: 308, width: view.bounds.width, height: 44))
        basicButton.setTitle("基本类型使用本地字符串JSON尝试", for: .normal)
        basicButton.backgroundColor = UIColor.lightGray
        basicButton.addTarget(self, action: #selector(requesJSONStringToModel), for: .touchUpInside)
        view.addSubview(basicButton)
        
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
        
        let modelLabel = UILabel(frame: CGRect(x: 0, y: 396, width: view.bounds.width, height: 44))
        modelLabel.textAlignment = .center
        modelLabel.textColor = UIColor.black
        modelLabel.text = msg
        view.addSubview(modelLabel)
    }
    
    func check<N>(_ field: N) {
        if let x = field as? Any, x is Int || x is NSNumber {
            
        }
    }
}

extension ViewController {
    //MARK:- 到顶层的模型请求
    @objc
    func requestToTop() {
        
        configMappingTable()
        
        //  直接到顶层路径进行转换
        let callbackHandler = CallbackHandler<ResponseArray<Item>>()
        
        callbackHandler.success = { model, models, _ in
            // 其实一旦回调成功, model或者models中有一个必然有值,因为走success的条件是 Alamofire中.success (let value) 所以这里,知道后台返回的是JSON或者是JSON数组的话,这里完全可以隐式解包,当然使用guard守护也是不错
            guard let unwrapedModel = model as? ResponseArray<Item> else { return }
            print(unwrapedModel)
        }
        
        callbackHandler.failure = { data, error, _ in
            print(String(describing: data), String(describing: error))
        }
        
//        HttpUtils.request(method: .post, url: "http://sun.topray-media.cn/tz_inf/api/topics", parameters: nil, interceptHandle: InterceptHandle(), callbackHandler: callbackHandler)
        
        
        CheckoutViewModel().getList(callbackHandler: callbackHandler)
        //CheckoutViewModel.getList(callbackHandler: callbackHandler)
    }
    
    //MARK:- 到底层的模型请求
    @objc
    func requestToRoot() {
        
        configMappingTable()
        
        //  直接到目的路径 所以泛型的类型需要进行更改
        let callbackHandler = CallbackHandler<Item>().setKeyPath("list").setIsArray(true)
        
        callbackHandler.success = { model, models, _ in
            guard let unwrapedModels = models else { return }
            print(unwrapedModels)
        }
        
        callbackHandler.failure = { data, error, _ in
            print(String(describing: data), String(describing: error))
        }
        
        HttpUtils.request(method: .post, url: "http://sun.topray-media.cn/tz_inf/api/topics", parameters: nil, interceptHandle: InterceptHandle(), callbackHandler: callbackHandler)
        
    }
    
    //MARK:- 有妖气的网络请求 返回非常的复杂
    @objc
    func requestU17() {
        
        configU17MappingTable()
        
        /// 这个地方还是需要进行一次强转的,否则的话类型会是Mappable这个基类,另外可以在函数里面进行别名的使用
        typealias ResponseU17 = Response<U17Data>
        
        let callbackHandler = CallbackHandler<ResponseU17>() // CallbackHandler<U17Root>()
        
        callbackHandler.success = { model, models, _ in
            guard let unwrapedModel = model as? ResponseU17 else { return }
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
        
        let basicModel = Mapper<ResponseBase<Bool>>().map(JSONString: JSONString)
        
        print(basicModel)
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
