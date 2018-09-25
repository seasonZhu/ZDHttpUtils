//
//  HttpResponse.swift
//  ZDHttpUtilsDemo
//
//  Created by season on 2018/9/19.
//  Copyright © 2018年 season. All rights reserved.
//

import Foundation
import ObjectMapper

//MARK:- 响应字符串key
class ResponseKey {
    static let share = ResponseKey()
    private init() {}
    
    var code = "code"
    var message = "message"
    var result = "results"
    var status = "status"
    var total = "total"
}


//MARK:- 泛型模型装配 通用 result是模型
class Response<T: Mappable>: Mappable {
    
    var message : String?
    var result : T?
    var status : Int?
    var total : Int?
    var code: Int?
    
    required init?(map: Map) {
        
    }
    
    // 这个地方的字符串可以进行转译映射 这个可控制性更强
    func mapping(map: Map) {
        message <- map[ResponseKey.share.message]
        result <- map[ResponseKey.share.result]
        status <- map[ResponseKey.share.status]
        total <- map[ResponseKey.share.total]
        code <- map[ResponseKey.share.code]
    }
}

//MARK:- 泛型模型数组装配
class ResponseArray<T: Mappable>: Mappable {
    
    var message : String?
    var result : [T]?
    var status : Int?
    var total : Int?
    var code: Int?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        message <- map[ResponseKey.share.message]
        result <- map[ResponseKey.share.result]
        status <- map[ResponseKey.share.status]
        total <- map[ResponseKey.share.total]
        code <- map[ResponseKey.share.code]
    }
}
