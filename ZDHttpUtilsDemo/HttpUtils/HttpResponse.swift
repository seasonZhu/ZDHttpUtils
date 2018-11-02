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
    var status = "status"
    var total = "total"
    var result = "result"
    var message = "message"

}


//MARK:- 泛型模型装配 通用 result是模型
class Response<T: Mappable>: Mappable {

    var code: Int?
    var status : String?
    var total : Int?
    var result : T?
    var message : String?
    
    required init?(map: Map) {
        
    }
    
    // 这个地方的字符串可以进行转译映射 这个可控制性更强
    func mapping(map: Map) {
        code <- map[ResponseKey.share.code]
        status <- map[ResponseKey.share.status]
        total <- map[ResponseKey.share.total]
        result <- map[ResponseKey.share.result]
        message <- map[ResponseKey.share.message]
    }
}

//MARK:- 泛型模型数组装配 通用 result是模型数组
class ResponseArray<T: Mappable>: Mappable {
    
    var code: Int?
    var status : String?
    var total : Int?
    var result : [T]?
    var message : String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        code <- map[ResponseKey.share.code]
        status <- map[ResponseKey.share.status]
        total <- map[ResponseKey.share.total]
        result <- map[ResponseKey.share.result]
        message <- map[ResponseKey.share.message]
    }
}

//MARK:- 泛型基本类型装配 通用 result是基本类型 Int Bool String
class ResponseBase<T: BasicStructProtocol>: Mappable {
    var code: Int?
    var status : String?
    var total : Int?
    var result : T?
    var message : String?
    
    var isJump = false
    
    required init?(map: Map) {
        checkStringToBool(map: map)
    }
    
    func mapping(map: Map) {
        code <- map[ResponseKey.share.code]
        status <- map[ResponseKey.share.status]
        total <- map[ResponseKey.share.total]
        if !isJump {
            result <- map[ResponseKey.share.result]
        }
        message <- map[ResponseKey.share.message]
    }
}

// MARK: - 判断字符串类型的bool值类型
extension ResponseBase {
    func checkStringToBool(map: Map) {
        if let string = map.JSON[ResponseKey.share.result] as? String {
            let bool: Bool
            
            if BoolString.trues.contains(string) || (string as NSString).integerValue > 0 {
                bool = true
            }else if BoolString.falses.contains(string) || (string as NSString).integerValue <= 0 {
                bool = false
            }else {
                bool = false
            }
            
            result = bool as? T
            
            //  这里其实判断的是T与Bool类型是否匹配,如果匹配说明是String转Bool,否则的话其实String转String,是不能Jump的
            if let _ = result {
                isJump = true
            }
        }
    }
}

/// 只是为了便于泛型而追加的一个空协议
public protocol BasicStructProtocol {}

extension Bool: BasicStructProtocol {}
extension Int: BasicStructProtocol {}
extension String: BasicStructProtocol {}

public struct BoolString {
    static let trues = ["TRUE", "True", "true", "YES", "Yes", "yes"]
    static let falses = ["FALSE", "False", "false", "NO", "No", "no"]
}
