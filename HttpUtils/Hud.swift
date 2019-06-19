//
//  Hud.swift
//  SwiftHud
//
//  Created by season on 2018/10/9.
//  Copyright © 2018 season. All rights reserved.
//

import UIKit

/*
 * 这本是一个对外的public类,是我自己写的,这里为了方便使用和避免冲突,私有化了
 */

/// 自动完成后的回调
typealias CompleteHandle = () -> Void

/// 点击通知栏的ToolBar回调
typealias ToolbarTapHandle = CompleteHandle

// MARK:- Hud

/// 对外的Hud类
class Hud {
    
    /// 非showOnNavigationBar的整体背景颜色
    static var backgroundColor: UIColor = .clear {
        didSet {
            HudInternal.backgroundColor = backgroundColor
        }
    }
    
    /// 非showOnNavigationBar的mainView的背景颜色
    static var mainColor: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8) {
        didSet {
            HudInternal.mainColor = mainColor
        }
    }
    
    /// 非showOnNavigationBar的文字显示颜色和绘制的颜色
    static var textColor: UIColor = .white {
        didSet {
            HudInternal.textColor = textColor
            HudGraph.drawColor = textColor
        }
    }
    
    /// 菊花转的颜色
    static var indicatorColor: UIColor = .white {
        didSet {
            HudInternal.indicatorColor = indicatorColor
        }
    }
    
    /// 显示消息
    ///
    /// - Parameters:
    ///   - message: 信息
    ///   - autoClear: 是否自动移除
    ///   - autoClearTime: 移除的延迟时间
    ///   - responseTap: 是否响应点击移除
    ///   - completeHandle: 自动移除后的操作响应
    /// - Returns: 返回window
    @discardableResult
    static func showMessage(message: String, autoClear: Bool = true, autoClearTime: TimeInterval = 3, responseTap: Bool = false, completeHandle: CompleteHandle? = nil) -> UIWindow? {
        guard let _ = UIApplication.shared.keyWindow else { return nil }
        return HudInternal.showMessage(message: message, autoClear: autoClear, autoClearTime: autoClearTime, responseTap: responseTap, completeHandle: completeHandle)
    }
    
    /// 显示等待
    ///
    /// - Parameters:
    ///   - message: 信息
    ///   - autoClear: 是否自动移除
    ///   - autoClearTime: 移除的延迟时间
    ///   - responseTap: 是否响应点击移除
    ///   - completeHandle: 自动移除后的操作响应
    /// - Returns: 返回window
    @discardableResult
    static func showWait(message: String? = nil, autoClear: Bool = true, autoClearTime: TimeInterval = 3, responseTap: Bool = false, completeHandle: CompleteHandle? = nil) -> UIWindow? {
        guard let _ = UIApplication.shared.keyWindow else { return nil }
        return HudInternal.showWait(message:message, autoClear:autoClear, autoClearTime:autoClearTime, responseTap:responseTap, completeHandle:completeHandle)
    }
    
    /// 显示成功
    ///
    /// - Parameters:
    ///   - message: 信息
    ///   - autoClear: 是否自动移除
    ///   - autoClearTime: 移除的延迟时间
    ///   - responseTap: 是否响应点击移除
    ///   - completeHandle: 自动移除后的操作响应
    /// - Returns: 返回window
    @discardableResult
    static func showSuccess(message: String, autoClear: Bool = true, autoClearTime: TimeInterval = 3, responseTap: Bool = false, completeHandle: CompleteHandle? = nil) -> UIWindow? {
        guard let _ = UIApplication.shared.keyWindow else { return nil }
        return HudInternal.showNotice(type: .success, message: message, autoClear: autoClear, autoClearTime: autoClearTime, responseTap: responseTap, completeHandle: completeHandle)
    }
    
    /// 显示失败
    ///
    /// - Parameters:
    ///   - message: 信息
    ///   - autoClear: 是否自动移除
    ///   - autoClearTime: 移除的延迟时间
    ///   - responseTap: 是否响应点击移除
    ///   - completeHandle: 自动移除后的操作响应
    /// - Returns: 返回window
    @discardableResult
    static func showFail(message: String, autoClear: Bool = true, autoClearTime: TimeInterval = 3, responseTap: Bool = false, completeHandle: CompleteHandle? = nil) -> UIWindow? {
        guard let _ = UIApplication.shared.keyWindow else { return nil }
        return HudInternal.showNotice(type: .fail, message: message, autoClear: autoClear, autoClearTime: autoClearTime, responseTap: responseTap, completeHandle: completeHandle)
    }
    
    /// 显示信息
    ///
    /// - Parameters:
    ///   - message: 信息
    ///   - autoClear: 是否自动移除
    ///   - autoClearTime: 移除的延迟时间
    ///   - responseTap: 是否响应点击移除
    ///   - completeHandle: 自动移除后的操作响应
    /// - Returns: 返回window
    @discardableResult
    static func showInfo(message: String, autoClear: Bool = true, autoClearTime: TimeInterval = 3, responseTap: Bool = false, completeHandle: CompleteHandle? = nil) -> UIWindow? {
        guard let _ = UIApplication.shared.keyWindow else { return nil }
        return HudInternal.showNotice(type: .info, message: message, autoClear: autoClear, autoClearTime: autoClearTime, responseTap: responseTap, completeHandle: completeHandle)
    }
    
    /// 显示 可以通过枚举进而进行更多的自定义
    ///
    /// - Parameters:
    ///   - type: HudType的类型
    ///   - message: 信息
    ///   - autoClear: 是否自动移除
    ///   - autoClearTime: 移除的延迟时间
    ///   - responseTap: 是否响应点击移除
    ///   - completeHandle: 自动移除后的操作响应
    /// - Returns: 返回window
    @discardableResult
    static func showNotice(type: HudType = .info, message: String, autoClear: Bool = true, autoClearTime: TimeInterval = 3, responseTap: Bool = false, completeHandle: CompleteHandle? = nil) -> UIWindow? {
        guard let _ = UIApplication.shared.keyWindow else { return nil }
        return HudInternal.showNotice(type: type, message: message, autoClear: autoClear, autoClearTime: autoClearTime, responseTap: responseTap, completeHandle: completeHandle)
    }
    
    /// 显示Gif
    ///
    /// - Parameters:
    ///   - images: 图片数组
    ///   - autoClear: 是否自动移除
    ///   - autoClearTime: 移除的延迟时间
    ///   - responseTap: 是否响应点击移除
    ///   - completeHandle: 自动移除后的操作响应
    ///   - timeMilliseconds: 动画时长,越短动画的节奏越快
    ///   - scale: 图片与mainView的比例,我这里用的黄金比例
    ///   - completeHandle: 自动移除后的操作响应
    /// - Returns: 返回window
    @discardableResult
    static func showAnimate(images: [UIImage], autoClear: Bool = true, autoClearTime: TimeInterval = 3, responseTap: Bool = false, timeMilliseconds: Int = 70, scale: CGFloat = 0.618, completeHandle: CompleteHandle? = nil) -> UIWindow? {
        guard let _ = UIApplication.shared.keyWindow else { return nil }
        return HudInternal.showAnimate(images: images, autoClear: autoClear, autoClearTime: autoClearTime, responseTap: responseTap, timeMilliseconds: timeMilliseconds, scale: scale, completeHandle: completeHandle)
    }
    
    /// 通知栏的单行文字信息 注意没有做多行处理 如果多了会进入linebreak模式,另外横屏模式下暂时有问题
    ///
    /// - Parameters:
    ///   - message: 信息
    ///   - autoClear: 是否自动移除
    ///   - autoClearTime: 移除的延迟时间
    ///   - textColor: 颜色
    ///   - fontSize: 字体大小
    ///   - backgroundColor: 背景颜色
    ///   - completeHandle: 自动移除后的操作响应
    /// - Returns: 返回window
    @discardableResult
    static func showOnNavigationBar(message: String, autoClear: Bool = true, autoClearTime: TimeInterval = 3, textColor: UIColor = .black, fontSize: CGFloat = 13, backgroundColor: UIColor? = nil , toolbarTapHandle: ToolbarTapHandle? = nil, completeHandle: CompleteHandle? = nil) -> UIWindow? {
        guard let _ = UIApplication.shared.keyWindow else { return nil }
        return HudInternal.showOnNavigationBar(message: message, autoClear: autoClear, autoClearTime: autoClearTime, textColor: textColor, fontSize: fontSize, backgroundColor: backgroundColor, toolbarTapHandle: toolbarTapHandle, completeHandle: completeHandle)
    }
    
    /// 清除Hud
    static func clear() {
        HudInternal.clear()
    }
    
    /// 私有化构造方法
    private init() {}
}

