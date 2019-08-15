//
//  DockProtocol.swift
//  Dock
//
//  Created by ios on 2019/8/14.
//  Copyright © 2019 xiaoqiang. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol DockProtocol: UIApplicationDelegate {
    
    /// 所有注册的模块都需要是一个单例
    @objc static var sharedInstace: DockProtocol { get }
    
    /// 在程序运行之初自动调用，效果类似于OC中的`load()`方法
    /// 用来进行模块注册或路由绑定
    static func awake()
    
    /// 模块设置方法，会在 app 启动或模块加载完成时由 `module manager` 调用
    @objc optional func setup()
    
    /// 设置方法是否在主线程同步运行
    /// 如果未实现，默认返回 `false`，在后台异步进行调用
    
    /// - returns : 是否同步设置
    @objc optional static func setupModuleSynchronously()-> Bool
    
    
    /// 模块设置方法调用的优先级，最低是 0
    /// 如果没有实现，默认返回 default
    /// - returns: 优先级
 
    @objc optional static func priority() -> UInt
}
