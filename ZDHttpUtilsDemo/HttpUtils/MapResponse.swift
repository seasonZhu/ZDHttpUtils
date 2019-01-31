//
//  HttpResponse.swift
//  ZDHttpUtilsDemo
//
//  Created by season on 2018/9/19.
//  Copyright © 2018年 season. All rights reserved.
//

import Foundation
import ObjectMapper


//MARK:- 映射表协议
public protocol MappingTableProtocol{
    var code: String { set get }
    var status: String { set get }
    var total: String { set get }
    var result: String { set get }
    var message: String { set get }
}

//MARK:- 映射表
class MappingTable: MappingTableProtocol {
    public static let share = MappingTable()
    private init() {}
    
    public var code = "code"
    public var status = "status"
    public var total = "total"
    public var result = "result"
    public var message = "message"
}

// MARK:- 基本结构体类型协议
public protocol BasicStructProtocol {}
extension Bool: BasicStructProtocol {}
extension Int: BasicStructProtocol {}
extension String: BasicStructProtocol {}

//MARK:- Bool字符串集合
public struct BoolString {
    public static let trues = ["TRUE", "True", "true", "YES", "Yes", "yes", "1"]
    public static let falses = ["FALSE", "False", "false", "NO", "No", "no", "0"]
}

//MARK:- 响应模型协议
public protocol ResponseProtocol {
    
    associatedtype R
    
    var code: Int? { set get }
    var status : String? { set get }
    var total : Int? { set get }
    var result : R? { set get }
    var message : String? { set get }
}

//MARK:- 泛型模型装配 通用 result是模型
struct Response<T: Mappable>: ResponseProtocol, Mappable {

    /// 这个其实可以不写 隐式转换了
    typealias R = T
    
    var code: Int?
    var status : String?
    var total : Int?
    var result : T?
    var message : String?
    
    init?(map: Map) {
        
    }
    
    // 这个地方的字符串可以进行转译映射 这个可控制性更强
    mutating func mapping(map: Map) {
        code <- map[MappingTable.share.code]
        status <- map[MappingTable.share.status]
        total <- map[MappingTable.share.total]
        result <- map[MappingTable.share.result]
        message <- map[MappingTable.share.message]
    }
}

//MARK:- 响应模型数组协议
public protocol ResponseArrayProtocol {
    
    associatedtype R
    
    var code: Int? { set get }
    var status : String? { set get }
    var total : Int? { set get }
    var result : [R]? { set get }
    var message : String? { set get }
}

//MARK:- 泛型模型数组装配 通用 result是模型数组
struct ResponseArray<T: Mappable>: ResponseArrayProtocol, Mappable {
    
    typealias R = T
    
    var code: Int?
    var status : String?
    var total : Int?
    var result : [T]?
    var message : String?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        code <- map[MappingTable.share.code]
        status <- map[MappingTable.share.status]
        total <- map[MappingTable.share.total]
        result <- map[MappingTable.share.result]
        message <- map[MappingTable.share.message]
    }
}

//MARK:- 响应基本类型协议
public protocol ResponseBaseProtocol {
    
    associatedtype R
    
    var code: Int? { set get }
    var status : String? { set get }
    var total : Int? { set get }
    var result : R? { set get }
    var message : String? { set get }
    
    var isJump: Bool { set get }
}

// MARK:- 判断字符串类型的bool值类型
extension ResponseBaseProtocol {
    mutating func checkStringToBool(map: Map) {
        if let string = map.JSON[MappingTable.share.result] as? String {
            let bool: Bool
            
            if BoolString.trues.contains(string) || (string as NSString).integerValue > 0 {
                bool = true
            }else if BoolString.falses.contains(string) || (string as NSString).integerValue <= 0 {
                bool = false
            }else {
                bool = false
            }
            
            result = bool as? R
            
            //  这里其实判断的是T与Bool类型是否匹配,如果匹配说明是String转Bool,否则的话其实String转String,是不能Jump的
            if let _ = result {
                isJump = true
            }
        }
    }

}

//MARK:- 泛型基本类型装配 通用 result是基本类型(Int Bool String)
struct ResponseBase<T: BasicStructProtocol>: ResponseBaseProtocol, Mappable {
    
    typealias R = T
    
    var code: Int?
    var status : String?
    var total : Int?
    var result : T?
    var message : String?
    
    var isJump = false
    
    init?(map: Map) {
        checkStringToBool(map: map)
    }
    
    mutating func mapping(map: Map) {
        code <- map[MappingTable.share.code]
        status <- map[MappingTable.share.status]
        total <- map[MappingTable.share.total]
        if !isJump {
            result <- map[MappingTable.share.result]
        }
        message <- map[MappingTable.share.message]
    }
}


//----------- 以下还没有来得急实践,但是思路肯定是对的 ----------- //

//MARK:- 响应全泛型 模型类型协议
protocol ResponseGenericProtocol {
    
    associatedtype C
    associatedtype S
    associatedtype T
    associatedtype R
    associatedtype M
    
    var code: C? { set get }
    var status: S? { set get }
    var total: T? { set get }
    var result: R? { set get }
    var message: M? { set get }
}

//MARK:- 泛型模型装配 泛型类型系列
struct ResponseGeneric<Code, Status, Total, Reslut: Mappable, Message>: ResponseGenericProtocol, Mappable {
    
    typealias C = Code
    typealias S = Status
    typealias T = Total
    typealias R = Reslut
    typealias M = Message
    
    var code: Code?
    var status: Status?
    var total: Total?
    var result: Reslut?
    var message: Message?
    
    init?(map: Map) {
        
    }
    
    // 这个地方的字符串可以进行转译映射 这个可控制性更强
    mutating func mapping(map: Map) {
        code <- map[MappingTable.share.code]
        status <- map[MappingTable.share.status]
        total <- map[MappingTable.share.total]
        result <- map[MappingTable.share.result]
        message <- map[MappingTable.share.message]
    }
}

//MARK:- 响应全泛型 模型数组类型协议
protocol ResponseArrayGenericProtocol {
    
    associatedtype C
    associatedtype S
    associatedtype T
    associatedtype R
    associatedtype M
    
    var code: C? { set get }
    var status: S? { set get }
    var total: T? { set get }
    var result: [R]? { set get }
    var message: M? { set get }
}

//MARK:- 泛型模型数组装配 泛型类型系列
struct ResponseArrayGeneric<Code, Status, Total, Reslut: Mappable, Message>: ResponseArrayGenericProtocol, Mappable {
    
    typealias C = Code
    typealias S = Status
    typealias T = Total
    typealias R = Reslut
    typealias M = Message
    
    var code: Code?
    var status: Status?
    var total: Total?
    var result: [Reslut]?
    var message: Message?
    
    init?(map: Map) {
        
    }
    
    // 这个地方的字符串可以进行转译映射 这个可控制性更强
    mutating func mapping(map: Map) {
        code <- map[MappingTable.share.code]
        status <- map[MappingTable.share.status]
        total <- map[MappingTable.share.total]
        result <- map[MappingTable.share.result]
        message <- map[MappingTable.share.message]
    }
}
