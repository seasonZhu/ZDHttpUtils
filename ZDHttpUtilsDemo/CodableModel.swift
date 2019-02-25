//
//  File.swift
//  ZDHttpUtilsDemo
//
//  Created by season on 2019/2/25.
//  Copyright © 2019 season. All rights reserved.
//

import Foundation

struct ListItem: Codable {
    var topicOrder: Int?
    var id: Int?
    var topicDesc: String?
    var topicTittle: String?
    var upTime: String?
    var topicImageUrl: String?
    var topicStatus: Int?
}

struct ExampleModelName: Codable {
    var list: [ListItem]?
    var code: Int?
}
