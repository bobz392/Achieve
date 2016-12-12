//
//  ReadLaterManager.swift
//  Accomplish
//
//  Created by zhoubo on 16/12/11.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation
import Fuzi

struct ReadLaterManager {
    typealias FinishBlock = () -> Void
    private let session: URLSession
    private let userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Safari/601.1.42"
    init() {
        self.session = URLSession(configuration: .default)
    }
    
    func downloadReadLaterPreview(readLater: ReadLater, finishBlock: FinishBlock? = nil) {
        guard !readLater.cacheed,
            let url = URL(string: readLater.link) else { return }
        
        var request = URLRequest(url: url)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            if let err = error {
                Logger.log("download readLater error = \(err)")
                return
            }
            
            guard let htmlData = data,
                let html = try? HTMLDocument(data: htmlData) else {
                    Logger.log("download readLater date empty = \(response)")
                    return
            }
            
            var img: String? = nil
            let imgs = html.css("img")
            for i in imgs {
                if let src = i["src"] {
                    if src.hasPrefix("http") {
                        img = src
                        break
                    }
                }
            }
            
            dispatch_async_main {
                RealmManager.shared.updateObject {
                    readLater.cacheed = true
                    if let imgSrc = img {
                        readLater.previewImageLink = imgSrc
                    }
                    Logger.log("read later update with src = \(img)")
                    
                    finishBlock?()
                }
            }
            
        })
        
        task.resume()
    }
    
}