// MARK: - Hud配置化的链式方法,链式方法一定要在show方法之前,否则无效
extension Hud {
    
    /// 设置Hud的背景颜色
    ///
    /// - Parameter backgroundColor: 背景颜色
    /// - Returns: Hud类
    @discardableResult
    static func setBackgroundColor(_ backgroundColor: UIColor) -> Hud.Type {
        self.backgroundColor = backgroundColor
        return type(of: Hud())
    }
    
    /// 设置主颜色
    ///
    /// - Parameter mainColor: 主颜色
    /// - Returns: Hud类
    @discardableResult
    static func setMainColor(_ mainColor: UIColor) -> Hud.Type {
        self.mainColor = mainColor
        return type(of: Hud())
    }
    
    /// 设置文字颜色
    ///
    /// - Parameter textColor: 文字颜色
    /// - Returns: Hud类
    @discardableResult
    static func setTextColor(_ textColor: UIColor) -> Hud.Type {
        self.textColor = textColor
        return type(of: Hud())
    }
    
    /// 设置菊花转颜色
    ///
    /// - Parameter indicatorColor: 菊花转颜色
    /// - Returns: Hud类
    @discardableResult
    static func setIndicatorColor(_ indicatorColor: UIColor) -> Hud.Type {
        self.indicatorColor = indicatorColor
        return type(of: Hud())
    }
    
