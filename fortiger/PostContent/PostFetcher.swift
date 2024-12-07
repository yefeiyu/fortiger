//
//  PostFetcher.swift
//  FourFour
//
//  Created by Charles Thomas on 2024/11/20.
//
// PostFetcher.swift
import Foundation
import SwiftSoup

class NetworkManager {
    static let shared = NetworkManager()

    func fetchHTMLContent(for postURL: URL, completion: @escaping (String?, String?) -> Void) {
        let task = URLSession.shared.dataTask(with: postURL) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil, nil)
                return
            }
            let htmlContent = String(data: data, encoding: .gbk)
            
            let formhash = PostParser.extractFormhash(from: htmlContent ?? "")
            completion(htmlContent, formhash)
        }
        task.resume()
    }
    func percentEncode(_ string: String, encoding: String.Encoding) -> String {
        if let data = string.data(using: encoding) {
            var encodedString = ""
            for byte in data {
                if (byte >= 0x30 && byte <= 0x39) || // 0-9
                   (byte >= 0x41 && byte <= 0x5A) || // A-Z
                   (byte >= 0x61 && byte <= 0x7A) || // a-z
                   byte == 0x2D || byte == 0x2E || byte == 0x5F || byte == 0x7E {
                    // - . _ ~ 不编码
                    encodedString.append(Character(UnicodeScalar(byte)))
                } else {
                    encodedString.append(String(format: "%%%02X", byte))
                }
            }
            return encodedString
        } else {
            return string
        }
    }
    func submitReply(tid: String, replyContent: String, formhash: String, completion: @escaping (Bool, Error?) -> Void) {
        let urlString = "\(ForumURLs.baseURL)post.php?action=reply&tid=\(tid)&replysubmit=yes&infloat=yes&handlekey=fastpost&inajax=1"
        guard let url = URL(string: urlString) else {
            completion(false, nil)
            return
        }
        
        
        let parameters: [String: String] = [
            "message": replyContent,
            "formhash": formhash,
            // 其他必要的参数
        ]
        
        let gbkEncoding = String.Encoding.gbk
        var bodyComponents = [String]()

        for (key, value) in parameters {
            let encodedKey = percentEncode(key, encoding: .gbk)
            let encodedValue = percentEncode(value, encoding: .gbk)
            bodyComponents.append("\(encodedKey)=\(encodedValue)")
        }

        let bodyString = bodyComponents.joined(separator: "&")

        guard let bodyData = bodyString.data(using: gbkEncoding) else {
            completion(false, nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = bodyData
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(false, error)
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                print("状态码: \(httpResponse.statusCode)")
            }
            if let data = data, let responseString = String(data: data, encoding: .gbk) {
                print("响应数据: \(responseString)")
            }
            // 根据服务器返回的数据判断提交是否成功
            completion(true, nil)
        }
        task.resume()
    }
}
