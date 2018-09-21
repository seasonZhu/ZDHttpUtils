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
    private lazy var dao = CheckoutDao.init(httpConfig: HttpConfig.Builder().setTimeOut(10).constructor)
    
    private var interceptHandle = InterceptHandle.Builder().setIsShowToast(false).constructor
    
    func getResponse<T: Mappable>(parameters: Parameters? = nil, interceptHandle: InterceptHandle? = nil, callbackHandler: CallbackHandler<T>) {
        dao.getList(parameters: parameters, interceptHandle: interceptHandle ?? self.interceptHandle, callbackHandler: callbackHandler)
    }
}
