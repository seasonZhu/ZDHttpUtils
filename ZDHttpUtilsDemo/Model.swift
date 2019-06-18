//
//  Model.swift
//  ZDHttpUtilsDemo
//
//  Created by season on 2018/9/20.
//  Copyright © 2018年 season. All rights reserved.
//

import Foundation


//MARK:- 网络请求测试用例
struct Item: Codable {
    
    var topicImageUrl: String?
    var topicOrder: Int?
    var id: Int?
    var upTime: String?
    var topicStatus: Int?
    var topicTittle: String?
    var topicDesc: String?
}