    /// 设置为默认值
    ///
    /// - Returns: Hud类
    @discardableResult
    static func setDeault() -> Hud.Type {
        backgroundColor = .clear
        mainColor = UIColor(red:0, green:0, blue:0, alpha: 0.8)
        textColor = .white
        indicatorColor = .white
        return type(of: Hud())
    }
}

// MARK:- Hud类型枚举
/// Hud类型枚举
///
/// - success: 成功
/// - fail: 失败
/// - info: 信息
enum HudType {
    case success
    case fail
    case info
}

// MARK:- Hud类型枚举分类获取图片
extension HudType {
    var image: UIImage? {
        let image: UIImage?
        switch self {
        case .success:
            image = HudGraph.imageOfCheckmark
        case .fail:
            image = HudGraph.imageOfCross
        case .info:
            image = HudGraph.imageOfInfo
        }
        return image
    }
}

/// 标记是否是导航栏的通知样式
private let kNaviBarHud = 10001

/// 点击Hud的消失的触发次数
private let kHideHudTaps = 2

/// 倒角的数值
private let kCornerRadius: CGFloat = 8

// MARK:-  Hud对内API
/// Hud对内API
private class HudInternal: NSObject {
    //MARK:- 属性设置
    static var taskQueues = [UIWindow]()
    
    static let rootView = UIApplication.shared.keyWindow?.subviews.first
    
    static var timer: DispatchSource!
    
    static var timerTimes = 0
    
