//
//  NetworkTool.swift
//  NetworkTool
//
//  Created by iosdevmac201 on 2021/3/31.
//

import UIKit
import Alamofire
import SwiftyJSON

let GGNetworkTool_singleton = GGNetworkTool()

class GGNetworkTool: NSObject {
    
    var baseUrl = ""
    
    override init() {
        #if Release
        baseUrl = ProjectTool_singleton.currentReleaseBaseUrl
        #else
        if let userDefaults_standard_baseUrl = UserDefaults.standard.object(forKey:"baseUrl") as? String {
            baseUrl = userDefaults_standard_baseUrl
        }else{
            baseUrl = "https://test.flhsshjl.com/app/?"
        }
        #endif
    }
    
    class func get(_ uri:String,
                   param:Parameters?=nil,
                   shouldPrint:Bool=true,
                   isCache:Bool = false,
                   callback:@escaping(_ json:JSON?,_ isSuccess:Bool,_ isCache:Bool)->()) {
        GGNetworkTool_singleton.request(uri:uri, parameters:(param ?? [String:Any]()),
                                      m:HTTPMethod.get, shouldPrint:shouldPrint, isCache: isCache) { (json,isSuccess,isCache) in
            callback(json,isSuccess,isCache)
        }
    }
    
    class func post(_ uri:String,
                    param:Parameters?=nil,
                    shouldPrint:Bool=true,
                    isCache:Bool = false,
                    callback:@escaping(_ json:JSON?,_ isSuccess:Bool,_ isCache:Bool)->()) {
        GGNetworkTool_singleton.request(uri:uri,parameters:(param ?? [String:Any]()),
                                      m:HTTPMethod.post,shouldPrint:shouldPrint, isCache: isCache) { (json,isSuccess,isCache) in
            callback(json,isSuccess,isCache)
        }
    }
    
    class func put(_ uri:String,
                   param:Parameters?=nil,
                   shouldPrint:Bool=true,
                   callback:@escaping(_ json:JSON?,_ isSuccess:Bool)->()) {
        GGNetworkTool_singleton.request(uri:uri,parameters:(param ?? [String:Any]()),
                                      m:HTTPMethod.put,shouldPrint:shouldPrint) { (json,isSuccess,isCache) in
            callback(json,isSuccess)
        }
    }
    
    class func del(_ uri:String,
                   param:Parameters?=nil,
                   shouldPrint:Bool=true,
                   callback:@escaping(_ json:JSON?,_ isSuccess:Bool)->()) {
        GGNetworkTool_singleton.request(uri:uri,parameters:(param ?? [String:Any]()),
                                      m:HTTPMethod.delete,shouldPrint:shouldPrint) { (json,isSuccess,isCache) in
            callback(json,isSuccess)
        }
    }
    
    func request(uri:String,
                 parameters:Parameters,
                 m:HTTPMethod,
                 shouldPrint:Bool=true,
                 isCache:Bool = false,
                 callBack:@escaping(_ json:JSON?,_ isSuccess:Bool, _ isCache:Bool)->()) {
        let completeUrl = baseUrl + uri
        /// 是否请求缓存，请求缓存的话
        if isCache, let cacheJson = GGNetworkCache.getHttpCache(completeUrl, parameters)?.json {
            callBack(cacheJson, true, true)
        }
        var headers: HTTPHeaders = HTTPHeaders()
        headers["token"] = "我是登录的token"
        let e:ParameterEncoding = m == .get ? URLEncoding.default : JSONEncoding.default
        AF.request(completeUrl,method:m,parameters:parameters,encoding:e,headers:headers,requestModifier: {
            
            if uri.contains("logout"){
                $0.timeoutInterval = 3
            }
            
        }).responseJSON { (res) in
            
            let isSuccess = JSON(res.value ?? 0)["code"].intValue == 200
            print("┌────────────────────────\(m.rawValue)────────────────────────┐")
            print(res.request!.url!)
            if m == .post {
                let Parameters = String(data: res.request?.httpBody ?? Data(),encoding:String.Encoding.utf8)
                print("Parameters:")
                print(Parameters ?? "")
            }
            let json = JSON(res.value ?? 0)
            print("Response:")
            if shouldPrint {
                print(json)
            }else{
                print("省略")
            }
            if isSuccess == false {
                let errorstr = json["error"].stringValue
                if errorstr == "模拟单点登录监听"{
                    /// 退出登录，通知给appdelegate刷新
                    return
                }
            }
            /// 请求成功 && 需要缓存才添加缓存
            if isSuccess, isCache {
                var cacheModel = CacheModel()
                cacheModel.json = json
                GGNetworkCache.setHttpCache(cacheModel, completeUrl, parameters)
            }
            callBack(json,isSuccess, false)
            if let err = res.error { print(err)}// -1009 代表网络状态不佳
            print("└────────────────────────\(m.rawValue)────────────────────────┘")
        }
    }
    
    
}
