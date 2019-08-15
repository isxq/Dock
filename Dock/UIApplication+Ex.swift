//
//  UIApplication+Ex.swift
//  Dock
//
//  Created by ios on 2019/8/14.
//  Copyright © 2019 xiaoqiang. All rights reserved.
//

import Foundation

extension UIApplication {
    
    static let runOnce: Void = {
        Dock.hook()
        return
    }()
    
    open override var next: UIResponder? {
        UIApplication.runOnce
        return super.next
    }
}
