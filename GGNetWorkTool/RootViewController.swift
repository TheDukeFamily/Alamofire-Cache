//
//  RootViewController.swift
//  GGNetWorkTool
//
//  Created by iosdevmac201 on 2021/3/31.
//

import UIKit

class RootViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        GGNetworkTool.post("s=/index/index/get_index_data", shouldPrint:false, isCache: true) { (json, isSuccess) in
            
        }
    }

}
