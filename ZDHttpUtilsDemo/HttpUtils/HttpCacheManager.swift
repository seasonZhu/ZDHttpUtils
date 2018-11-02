//
//  HttpCacheManager.swift
//  ZDHttpUtilsDemo
//
//  Created by season on 2018/9/20.
//  Copyright © 2018年 season. All rights reserved.
//

import Foundation

// MARK: - 网络请求缓存本地化处理
class HttpCacheManager {
    
    /// 写数据
    ///
    /// - Parameters:
    ///   - data: 数据
    ///   - url: url
    ///   - callback: 是否写入成功的回调
    static func write(data: Data?, by url: String, callback: ((Bool) -> ())? = nil) {
        let ioQueue = DispatchQueue(label: "com.lostsakura.season")
        ioQueue.async {
            let filePath = getFilePath(url: url)
            let fileUrl = URL(fileURLWithPath: filePath)
            do {
                try data?.write(to: fileUrl)
                callback?(true)
            } catch _ {
                callback?(false)
            }
        }
    }
    
    /// 获取url获取文件在缓存中路径
    ///
    /// - Parameter url: url
    /// - Returns: 路径字符串
    static func getFilePath(url: String) -> String {
        return httpUtilsCachePath + "/" + url.swiftMd5
    }
    
    /// 通过url获取文件缓存并转为字典
    ///
    /// - Parameter url: url
    /// - Returns: 字典
    static func getCacheDict(url: String) -> [String: Any]? {
        let pathUrl = URL.init(fileURLWithPath: getFilePath(url: url))
        let data = try? Data.init(contentsOf: pathUrl)
        let dict = data?.toDict
        return dict
    }
    
    /// 通过url获取文件缓存并转为字符串
    ///
    /// - Parameter url: url
    /// - Returns: 字符串
    static func getCacheString(url: String) -> String? {
        let pathUrl = URL.init(fileURLWithPath: getFilePath(url: url))
        let string = try? String.init(contentsOf: pathUrl, encoding: .utf8)
        return string
    }
    
    /// 通过传递的路径判断 文件或者文件夹, 如果不存在就进行创建, 这个方法一定要调用呀
    ///
    /// - Parameter path: 路径
    static func checkDirectory(path: String = httpUtilsCachePath) {
        let fileManager = FileManager.default
        
        //  是否是文件夹
        var isDir: ObjCBool = false
        if !fileManager.fileExists(atPath: path, isDirectory: &isDir) {
            createBaseDirectory(at: path)
        }else {
            if !isDir.boolValue {
                do {
                    try fileManager.removeItem(atPath: path)
                    createBaseDirectory(at: path)
                }catch {
                    #if DEBUG
                    print("removeItem at Path Error")
                    #endif
                }
            }else {
                #if DEBUG
                print("The \(path) is Exist ")
                #endif
            }
        }
    }
    
    /// 缓存文件夹路径
    class var httpUtilsCachePath: String {
        let path = NSHomeDirectory() + "/Library/HttpUtilsCache"
        #if DEBUG
        print("path: \(path)")
        #endif
        return path
    }
    
    /// 创建基本文件夹
    ///
    /// - Parameter path: 文件夹所在的路径
    private static func createBaseDirectory(at path: String) {
        do {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            addDoNotBackupAttribute(path: path)
        }catch {
            #if DEBUG
            print("create cache directory failed")
            #endif
        }
    }
    
    private static func addDoNotBackupAttribute(path: String) {
        var url = URL.init(fileURLWithPath: path)
        url.setTemporaryResourceValue(true, forKey: URLResourceKey.isExcludedFromBackupKey)
    }
    
    /// 清理本地缓存的json数据
    class func clearDiskCache() {
        DispatchQueue.global().async {
            do {
                try FileManager.default.removeItem(atPath: httpUtilsCachePath)
                checkDirectory()
            }catch {
                #if DEBUG
                print("clearDiskCache error")
                #endif
            }
        }
    }
}

private extension Data {
    var toDict: [String: Any]? {
        do{
            let json = try JSONSerialization.jsonObject(with: self, options: .mutableContainers)
            
            guard let dic = json as? Dictionary<String, Any> else {
                return nil
            }
            
            return dic
            
        }catch {
            #if DEBUG
            print("data转Dict失败")
            #endif
            return nil
        }
    }
}