    static var backgroundColor = UIColor.clear
    
    static var mainColor = UIColor(red:0, green:0, blue:0, alpha: 0.8)
    
    static var textColor = UIColor.white
    
    static var indicatorColor = UIColor.white
    
    static var toolbarTapHandle: ToolbarTapHandle?
    
    /// 仅显示文字
    ///
    /// - Parameters:
    ///   - message: 信息
    ///   - autoClear: 是否自动移除
    ///   - autoClearTime: 移除的延迟时间
    ///   - responseTap: 是否响应点击移除
    ///   - completeHandle: 自动移除后的操作响应
    /// - Returns: 返回window
    @discardableResult
    static func showMessage(message: String, autoClear: Bool = true, autoClearTime: TimeInterval = 3, responseTap: Bool = false, completeHandle: CompleteHandle? = nil) -> UIWindow? {
        
        guard let rv = rootView else { return nil }
        
        let window = alertWindow()
        taskQueues.append(window)
        
        let mainView = UIView()
        mainView.layer.cornerRadius = kCornerRadius
        mainView.backgroundColor = mainColor
        window.addSubview(mainView)
        
        let label = UILabel()
        label.text = message
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .center
        label.textColor = textColor
        let size = label.sizeThatFits(CGSize(width: UIScreen.main.bounds.width - 82, height: CGFloat.greatestFiniteMagnitude))
        label.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        mainView.addSubview(label)
        
        let frame = CGRect(x: 0, y: 0, width: label.frame.width + 50 , height: label.frame.height + 30)
        mainView.frame = frame
        label.center = mainView.center
        mainView.center = rv.center
        
        alphaEaseIn(mainView)
        
        addTapGesture(responseTap: responseTap, window: window)
        autoClearAction(autoClear: autoClear, window: window, autoClearTime: autoClearTime, completeHandle: completeHandle)
        
        return window
    }
    
    /// 显示HudType类型的通知
    ///
    /// - Parameters:
    ///   - type: HudType
    ///   - message: 信息
    ///   - autoClear: 是否自动移除
    ///   - autoClearTime: 移除的延迟时间
    ///   - responseTap: 是否响应点击移除
    ///   - completeHandle: 自动移除后的操作响应
    /// - Returns: 返回window
    @discardableResult
    static func showNotice(type: HudType = .info, message: String, autoClear: Bool = true, autoClearTime: TimeInterval = 3, responseTap: Bool = false, completeHandle: CompleteHandle? = nil) -> UIWindow? {
        
        guard let rv = rootView else { return nil }
        
        let window = alertWindow()
        taskQueues.append(window)
        
        var frame = CGRect(x: 0, y: 0, width: 90, height: 90)
        let mainView = UIView()
        mainView.layer.cornerRadius = kCornerRadius
        mainView.backgroundColor = mainColor
        window.addSubview(mainView)
        
        let image = type.image
        let checkmarkView = UIImageView(image: image)
        checkmarkView.frame = CGRect(x: 27, y: 15, width: 36, height: 36)
        mainView.addSubview(checkmarkView)
        
        let label = UILabel(frame: CGRect(x: 0, y: 60, width: 90, height: 16))
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = textColor
        label.text = message
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingMiddle
        label.numberOfLines = 0
        
        var size = label.sizeThatFits(CGSize(width: UIScreen.main.bounds.width - 82, height: CGFloat.greatestFiniteMagnitude))
        
        //  如果字符串的长度大于原有预计的90 需要重新进行计算
        if size.width > 90 {
            label.frame.origin.x = 5
            label.frame.size.width = size.width
            if Int(size.height) % 16 != 0 {
                let ratio = Int(size.height) / 16 + 2
                size.height = CGFloat(ratio) * 16
            }
            label.frame.size.height = size.height
            frame.size.width = size.width + 10
            frame.size.height = size.height + label.frame.minY + 5
            checkmarkView.frame.origin.x = (frame.width - checkmarkView.frame.width) / 2
        }
        
        mainView.addSubview(label)
        mainView.frame = frame
        mainView.center = rv.center
        
        alphaEaseIn(mainView)
        
        addTapGesture(responseTap: responseTap, window: window)
        autoClearAction(autoClear: autoClear, window: window, autoClearTime: autoClearTime, completeHandle: completeHandle)
        
        return window
    }
    
