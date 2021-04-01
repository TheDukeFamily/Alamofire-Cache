//
//  RootViewController.swift
//  GGNetWorkTool
//
//  Created by iosdevmac201 on 2021/3/31.
//

import UIKit
import SwiftyJSON

let screenWidth = UIScreen.main.bounds.width
let screenHeight = UIScreen.main.bounds.height

class RootViewController: UIViewController {
    
    let requestButton = UIButton(type: .custom)
    let removeCacheButton = UIButton(type: .custom)
    let textView = UITextView()
    let cacheTextView = UITextView()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        createUI()
    }

    //实际业务场景，是拉取了缓存数据刷新页面，在得到网络数据刷新页面,isCache在实际项目使用场景很少
    @objc func requestData() {
        GGNetworkTool.post("s=/index/index/get_index_data", shouldPrint:false, isCache: true) {[weak self] (json, isSuccess, isCache) in
            guard let s = self else { return }
            if isSuccess, let dic = json?.dictionaryObject {
                if isCache {
                    s.cacheTextView.text = dic.gg_cache_jsonString()
                }else{
                    s.textView.text = dic.gg_cache_jsonString()
                }
                return
            }
        }
    }
    
    @objc func removeCacheData() {
        GGNetworkCache.removeAllCache {[weak self] (isSuccess) in
            guard let s = self else { return }
            if isSuccess {
                s.cacheTextView.text = nil
                s.textView.text = nil
            }
        }
    }
}


extension RootViewController {
    func createUI() {
        view.backgroundColor = .white
        requestButton.backgroundColor = #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1)
        requestButton.setTitle("请求数据", for: .normal)
        requestButton.addTarget(self, action: #selector(requestData), for: .touchUpInside)
        requestButton.frame = CGRect(x: 30, y: 44, width: 80, height: 35)
        view.addSubview(requestButton)
        
        removeCacheButton.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        removeCacheButton.setTitle("清除缓存", for: .normal)
        removeCacheButton.addTarget(self, action: #selector(removeCacheData), for: .touchUpInside)
        removeCacheButton.frame = CGRect(x: screenWidth - 110, y: 44, width: 80, height: 35)
        view.addSubview(removeCacheButton)
        
        textView.frame = CGRect(x: 10, y: requestButton.frame.maxY + 20, width: screenWidth - 20, height: 220)
        textView.backgroundColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
        view.addSubview(textView)
        
        cacheTextView.frame = CGRect(x: 10, y: textView.frame.maxY + 20, width: screenWidth - 20, height: 220)
        cacheTextView.backgroundColor = #colorLiteral(red: 0.6679978967, green: 0.4751212597, blue: 0.2586010993, alpha: 1)
        view.addSubview(cacheTextView)
    }
}

