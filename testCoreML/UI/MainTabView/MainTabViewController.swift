//
//  MainTabViewController.swift
//  testCoreML
//
//  Created by 池田和浩 on 2021/04/14.
//

import UIKit

typealias HomeTabs = (
    task: UIViewController,
    itemManage: UIViewController
)

class MainTabViewController: UITabBarController {
    init(tabs: HomeTabs) {
        super.init(nibName: nil, bundle: nil)
        viewControllers = [tabs.task, tabs.itemManage]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 背景色変更
        self.view.backgroundColor = .red
        
        //view.layoutIfNeeded()
    }
}
