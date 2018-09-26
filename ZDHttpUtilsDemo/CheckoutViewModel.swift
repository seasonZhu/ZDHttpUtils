//
//  CheckoutViewModel.swift
//  ZDHttpUtilsDemo
//
//  Created by season on 2018/9/21.
//  Copyright © 2018年 season. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

class CheckoutViewModel: BaseViewModel {
    private lazy var dao = CheckoutDao(httpConfig: HttpConfig.Builder().setTimeOut(15).constructor, sessionManager: SessionManager.timeout45s)
    
    override var interceptHandle: InterceptHandle {
        return InterceptHandle.Builder().setIsShowToast(false).constructor
    }
    
    func getResponse<T: Mappable>(parameters: Parameters? = nil, interceptHandle: InterceptHandle? = nil, callbackHandler: CallbackHandler<T>) {
        dao.getList(parameters: parameters, interceptHandle: interceptHandle ?? self.interceptHandle, callbackHandler: callbackHandler)
    }
}