    /// 展示菊花转并可以带多行文字
    ///
    /// - Parameters:
    ///   - message: 信息
    ///   - autoClear: 是否自动移除
    ///   - autoClearTime: 移除的延迟时间
    ///   - responseTap: 是否响应点击移除
    ///   - completeHandle: 自动移除后的操作响应
    /// - Returns: 返回window
    @discardableResult
    static func showWait(message: String? = nil, autoClear: Bool = true, autoClearTime: TimeInterval = 3, responseTap: Bool = false, completeHandle: CompleteHandle? = nil) -> UIWindow? {
        
        guard let rv = rootView else { return nil }
        
        let window = alertWindow()
        taskQueues.append(window)
        
        var frame = CGRect(x: 0, y: 0, width: 90, height: 90)
        let mainView = UIView()
        mainView.layer.cornerRadius = kCornerRadius
        mainView.backgroundColor = mainColor
        window.addSubview(mainView)
        
        #if swift(>=4.2)
        let ai = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
        #else
        let ai = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        #endif
        ai.color = indicatorColor
        
        if let msg = message {
            ai.frame = CGRect(x: 27, y: 15, width: 36, height: 36)
            
            let label = UILabel(frame: CGRect(x: 0, y: 60, width: 90, height: 16))
            label.font = UIFont.systemFont(ofSize: 13)
            label.textColor = textColor
            label.text = msg
            label.lineBreakMode = .byTruncatingMiddle
            label.textAlignment = .center
            label.numberOfLines = 0
            
            var size = label.sizeThatFits(CGSize(width: UIScreen.main.bounds.width - 82, height: CGFloat.greatestFiniteMagnitude))
            
            //  如果字符串的长度大于原有预计的90 需要重新进行计算
            if size.width > 90 {
                label.frame.origin.x = 5
                label.frame.size.width = size.width
                if Int(size.height) % 16 != 0 {
                    let ratio = Int(size.height) / 16 + 2
                    size.height = CGFloat(ratio) * 16
                }
                label.frame.size.height = size.height
                frame.size.width = size.width + 10
                frame.size.height = size.height + label.frame.minY + 5
                ai.frame.origin.x = (frame.width - ai.frame.width) / 2
            }
            
            mainView.addSubview(label)
        }else {
            ai.frame = CGRect(x: 27, y: 27, width: 36, height: 36)
        }
        
        
        ai.startAnimating()
        mainView.addSubview(ai)
        mainView.frame = frame
        mainView.center = rv.center
        
        alphaEaseIn(mainView)
        
        addTapGesture(responseTap: responseTap, window: window)
        autoClearAction(autoClear: autoClear, window: window, autoClearTime: autoClearTime, completeHandle: completeHandle)
        
        return window
    }
    
