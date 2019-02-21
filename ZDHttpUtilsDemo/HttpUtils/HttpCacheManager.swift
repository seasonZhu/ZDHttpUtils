//
//  HttpCacheManager.swift
//  ZDHttpUtilsDemo
//
//  Created by season on 2018/9/20.
//  Copyright © 2018年 season. All rights reserved.
//

import Foundation

// MARK: - 网络请求缓存本地化处理
public class HttpCacheManager {
    
    /// 读写队列
    static let ioQueue = DispatchQueue(label: "com.lostsakura.season.HttpCacheManager")
    
    /// 写数据
    ///
    /// - Parameters:
    ///   - data: 数据
    ///   - url: url
    ///   - callback: 是否写入成功的回调
    static func write(data: Data?, by url: String, callback: ((Bool) -> ())? = nil) {
        ioQueue.sync {
            let filePath = getFilePath(url: url)
            let fileUrl = URL(fileURLWithPath: filePath)
            do {
                try data?.write(to: fileUrl)
                DispatchQueue.main.async {
                    callback?(true)
                }
            } catch _ {
                DispatchQueue.main.async {
                    callback?(false)
                }
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
        let data = try? Data(contentsOf: pathUrl)
        let dict = data?.toDictionary
        return dict
    }
    
    /// 通过url获取文件缓存并转为字符串
    ///
    /// - Parameter url: url
    /// - Returns: 字符串
    static func getCacheString(url: String) -> String? {
        let pathUrl = URL(fileURLWithPath: getFilePath(url: url))
        let string = try? String(contentsOf: pathUrl, encoding: .utf8)
        return string
    }
    
    /// 通过url获取断点续传需要的数据
    ///
    /// - Parameter url: url
    /// - Returns: 数据
    static func getResumeData(url: String) -> Data? {
        let pathUrl = URL(fileURLWithPath: getFilePath(url: url))
        let data = try? Data(contentsOf: pathUrl)
        return data
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
}

// MARK: - 对外方法
extension HttpCacheManager {
    /// 通过传递的路径判断 文件或者文件夹, 如果不存在就进行创建, 这个方法一定要调用呀
    ///
    /// - Parameter path: 路径
    public static func checkDirectory(path: String = httpUtilsCachePath) {
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
                //#if DEBUG
                print("The \(path) is Exist ")
                //#endif
            }
        }
    }
    
    /// 缓存文件夹路径
    public static var httpUtilsCachePath: String {
        let path = NSHomeDirectory() + "/Library/HttpUtilsCache"
        #if DEBUG
        print("path: \(path)")
        #endif
        return path
    }
    
    /// 清理本地缓存的json数据
    public class func clearDiskCache() {
        ioQueue.sync {
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

extension Data: DataTransformProtocol {
    typealias A = Any?
    
    typealias D = [String: Any]?
    
    typealias L = [Any]?
    
    typealias DL = [[String: Any]]?
    
    var toAny: Any? {
        do{
            let any = try JSONSerialization.jsonObject(with: self, options: .mutableContainers)
            return any
        }catch {
            print("data转换Any失败")
            return nil
        }
    }
    
    var toDictionary: [String: Any]? {
        guard let dict = toAny as? [String: Any] else {
            print("data转换字典失败")
            return nil
        }
        return dict
    }
    
    var toArray: [Any]? {
        guard let array = toAny as? [Any] else {
            print("data转换数组失败")
            return nil
        }
        return array
    }
    
    var toDictionaryArray: [[String: Any]]? {
        guard let dictArray = toArray as? [[String: Any]] else {
            print("data转换字典数组失败")
            return nil
        }
        return dictArray
    }
}

/// Data转换协议
protocol DataTransformProtocol {
    associatedtype A
    associatedtype D
    associatedtype L
    associatedtype DL
    
    /// A -> Any缩写
    var toAny: A { get }
    
    /// D -> Dictionary缩写
    var toDictionary: D { get }
    
    /// L -> List 亦即 Array
    var toArray: L { get }
    
    /// DL -> Dictionar List 亦即 Dictionary Array
    var toDictionaryArray: DL { get }
}
