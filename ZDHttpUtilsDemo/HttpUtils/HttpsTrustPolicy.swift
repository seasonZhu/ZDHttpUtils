//
//  HttpsTrustPolicy.swift
//  ZDHttpUtilsDemo
//
//  Created by season on 2018/12/28.
//  Copyright © 2018 season. All rights reserved.
//

import Foundation
import Alamofire

/// 服务器认证策略,你没有看错,我就是从Alamofire的ServerTrustPolicy基本拷贝了一份过来,因为我需要的通过路径去找,其实完全是可以使用原来的枚举的,可惜枚举不能继承
public enum HttpsServerTrustPolicy {
    case performDefaultEvaluation(validateHost: Bool)
    case performRevokedEvaluation(validateHost: Bool, revocationFlags: CFOptionFlags)  //revocationFlags位置为0 崩了 1可以过
    case pinCertificates(cerPath: String, validateCertificateChain: Bool, validateHost: Bool)
    case pinPublicKeys(cerPath: String, validateCertificateChain: Bool, validateHost: Bool)
    case disableEvaluation
    case customEvaluation((_ serverTrust: SecTrust, _ host: String) -> Bool)
    
    /// 全局的服务器认证策略管理器
    static var manager: ServerTrustPolicyManager?
    
    /// 全局的服务器默认认证策略
    static var `default`: HttpsServerTrustPolicy? = .disableEvaluation
    
    /// 获取App中的Bundle里的所有SecCertificate
    ///
    /// - Parameter bundle: Bundle的路径
    /// - Returns: SecCertificate数组
    public static func certificates(in bundle: Bundle = Bundle.main) -> [SecCertificate] {
        var certificates: [SecCertificate] = []
        
        let paths = Set([".cer", ".CER", ".crt", ".CRT", ".der", ".DER"].map { fileExtension in
            bundle.paths(forResourcesOfType: fileExtension, inDirectory: nil)
            }.joined())
        
        for path in paths {
            if
                let certificateData = try? Data(contentsOf: URL(fileURLWithPath: path)) as CFData,
                let certificate = SecCertificateCreateWithData(nil, certificateData) {
                certificates.append(certificate)
            }
        }
        
        return certificates
    }
    
    /// 获取App中的Bundle里的所有SecKey
    ///
    /// - Parameter bundle: Bundle的路径
    /// - Returns: SecKey数组
    public static func publicKeys(in bundle: Bundle = Bundle.main) -> [SecKey] {
        var publicKeys: [SecKey] = []
        
        for certificate in certificates(in: bundle) {
            if let publicKey = publicKey(for: certificate) {
                publicKeys.append(publicKey)
            }
        }
        
        return publicKeys
    }
    
    /// 与服务端进行验证
    ///
    /// - Parameters:
    ///   - serverTrust: SecTrust
    ///   - host: host
    /// - Returns: 验证结果
    public func evaluate(_ serverTrust: SecTrust, forHost host: String) -> Bool {
        var serverTrustIsValid = false
        
        switch self {
        case let .performDefaultEvaluation(validateHost):
            let policy = SecPolicyCreateSSL(true, validateHost ? host as CFString : nil)
            SecTrustSetPolicies(serverTrust, policy)
            
            serverTrustIsValid = trustIsValid(serverTrust)
        case let .performRevokedEvaluation(validateHost, revocationFlags):
            let defaultPolicy = SecPolicyCreateSSL(true, validateHost ? host as CFString : nil)
            let revokedPolicy = SecPolicyCreateRevocation(revocationFlags)
            SecTrustSetPolicies(serverTrust, [defaultPolicy, revokedPolicy] as CFTypeRef)
            
            serverTrustIsValid = trustIsValid(serverTrust)
        case let .pinCertificates(cerPath, validateCertificateChain, validateHost):
            
            //  读取本地证书数据
            let cerUrl = URL(fileURLWithPath: cerPath)
            guard
                let localCertificateData = try? Data(contentsOf: cerUrl) as CFData,
                let pinnedCertificate = SecCertificateCreateWithData(nil, localCertificateData) else {
                return false
            }
            
            let pinnedCertificates = [pinnedCertificate]
            
            if validateCertificateChain {
                let policy = SecPolicyCreateSSL(true, validateHost ? host as CFString : nil)
                SecTrustSetPolicies(serverTrust, policy)
                
                SecTrustSetAnchorCertificates(serverTrust, pinnedCertificates as CFArray)
                SecTrustSetAnchorCertificatesOnly(serverTrust, true)
                
                serverTrustIsValid = trustIsValid(serverTrust)
            } else {
                let serverCertificatesDataArray = certificateData(for: serverTrust)
                let pinnedCertificatesDataArray = certificateData(for: pinnedCertificates)
                
                outerLoop: for serverCertificateData in serverCertificatesDataArray {
                    for pinnedCertificateData in pinnedCertificatesDataArray {
                        if serverCertificateData == pinnedCertificateData {
                            serverTrustIsValid = true
                            break outerLoop
                        }
                    }
                }
            }
        case let .pinPublicKeys(cerPath, validateCertificateChain, validateHost):
            
            //  读取本地证书数据
            let cerUrl = URL(fileURLWithPath: cerPath)
            guard
                let localCertificateData = try? Data(contentsOf: cerUrl) as CFData,
                let pinnedCertificate = SecCertificateCreateWithData(nil, localCertificateData),
                let pinnedPublicKey = HttpsServerTrustPolicy.publicKey(for: pinnedCertificate) else {
                    return false
            }
            let pinnedPublicKeys = [pinnedPublicKey]
            
            var certificateChainEvaluationPassed = true
            
            if validateCertificateChain {
                let policy = SecPolicyCreateSSL(true, validateHost ? host as CFString : nil)
                SecTrustSetPolicies(serverTrust, policy)
                
                certificateChainEvaluationPassed = trustIsValid(serverTrust)
            }
            
            if certificateChainEvaluationPassed {
                outerLoop: for serverPublicKey in HttpsServerTrustPolicy.publicKeys(for: serverTrust) as [AnyObject] {
                    for pinnedPublicKey in pinnedPublicKeys as [AnyObject] {
                        if serverPublicKey.isEqual(pinnedPublicKey) {
                            serverTrustIsValid = true
                            break outerLoop
                        }
                    }
                }
            }
        case .disableEvaluation:
            serverTrustIsValid = true
        case let .customEvaluation(closure):
            serverTrustIsValid = closure(serverTrust, host)
        }
        
        return serverTrustIsValid
    }
    
