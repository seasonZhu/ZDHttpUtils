//
//  HttpUtil+OtherError.swift
//  ZDHttpUtilsDemo
//
//  Created by season on 2018/12/19.
//  Copyright © 2018 season. All rights reserved.
//

import Foundation

extension HttpUtils {
    /// 信息类型
    ///
    /// - networkNotReachable: 无网络
    /// - writeJSONCacheFailed: 写入JSON缓存失败
    /// - readJSONCacheFailed: 读取JSON缓存失败
    /// - writeDownloadResumeDataFailed: 写入下载的ResumeData失败
    public enum OtherError: Error {
        case networkNotReachable
        case writeJSONCacheFailed
        case readJSONCacheFailed
        case writeDownloadResumeDataFailed
    }
}

extension HttpUtils.OtherError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .networkNotReachable:
            return "无网络"
        case .writeJSONCacheFailed:
            return "写入JSON数据失败"
        case .readJSONCacheFailed:
            return "读取JSON缓存失败"
        case .writeDownloadResumeDataFailed:
            return "写入下载的ResumeData失败"
        }
    }
}
