//
//  ValificationRouter.swift
//  testCoreML
//
//  Created by 池田和浩 on 2021/04/14.
//

import UIKit

class ValificationRouter: NSObject {

    var view: ValificationViewController?
        
    static func assembleModule() -> ValificationViewController {
        
        let view: ValificationViewController = ValificationViewController()
        let router = ValificationRouter()
        router.view = view
                        
        return view
    }
}