    /// 认证方法
    ///
    /// - Parameter trust: SecTrust
    /// - Returns: 验证结果
    private func trustIsValid(_ trust: SecTrust) -> Bool {
        var isValid = false
        
        var result = SecTrustResultType.invalid
        let status = SecTrustEvaluate(trust, &result)
        
        if status == errSecSuccess {
            let unspecified = SecTrustResultType.unspecified
            let proceed = SecTrustResultType.proceed
            
            
            isValid = result == unspecified || result == proceed
        }
        
        return isValid
    }
    
    /// 通过SecTrust获取其数据数组
    ///
    /// - Parameter trust: SecTrust
    /// - Returns: 数据数组
    private func certificateData(for trust: SecTrust) -> [Data] {
        var certificates: [SecCertificate] = []
        
        for index in 0..<SecTrustGetCertificateCount(trust) {
            if let certificate = SecTrustGetCertificateAtIndex(trust, index) {
                certificates.append(certificate)
            }
        }
        
        return certificateData(for: certificates)
    }
    
    /// SecCertificate数组转Data数组
    ///
    /// - Parameter certificates: SecCertificate数组
    /// - Returns: Data数组
    private func certificateData(for certificates: [SecCertificate]) -> [Data] {
        return certificates.map { SecCertificateCopyData($0) as Data }
    }
    
    /// 通过SecTrust获取SecKey数组
    ///
    /// - Parameter trust: SecTrust
    /// - Returns: SecKey数组
    private static func publicKeys(for trust: SecTrust) -> [SecKey] {
        var publicKeys: [SecKey] = []
        
        for index in 0..<SecTrustGetCertificateCount(trust) {
            if
                let certificate = SecTrustGetCertificateAtIndex(trust, index),
                let publicKey = publicKey(for: certificate)
            {
                publicKeys.append(publicKey)
            }
        }
        
        return publicKeys
    }
    
    /// 通过SecCertificate获取SecKey
    ///
    /// - Parameter certificate: SecCertificate
    /// - Returns: SecKey
    private static func publicKey(for certificate: SecCertificate) -> SecKey? {
        var publicKey: SecKey?
        
        let policy = SecPolicyCreateBasicX509()
        var trust: SecTrust?
        let trustCreationStatus = SecTrustCreateWithCertificates(certificate, policy, &trust)
        
        if let trust = trust, trustCreationStatus == errSecSuccess {
            publicKey = SecTrustCopyPublicKey(trust)
        }
        
        return publicKey
    }
}

/// 客户端认证策略
struct ClientTrustPolicy {
    /// 定义认证错误
    ///
    /// - pathError: 路径错误
    /// - passwordError: 密码错误
    /// - unknownError: 未知错误
    enum IdentityError: Error, CustomStringConvertible {
        case pathError
        case passwordError
        case unknownError
        
        var description: String {
            switch self {
            case .pathError:
                return "路径错误"
            case .passwordError:
                return "密码错误"
            case .unknownError:
                return "未知错误"
            }
        }
    }
    
    /// 存储认证相关信息的结构体
    struct IdentityAndTrust {
        var identityRef: SecIdentity
        var trust: SecTrust
        var certArray: AnyObject
    }
    
    /// 存储认证相关信息
    ///
    /// - Parameters:
    ///   - p12Path: p12证书路径
    ///   - password: p12证书密码
    /// - Returns: 认证相关信息
    /// - Throws: 抛出异常
    static func extractIdentity(p12Path: String, p12password: String) throws -> IdentityAndTrust {
        
        var identityAndTrust: IdentityAndTrust!
        var securityError: OSStatus = errSecSuccess
        
        guard let PKCS12Data = try? Data(contentsOf: URL(fileURLWithPath: p12Path)) else {
            throw IdentityError.pathError
        }
        
        let key = kSecImportExportPassphrase as NSString
        let options = [key: p12password]
        
        var items: CFArray?
        securityError = SecPKCS12Import(PKCS12Data as CFData, options as CFDictionary, &items)
        
        if securityError == errSecSuccess,
            let certItems = items,
            let dict = (certItems as Array).first,
            let certEntry = dict as? [String: AnyObject],
            let identityPointer = certEntry["identity"],
            let trustPointer = certEntry["trust"],
            let chainPointer = certEntry["chain"] {
            
            let secIdentityRef = identityPointer as! SecIdentity
            let trustRef = trustPointer as! SecTrust
            identityAndTrust = IdentityAndTrust(identityRef: secIdentityRef, trust: trustRef, certArray: chainPointer)
        } else {
            throw IdentityError.passwordError
        }
        
        return identityAndTrust
    }
}