    /// 播放GIF的wait
    ///
    /// - Parameters:
    ///   - images: 图片数组
    ///   - autoClear: 是否自动移除
    ///   - autoClearTime: 移除的延迟时间
    ///   - responseTap: 是否响应点击移除
    ///   - completeHandle: 自动移除后的操作响应
    ///   - timeMilliseconds: 动画时长,越短动画的节奏越快
    ///   - scale: 图片与mainView的比例,我这里用的黄金比例
    ///   - completeHandle: 自动移除后的操作响应
    /// - Returns: 返回window
    @discardableResult
    static func showAnimate(images: [UIImage], autoClear: Bool = true, autoClearTime: TimeInterval = 3, responseTap: Bool = false, timeMilliseconds: Int = 70, scale: CGFloat = 0.618, completeHandle: CompleteHandle? = nil) -> UIWindow? {
        guard let rv = rootView, images.count > 0 else { return nil }
        
        let window = alertWindow()
        taskQueues.append(window)
        
        let frame = CGRect(x: 0, y: 0, width: 90, height: 90)
        let mainView = UIView()
        mainView.layer.cornerRadius = kCornerRadius
        mainView.backgroundColor = mainColor
        window.addSubview(mainView)
        
        let imgViewFrame = CGRect(x: frame.size.width * (1 - scale) * 0.5, y: frame.size.height * (1 - scale) * 0.5, width: frame.size.width * scale, height: frame.size.height * scale)
        
        if images.count > timerTimes {
            let imageView = UIImageView(frame: imgViewFrame)
            imageView.image = images.first
            imageView.contentMode = .scaleAspectFit
            mainView.addSubview(imageView)
            timer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: UInt(0)), queue: DispatchQueue.main) as? DispatchSource
            timer.schedule(deadline: .now(), repeating: DispatchTimeInterval.milliseconds(timeMilliseconds))
            timer.setEventHandler {
                let image = images[timerTimes % images.count]
                imageView.image = image
                timerTimes += 1
            }
            timer.resume()
        }
        
        mainView.frame = frame
        mainView.center = rv.center
        
        alphaEaseIn(mainView)
        
        addTapGesture(responseTap: responseTap, window: window)
        autoClearAction(autoClear: autoClear, window: window, autoClearTime: autoClearTime, completeHandle: completeHandle)
        
        return window
    }
    
    /// 通知栏的文字信息
    ///
    /// - Parameters:
    ///   - message: 信息
    ///   - autoClear: 是否自动移除
    ///   - autoClearTime: 移除的延迟时间
    ///   - textColor: 颜色
    ///   - fontSize: 字体大小
    ///   - backgroundColor: 背景颜色
    ///   - completeHandle: 自动移除后的操作响应
    /// - Returns: 返回window
    @discardableResult
    static func showOnNavigationBar(message: String, autoClear: Bool = true, autoClearTime: TimeInterval = 3, textColor: UIColor = .black, fontSize: CGFloat = 13, backgroundColor: UIColor? = nil, toolbarTapHandle: ToolbarTapHandle? = nil, completeHandle: CompleteHandle? = nil) -> UIWindow? {
    
        let statusBarFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIApplication.shared.statusBarFrame.height == 0 ? 20 : UIApplication.shared.statusBarFrame.height)
        
        let window = alertWindow()
        window.backgroundColor = UIColor.clear
        taskQueues.append(window)
        
        let toolbar = UIToolbar()
        toolbar.barTintColor = backgroundColor
        toolbar.tag = kNaviBarHud
        window.addSubview(toolbar)
        
        let labelWidth = statusBarFrame.width - 20
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.textColor = textColor
        label.text = message
        label.numberOfLines = 0
        let size = label.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude))
        label.frame = CGRect(x: 10, y: statusBarFrame.height, width: labelWidth, height: size.height)
        toolbar.addSubview(label)
        
        let frame = CGRect(x: 0, y: 0, width: statusBarFrame.width, height: statusBarFrame.height + size.height + 20)
        window.frame = frame
        toolbar.frame = frame
        
        if let toolbarTapHandle = toolbarTapHandle {
            self.toolbarTapHandle = toolbarTapHandle
            let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(toolBarTap(_:)))
            toolbar.addGestureRecognizer(tapGesture)
        }
        
        var originPoint = toolbar.frame.origin
        originPoint.y = -(toolbar.frame.size.height)
        
        toolbar.frame = CGRect(origin: originPoint, size: toolbar.frame.size)
        UIView.animate(withDuration: 0.3, animations: {
            toolbar.transform = CGAffineTransform(translationX: 0, y: -toolbar.frame.origin.y)
        }, completion: { _ in
            if autoClear {
                DispatchQueue.main.asyncAfter(deadline: .now() + autoClearTime) {
                    UIView.animate(withDuration: 0.3, animations: {
                        toolbar.transform = .identity
                    }, completion: { (_) in
                        let selector = #selector(hideHud(_:))
                        self.perform(selector, with: window, afterDelay: 0)
                    })
                    completeHandle?()
                }
            }
        })
        return window
    }
    
    /// 清除Hud
    static func clear() {
        cancelPreviousPerformRequests(withTarget: self)
        if let _ = timer {
            timer.cancel()
            timer = nil
            timerTimes = 0
        }
        taskQueues.removeAll(keepingCapacity: false)
    }
    
    /// 点击手势隐藏
    ///
    /// - Parameter gesture: 手势
    @objc
    static func tapHide(_ gesture: UITapGestureRecognizer) {
        clear()
    }
    
    /// 点击通知栏的工具条
    ///
    /// - Parameter gesture: 手势
    @objc
    static func toolBarTap(_ gesture: UITapGestureRecognizer) {
        toolbarTapHandle?()
    }
    
    /// 隐藏Hud
    ///
    /// - Parameter sender: 传递值
    @objc
    static func hideHud(_ sender: AnyObject) {
        guard let window = sender as? UIWindow, let view = window.subviews.first else { return }
        
        UIView.animate(withDuration: 0.2, animations: {
            // 这一段if主要用于手动进行通知栏HUD移除用的
            if view.tag == kNaviBarHud {
                UIView.animate(withDuration: 0.3, animations: {
                    view.transform = .identity
                }, completion: { (_) in
                    remove()
                })
            }else {
            // 一般情况
                remove()
            }

        }) { (_) in
            // 从任务队列中移除
            if let index = taskQueues.index(where: { $0 == window }) {
                taskQueues.remove(at: index)
            }
        }
        
        func remove() {
            view.alpha = 0
            view.removeFromSuperview()
            window.alpha = 0
            window.removeFromSuperview()
        }
    }
}

