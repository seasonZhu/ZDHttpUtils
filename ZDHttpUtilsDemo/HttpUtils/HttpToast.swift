//
//  HttpToast.swift
//  ZDHttpUtilsDemo
//
//  Created by season on 2018/10/8.
//  Copyright © 2018 season. All rights reserved.
//

import UIKit
import Toast_Swift

let kHubTag = 10001

//MARK:- 吐司显示

/// 吐司显示
///
/// - Parameter message: 信息
func showToast(_ message: String) {

    guard let topVC = UIApplication.topViewController() else {
        return
    }
    topVC.view.makeToast(message)
    
    //  cocopods集成 会说AppDelegate有问题
    //    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
    //        return
    //    }
    //    appDelegate.window?.rootViewController?.view.makeToast(message)
    
    //appDelegate.window?.rootViewController?.view.makeToast(message, position: .center, title: "哈哈", image: UIImage(named: "weibo_icon")) 可以进行多种配置
}

//MARK:- 吐司菊花转显示

/// 吐司菊花转
///
/// - Parameter backgroundColor: 背景色
func showActivity(backgroundColor: UIColor? = nil) {
    guard let topVC = UIApplication.topViewController() else {
        return
    }
    
    let hud = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    hud.tag = kHubTag
    hud.backgroundColor = backgroundColor
    topVC.view.addSubview(hud)
    topVC.view.makeToastActivity(.center)
}

//MARK:- 吐司菊花转隐藏

/// 吐司菊花转隐藏
func hideActivity() {
    
    guard let topVC = UIApplication.topViewController() else {
        return
    }
    
    for subview in topVC.view.subviews where subview.tag == kHubTag {
        subview.removeFromSuperview()
    }
    
    topVC.view.hideToastActivity()
}

// MARK: - 获取顶层的控制器
extension UIApplication {
    static func topViewController(_ rootVC: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = rootVC as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        
        if let tab = rootVC as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        
        if let presented = rootVC?.presentedViewController {
            return topViewController(presented)
        }
        
        return rootVC
    }
}
