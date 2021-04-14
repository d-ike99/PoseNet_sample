//
//  ValificationViewController.swift
//  testCoreML
//
//  Created by 池田和浩 on 2021/04/14.
//

import UIKit

class ValificationViewController: UIViewController {

    override func viewDidLoad() {
        
        // 部品
        var testLabel: UILabel = UILabel()
        testLabel.frame = CGRect(x: self.view.frame.width / 2, y: self.view.frame.height / 2, width: 30, height: 30)
        testLabel.text = "test!!"
        testLabel.textColor = .red
        
        self.view.backgroundColor = .darkGray
        self.view.addSubview(testLabel)
    }
}