extension HudInternal {
    
    /// 创建alertWindow
    ///
    /// - Returns: UIWindow
    static func alertWindow() -> UIWindow {
        let window = UIWindow()
        window.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        window.backgroundColor = backgroundColor
        window.isHidden = false
        #if swift(>=4.2)
        window.windowLevel = UIWindow.Level.alert
        #else
        window.windowLevel = UIWindowLevelAlert
        #endif
        
        return window
    }
    
    /// 自动移除的行为
    ///
    /// - Parameters:
    ///   - autoClear: 是否自动移除
    ///   - window: alertWindow
    ///   - autoClearTime: 移除的延迟时间
    ///   - completeHandle: 自动移除后的操作响应
    static func autoClearAction(autoClear: Bool, window: UIWindow, autoClearTime: TimeInterval, completeHandle: CompleteHandle? = nil) {
        if autoClear {
            let selector = #selector(hideHud(_:))
            perform(selector, with: window, afterDelay: autoClearTime)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + autoClearTime) {
                completeHandle?()
            }
        }
    }
    
    /// 添加响应手势
    ///
    /// - Parameters:
    ///   - responseTap: 是否响应点击移除
    ///   - window: alertWindow
    static func addTapGesture(responseTap: Bool, window: UIWindow) {
        if responseTap {
            let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(tapHide(_:)))
            tapGesture.numberOfTapsRequired = kHideHudTaps
            window.addGestureRecognizer(tapGesture)
        }
    }
    
    /// view的透明度的渐入
    ///
    /// - Parameter mainView: UIView
    static func alphaEaseIn(_ mainView: UIView) {
        mainView.alpha = 0.0
        UIView.animate(withDuration: 0.2) {
            mainView.alpha = 1
        }
    }
}


