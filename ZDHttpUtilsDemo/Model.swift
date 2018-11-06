//
//  Model.swift
//  ZDHttpUtilsDemo
//
//  Created by season on 2018/9/20.
//  Copyright © 2018年 season. All rights reserved.
//

import Foundation
import ObjectMapper

//MARK:- 网络请求测试用例
struct Item: Mappable {
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        topicImageUrl <- map["topicImageUrl"]
        topicOrder <- map["topicOrder"]
        id <- map["id"]
        upTime <- map["upTime"]
        topicStatus <- map["topicStatus"]
        topicTittle <- map["topicTittle"]
        topicDesc <- map["topicDesc"]
    }
    
    var topicImageUrl: String?
    var topicOrder: Int?
    var id: Int?
    var upTime: String?
    var topicStatus: Int?
    var topicTittle: String?
    var topicDesc: String?
}
