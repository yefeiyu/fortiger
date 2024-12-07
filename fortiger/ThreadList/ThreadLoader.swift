//
//  ThreadLoader.swift
//  FourFour
//
//  Created by Charles Thomas on 12/1/24.
//

import Foundation
import SwiftSoup

class ThreadLoader {
    
    /// 加载帖子数据
    func loadThreads(fid: Int, page: Int) async throws -> [Thread] {
        guard let url = ForumURLs.forumDisplay(fid: fid, page: page) else {
            throw NSError(domain: "ThreadLoader", code: 400, userInfo: [NSLocalizedDescriptionKey: "无效的 URL"])
        }

        var request = URLRequest(url: url)
        request.httpShouldHandleCookies = true  // 确保处理 Cookies

        // 使用 withCheckedThrowingContinuation 来处理回调并转换为异步函数
        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: NSError(domain: "ThreadLoader", code: 500, userInfo: [NSLocalizedDescriptionKey: error.localizedDescription]))
                    return
                }

                guard let data = data else {
                    continuation.resume(throwing: NSError(domain: "ThreadLoader", code: 404, userInfo: [NSLocalizedDescriptionKey: "没有收到数据"]))
                    return
                }

                if let htmlString = String(data: data, encoding: .gbk) {
                    // 检查是否需要登录
                    if htmlString.contains("您需要登录后才能继续本操作") || htmlString.contains("请先登录") {
                        continuation.resume(throwing: NSError(domain: "ThreadLoader", code: 401, userInfo: [NSLocalizedDescriptionKey: "请先登录"]))
                        return
                    }

                    do {
                        let parsedThreads = try ThreadParser.parseThreadList(html: htmlString)
                        continuation.resume(returning: parsedThreads)
                    } catch {
                        continuation.resume(throwing: NSError(domain: "ThreadLoader", code: 500, userInfo: [NSLocalizedDescriptionKey: "解析错误: \(error)"]))
                    }
                } else {
                    continuation.resume(throwing: NSError(domain: "ThreadLoader", code: 415, userInfo: [NSLocalizedDescriptionKey: "无法使用 GBK 编码解码数据"]))
                }
            }.resume()
        }
    }
}
