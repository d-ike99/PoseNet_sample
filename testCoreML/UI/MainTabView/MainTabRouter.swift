//
//  MainTabRouter.swift
//  testCoreML
//
//  Created by 池田和浩 on 2021/04/14.
//

import UIKit

class MainTabRouter: NSObject {
    
    // DI
    var view: MainTabViewController?
    
    // setting Tabs
    typealias TabModules = (
        satuei: UINavigationController,
        itemManage: UINavigationController
    )
    var tabModules: TabModules?
    
    static func assembleModule(tabModules: TabModules) -> MainTabViewController {
        let tabs = MainTabRouter.createTabItems(tabModules)
        let view = MainTabViewController(tabs: tabs)
        let router = MainTabRouter()
        router.view = view
        router.tabModules = tabModules
        
        return view
    }
    
    static func createTabItems(_ tabModules: TabModules) -> HomeTabs {

        let graphIcon = UIImage(systemName: "folder")?.withTintColor(UIColor.black, renderingMode: .alwaysTemplate)
        
        // タブのアイテム作成
        let taskTabBarItem = UITabBarItem(title: "一覧", image: UIImage(named: "listWhite.png"), tag: 0)
        let itemManageTabBarItem = UITabBarItem(title: "種目管理", image: graphIcon?.scaleImage(scaleSize: 1.2), tag: 1)
        
        // 引数のVCの設定
        let taskTab: UIViewController = tabModules.satuei as UIViewController
        let itemManageTab: UIViewController = tabModules.itemManage as UIViewController
        
        taskTab.tabBarItem = taskTabBarItem
        itemManageTab.tabBarItem = itemManageTabBarItem
        
        return (
            task: taskTab,
            itemManage: itemManageTab
        )
    }
}

extension UIImage {
    // resize image
    func reSizeImage(reSize:CGSize)->UIImage {
        //UIGraphicsBeginImageContext(reSize);
        UIGraphicsBeginImageContextWithOptions(reSize,false,UIScreen.main.scale);
        self.draw(in: CGRect(x: 0, y: 0, width: reSize.width, height: reSize.height));
        let reSizeImage:UIImage! = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return reSizeImage;
    }

    // scale the image at rates
    func scaleImage(scaleSize:CGFloat)->UIImage {
        let reSize = CGSize(width: self.size.width * scaleSize, height: self.size.height * scaleSize)
        return reSizeImage(reSize: reSize)
    }
}