// MARK:-  Hud图形绘制
private class HudGraph {
    
    /// 存储图形用的结构体
    struct Cache {
        static var imageOfCheckmark: UIImage?
        static var imageOfCross: UIImage?
        static var imageOfInfo: UIImage?
    }
    
    /// 绘制的颜色
    static var drawColor: UIColor = .white
    
    /// 绘制图片
    ///
    /// - Parameter type: 类型
    static func draw(_ type: HudType) {
        let checkmarkShapePath = UIBezierPath()
        
        // draw circle
        checkmarkShapePath.move(to: CGPoint(x: 36, y: 18))
        checkmarkShapePath.addArc(withCenter: CGPoint(x: 18, y: 18), radius: 17.5, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
        checkmarkShapePath.close()
        
        switch type {
        // draw checkmark
        case .success:
            checkmarkShapePath.move(to: CGPoint(x: 10, y: 18))
            checkmarkShapePath.addLine(to: CGPoint(x: 16, y: 24))
            checkmarkShapePath.addLine(to: CGPoint(x: 27, y: 13))
            checkmarkShapePath.move(to: CGPoint(x: 10, y: 18))
            checkmarkShapePath.close()
        // draw X
        case .fail:
            checkmarkShapePath.move(to: CGPoint(x: 10, y: 10))
            checkmarkShapePath.addLine(to: CGPoint(x: 26, y: 26))
            checkmarkShapePath.move(to: CGPoint(x: 10, y: 26))
            checkmarkShapePath.addLine(to: CGPoint(x: 26, y: 10))
            checkmarkShapePath.move(to: CGPoint(x: 10, y: 10))
            checkmarkShapePath.close()
        // draw !
        case .info:
            checkmarkShapePath.move(to: CGPoint(x: 18, y: 6))
            checkmarkShapePath.addLine(to: CGPoint(x: 18, y: 22))
            checkmarkShapePath.move(to: CGPoint(x: 18, y: 6))
            checkmarkShapePath.close()
            
            drawColor.setStroke()
            checkmarkShapePath.stroke()
            
            let checkmarkShapePath = UIBezierPath()
            checkmarkShapePath.move(to: CGPoint(x: 18, y: 27))
            checkmarkShapePath.addArc(withCenter: CGPoint(x: 18, y: 27), radius: 1, startAngle: 0, endAngle: CGFloat(Double.pi*2), clockwise: true)
            checkmarkShapePath.close()
            
            drawColor.setFill()
            checkmarkShapePath.fill()
        }
        
        drawColor.setStroke()
        checkmarkShapePath.stroke()
    }
    
    /// checkMark
    static var imageOfCheckmark: UIImage? {
        guard let imageOfCheckmark = Cache.imageOfCheckmark else {
            
            UIGraphicsBeginImageContextWithOptions(CGSize(width: 36, height: 36), false, 0)
            draw(.success)
            Cache.imageOfCheckmark = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return Cache.imageOfCheckmark
        }
        
        return imageOfCheckmark
    }
    
    /// X
    static var imageOfCross: UIImage? {
        guard let imageOfCross = Cache.imageOfCross else {
            
            UIGraphicsBeginImageContextWithOptions(CGSize(width: 36, height: 36), false, 0)
            draw(.fail)
            Cache.imageOfCross = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return Cache.imageOfCross
        }
        
        return imageOfCross
    }
    
    /// info
    static var imageOfInfo: UIImage? {
        guard let imageOfInfo = Cache.imageOfInfo else {
            
            UIGraphicsBeginImageContextWithOptions(CGSize(width: 36, height: 36), false, 0)
            draw(.info)
            Cache.imageOfInfo = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return Cache.imageOfInfo
        }
        
        return imageOfInfo
    }
}

// MARK: - UIWindow的隐藏分类
extension UIWindow{
    func hide() {
        HudInternal.hideHud(self)
    }
}
