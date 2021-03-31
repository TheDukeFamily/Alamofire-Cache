//
//  NetworkCache.swift
//  NetworkTool
//
//  Created by iosdevmac201 on 2021/3/31.
//

import UIKit
import Cache
import SwiftyJSON

/// 缓存的路径
fileprivate let diskConfig = DiskConfig(name: "GGNetWorkCache")
/// 磁盘配置,过期时间1个月
fileprivate let memoryConfig = MemoryConfig(expiry: .seconds(3600 * 30), countLimit: 10, totalCostLimit: 10)
/// 缓存Cache的单例，供外部方便调用class
let GGNetworkCache_singleton = GGNetworkCache()

class GGNetworkCache {
    
    let storage = try? Storage<String, CacheModel>(
      diskConfig: diskConfig,
      memoryConfig: memoryConfig,
      transformer: TransformerFactory.forCodable(ofType: CacheModel.self)
    )
    
    /// 写入缓存
    class func setHttpCache(_ httpData:CacheModel, _ uri:String, _ params:[String:Any]? = nil) {
        let cacheKey = GGNetworkCache_singleton.cacheKey(uri, params)
        GGNetworkCache_singleton.storage?.async.setObject(httpData, forKey: cacheKey, completion: { (result) in
            switch result {
            case .value(_) :
                print("缓存成功:\(cacheKey)")
            case .error(_) :
                print("缓存失败:\(cacheKey)")
            }
        })
    }
    
    /// 读取缓存
    class func getHttpCache(_ uri:String, _ params:[String:Any]? = nil) -> CacheModel? {
        let cacheKey = GGNetworkCache_singleton.cacheKey(uri, params)
        do {
            /// 清楚过期缓存
            if let isExpire = try GGNetworkCache_singleton.storage?.isExpiredObject(forKey: cacheKey), isExpire {
                removeObjectCache(cacheKey) { (_) in }
                return nil
            }else{
                return try GGNetworkCache_singleton.storage?.object(forKey: cacheKey)
            }
        } catch  {
            return nil
        }
    }
    
    /// 清除所有缓存
    class func removeAllCache(completion: @escaping (_ isSuccess: Bool)->()) {
        GGNetworkCache_singleton.storage?.async.removeAll(completion: { result in
            DispatchQueue.main.async {
                switch result {
                case .value: completion(true)
                case .error: completion(false)
                }
            }
        })
    }
    
    /// 根据key值清除缓存
    class func removeObjectCache(_ cacheKey: String, completion: @escaping (_ isSuccess: Bool)->()) {
        GGNetworkCache_singleton.storage?.async.removeObject(forKey: cacheKey, completion: { result in
            DispatchQueue.main.async {
                switch result {
                case .value: completion(true)
                case .error: completion(false)
                }
            }
        })
    }

    /// 请求链接和参数组装Key
    func cacheKey(_ uri:String, _ params:[String:Any]? = nil) -> String {
        guard let params = params, params.count > 0 else { return uri }
        guard let string = params.gg_cache_jsonString() else { return uri }
        return uri + string
    }
    
}

extension Dictionary {
    ///字典转JOSN字符串，小心trimBlankSpace，可能会把想要保留的空格回车也删了
    func gg_cache_jsonString(trimBlankSpace:Bool=false,trimNewLine:Bool=false,trimGang:Bool=false) -> String? {
        if !JSONSerialization.isValidJSONObject(self) {print("❌不能转化为JSONString");return nil}
        guard let jsonData = try? JSONSerialization.data(withJSONObject:self,options:.prettyPrinted) else {
            return nil
        }
        var str = String(data:jsonData,encoding:String.Encoding.utf8)
        if trimBlankSpace {
            str = str?.replacingOccurrences(of:" ", with:"")
        }
        if trimNewLine {
            str = str?.replacingOccurrences(of:"\n", with:"")
        }
        if trimGang {
            str = str?.replacingOccurrences(of:"\\", with:"")
        }
        return str
    }
}


struct CacheModel: Codable {
    var json: JSON?
    init() { }
}
