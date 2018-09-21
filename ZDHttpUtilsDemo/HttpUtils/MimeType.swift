//
//  MimeType.swift
//  ZDHttpUtilsDemo
//
//  Created by season on 2018/9/21.
//  Copyright © 2018年 season. All rights reserved.
//

import Foundation

/// 网络上传多媒体类型
enum MimeType {
    
    case
    image(String?),
    gif(String?),
    video(String?)
    
    func getMimeTypeString() -> String {
        switch self {
        case .image:
            return "image/*"
        case .gif:
            return "image/gif"
        case .video:
            return "video/*"
        }
    }
    
    /// 获取默认的上传名字
    func getDefaultFileName() -> String {
        switch self {
        case .image(let name):
            return name ?? ".jpg"
        case .gif(let name):
            return name ?? ".gif"
        case .video(let name):
            return name ?? ".mp4"
        }
    }
}
