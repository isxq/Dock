//
//  DockHelper.swift
//  Dock
//
//  Created by ios on 2019/8/14.
//  Copyright © 2019 xiaoqiang. All rights reserved.
//

import Foundation

/// 字符串常量，用以标记字典中 `DockRouterCompletionHandler` 类型的值
public let DockRouterCompletion = "DockRouterCompletion"

/// 宏定义路由处理函数
public typealias DockRouterHandler = ([String: Any?])-> Any?

/// 宏定义路由完成回掉函数
public typealias DockRouterCompletionHandler = (Any)-> Void

/// DockError 结构体
public struct DockError: Error {
    
    /// 错误原因
    let reason: String?
    
    /// 出错位置的服务（协议）名
    let service: String?
    
    /// 出错位置的组件类名
    let module: String?
}

/// 组件优先级
public enum DockModulePriority: UInt {
    
    case lowest = 0
    case low = 50
    case `default` = 100
    case hight = 150
    
    static func > (lhs: DockModulePriority, rhs: DockModulePriority) -> Bool {
        return lhs.rawValue > lhs.rawValue
    }
}
