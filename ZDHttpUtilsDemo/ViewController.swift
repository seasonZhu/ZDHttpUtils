//
//  ViewController.swift
//  ZDHttpUtilsDemo
//
//  Created by season on 2018/9/14.
//  Copyright © 2018年 season. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configResponseKey()
        setUpUI()
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
    }
    
    //MARK:- 设置请求服务的key
    private func configResponseKey() {
        ResponseKey.share.result = "list"
        ResponseKey.share.code = "code"
    }
}

extension ViewController {
    //MARK:- 到顶层的模型请求
    @objc
    func requestToTop() {
        
        //  直接到顶层路径进行转换
        let callbackHandler = CallbackHandler<ResponseArray<Item>>()
        
        callbackHandler.success = { model, models in
            guard let unwrapedModel = model else {
                return
            }
            print(unwrapedModel)
        }
        
        callbackHandler.failure = { data, error in
            print(String(describing: data), String(describing: error))
        }
        
//        HttpUtils.request(method: .post, url: "http://sun.topray-media.cn/tz_inf/api/topics", parameters: nil, interceptHandle: InterceptHandle(), callbackHandler: callbackHandler)
        CheckoutViewModel().getResponse(callbackHandler: callbackHandler)
    }
    
    //MARK:- 到底层的模型请求
    @objc
    func requestToRoot() {
        //  直接到目的路径 所以泛型的类型需要进行更改
        let callbackHandler = CallbackHandler<Item>().setKeyPath("list").setIsArray(true)
        
        callbackHandler.success = { model, models in
            guard let unwrapedModels = models else {
                return
            }
            print(unwrapedModels)
        }
        
        callbackHandler.failure = { data, error in
            print(String(describing: data), String(describing: error))
        }
        
        HttpUtils.request(method: .post, url: "http://sun.topray-media.cn/tz_inf/api/topics", parameters: nil, interceptHandle: InterceptHandle(), callbackHandler: callbackHandler)
        
    }
}



