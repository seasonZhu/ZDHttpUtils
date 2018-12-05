//
//  CheckoutDao.swift
//  ZDHttpUtilsDemo
//
//  Created by season on 2018/9/21.
//  Copyright © 2018年 season. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

struct CheckoutUrl: HttpUrlProtocol {
    static let checkoutApi = "/tz_inf/api/topics"
}

protocol CheckoutRequest: HttpRequestProtocol {
    func getList<T: Mappable>(parameters: Parameters?, interceptHandle: InterceptHandle, callbackHandler: CallbackHandler<T>)
}

class CheckoutDao: BaseDao<CheckoutUrl>, CheckoutRequest {
    func getList<T: Mappable>(parameters: Parameters? = nil, interceptHandle: InterceptHandle, callbackHandler: CallbackHandler<T>) {
        post(api: CheckoutUrl.checkoutApi, parameters: nil, interceptHandle: interceptHandle, callbackHandler: callbackHandler)
    }
}
