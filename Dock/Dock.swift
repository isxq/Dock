//
//  Dock.swift
//  Dock
//
//  Created by ios on 2019/8/7.
//  Copyright © 2019 xiaoqiang. All rights reserved.
//

import Foundation

public class Dock {
    
    static let sharedInstance: Dock = Dock()
    
    var moduleDict: [String: AnyClass] = [:]
    
    static var router: [String: DockRouterHandler] = [:]
    
    private init(){}
    
}

/// Dock + Module
public extension Dock {
    
    static func regist(_ module: AnyClass, to service: Protocol) throws {
        let serviceStr = NSStringFromProtocol(service)
        let clsStr = NSStringFromClass(module)
        var error: String?
        if clsStr.isEmpty {
            error = "Needs a valid module for protocol \(serviceStr)"
        } else if serviceStr.isEmpty {
            error = "Needs a valid protocol for module \(serviceStr)"
        } else if !module.conforms(to: service){
            error = "Module \(clsStr) should confirm to protocol \(serviceStr)"
        } else {
            sharedInstance.moduleDict[serviceStr] = module
        }
        if let error = error {
            let error = DockError(reason: error, service: serviceStr, module: clsStr)
            throw error
        }
    }
    
    static func getAllModule()-> [AnyClass] {
        return sharedInstance.moduleDict.values.sorted { $0.priority?() ?? DockModulePriority.default.rawValue > $1.priority?() ?? DockModulePriority.default.rawValue
        }
    }
    
    static func getModule(by service: Protocol) -> AnyObject? {
        let serviceStr = NSStringFromProtocol(service)
        if let cls = sharedInstance.moduleDict[serviceStr] as? DockProtocol.Type {
            return cls.sharedInstace
        } else {
            return nil
        }
    }
    
    static func setupAllModules() {
        let allModule = getAllModule()
        allModule.forEach { (moduleClass) in
            let syncSetup = moduleClass.setupModuleSynchronously?() ?? false
            if syncSetup {
                moduleClass.sharedInstace?.setup?()
            } else {
                DispatchQueue.global().async {
                    moduleClass.sharedInstace?.setup?()
                }
            }
        }
    }
    
    static func invokeForAllModules(selector: Selector, arguments: Any?...) {
        let modules = getAllModule()
        modules.compactMap{$0.sharedInstace}.forEach { module in
            guard module.responds(to: selector) else { return }
            switch arguments.count {
            case 0:
                module.perform(selector)
            case 1:
                module.perform(selector, with: arguments[0])
            case 2:
                module.perform(selector, with: arguments[0], with: arguments[1])
            default: break
            }
        }
    }
}

/// Dock + Router
public extension Dock {
    
    static func getKey(from urlStr: String) -> String? {
        guard let url = URL(string: urlStr) else {
            return nil
        }
        return (url.host ?? "") + url.path
    }
    
    static func getParamters(from urlStr: String)-> [String: String]? {
        guard let url = URL(string: urlStr),
            let query = url.query,
            query.isEmpty == false else {
                return nil
        }
        var paramters: [String: String] = [:]
        let list = query.components(separatedBy: "&")
        list.forEach { (param) in
            let elts = param.components(separatedBy: "=")
            if elts.count >= 2{
                let value = elts.last?.removingPercentEncoding ?? ""
                let key = elts.first ?? ""
                paramters[key] = value
            }
        }
        return paramters
    }
    
    static func bind(url: String, to handler: @escaping DockRouterHandler) {
        guard let key = getKey(from: url) else {
            return
        }
        router[key] = handler
    }
    
    static func unbind(url: String){
        guard let key = getKey(from: url) else {
            return
        }
        router.removeValue(forKey: key)
    }
    
    static func unbindAll() {
        router.removeAll()
    }
    
    static func getHandler(for url: String) -> DockRouterHandler? {
        guard let key = getKey(from: url) else {
            return nil
        }
        return router[key]
    }
    
    static func canHandle(url: String) -> Bool {
        guard let key = getKey(from: url) else {
            return false
        }
        if getHandler(for: key) != nil {
            return true
        } else {
            return false
        }
    }
    
    @discardableResult
    static func handle(
        url: String,
        with complexParam: [String: Any]? = nil,
        completion: DockRouterCompletionHandler? = nil) -> Any? {
        var paramters: [String: Any] = getParamters(from: url) ?? [:]
        complexParam?.forEach{ paramters[$0] = $1 }
        if let completion = completion {
            paramters[DockRouterCompletion] = completion
        }
        return getHandler(for: url)?(paramters)
    }
    
    static func complete(with paramters: [String: Any], result: Any) {
        (paramters[DockRouterCompletion] as? DockRouterCompletionHandler)?(result)
    }
}

/// Dock + Hook
extension Dock {
    
    static func hook() {
        let typeCount = Int(objc_getClassList(nil, 0))
        let types = UnsafeMutablePointer<AnyClass?>.allocate(capacity: typeCount)
        let safeTypes = AutoreleasingUnsafeMutablePointer<AnyClass>(types)
        objc_getClassList(safeTypes, Int32(typeCount))
        for index in 0..<typeCount {
            if let cls = types[index] {
                let clsName = NSStringFromClass(cls)
                if clsName.components(separatedBy: ".").count > 1 {
                    if let dcls = cls as? DockProtocol.Type {
                        dcls.awake()
                    }
                }
            }
        }
        types.deallocate()
    }
    
}

