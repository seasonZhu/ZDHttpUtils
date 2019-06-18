//
//  CheckoutViewModel.swift
//  ZDHttpUtilsDemo
//
//  Created by season on 2018/9/21.
//  Copyright © 2018年 season. All rights reserved.
//

import UIKit
import Alamofire


class CheckoutViewModel: BaseViewModel {
    //MARK:- 对象方法使用
    private lazy var dao = CheckoutDao(httpConfig: HttpConfig.Builder().setTimeout(15).isNeedSign(true).constructor)
    
    override var interceptHandle: InterceptHandle {
        return InterceptHandle.Builder().setIsShowToast(false).setIsShowLoading(true).setLoadingText("wait...").constructor
    }
    
    func getList<T: Mappable>(parameters: Parameters? = nil, interceptHandle: InterceptHandle? = nil, callbackHandler: CallbackHandler<T>) {
        dao.getList(parameters: parameters, interceptHandle: interceptHandle ?? self.interceptHandle, callbackHandler: callbackHandler)
    }
    
    //MARK:- 类方法使用
    static func getList<T: Mappable>(parameters: Parameters? = nil, interceptHandle: InterceptHandle? = nil, callbackHandler: CallbackHandler<T>) {
        let dao = CheckoutDao(httpConfig: HttpConfig.Builder().setTimeout(15).constructor)
        dao.getList(parameters: parameters, interceptHandle: interceptHandle ?? InterceptHandle(), callbackHandler: callbackHandler)
    }
}
