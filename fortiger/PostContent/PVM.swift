//
//  PVW.swift
//  FourFour
//
//  Created by Charles Thomas on 12/1/24.
//
import SwiftUI
import WebKit
class PostViewModel: ObservableObject {
    @Published var contentHTML: String = ""
    @Published var currentPage: Int = 1
    @Published var additionalContent: String = ""
    @Published var isLoadingNextPage: Bool = false
    @Published var totalPages: Int = 1
    @Published var hasAppendedReturnButton: Bool = false // 防止多次追加
    @Published var formhash: String?
    @Published var postURL44: String = ""
    // 初始化方法
    init() {}
    // 提取 tid 的辅助函数
       func extractTid(from urlString: String) -> Int? {
           if let urlComponents = URLComponents(string: urlString),
              let queryItems = urlComponents.queryItems {
               for item in queryItems {
                   if item.name == "tid", let value = item.value, let tid = Int(value) {
                       return tid
                   }
               }
           }
           return nil
       }
    func fetchAndDisplayPost(postURL44: String) {
        self.postURL44 = postURL44
        let fullURLString = ForumURLs.baseURL.absoluteString + postURL44
        if let url = URL(string: fullURLString) {
            NetworkManager.shared.fetchHTMLContent(for: url) { htmlContent, formhash in
                guard let htmlContent = htmlContent else {
                    print("Failed to fetch content")
                    return
                }
                if let formhash = PostParser.parseFormhash(htmlContent) {
                    DispatchQueue.main.async{
                        self.formhash = formhash
                    }
                }
                    
                if let postContent = PostParser.parseHTMLContent(htmlContent) {
                    DispatchQueue.main.async {
                        self.contentHTML = postContent.contentHTML
                        self.totalPages = postContent.totalPages
                        // 这里添加返回列表按钮和回复框的 HTML
                        self.additionalContent += self.returnToListButtonHTML()
//                        self.additionalContent += self.replyContentHTML()
                    }
                }
            }
        } else {
            print("Invalid URL")
        }
    }

    func loadNextPage(postURL44: String) {
        guard let tid = extractTid(from: postURL44),
              !isLoadingNextPage,
              currentPage < totalPages else {
            if currentPage >= totalPages && !hasAppendedReturnButton {
                DispatchQueue.main.async {
                    self.additionalContent += self.returnToListButtonHTML()  // 仅添加一次
                    self.hasAppendedReturnButton = true
                }
            }
            return
        }

        isLoadingNextPage = true
        let nextPageURL = ForumURLs.viewThread(tid: tid, page: currentPage + 1)
        guard let nextPageURL = nextPageURL else {
            return
        }

        NetworkManager.shared.fetchHTMLContent(for: nextPageURL) { htmlContent, formhash in
            guard let htmlContent = htmlContent else {
                DispatchQueue.main.async {
                    self.isLoadingNextPage = false
                }
                return
            }

            if let postContent = PostParser.parseHTMLContent(htmlContent) {
                DispatchQueue.main.async {
                    self.additionalContent += postContent.contentHTML
                    self.totalPages = postContent.totalPages
                    self.currentPage += 1
                    if self.currentPage >= self.totalPages && !self.hasAppendedReturnButton {
                        self.additionalContent += self.returnToListButtonHTML()
                        self.hasAppendedReturnButton = true
                    }
                    self.isLoadingNextPage = false
                }
            }
        }
    }
    func reloadPostContent() {
        // 清空现有内容
        self.contentHTML = ""
        self.additionalContent = ""
        // 重新获取帖子内容
        self.fetchAndDisplayPost(postURL44: self.postURL44)
        // 如果需要跳转到最后一页，可以更新 currentPage
        self.currentPage = self.totalPages
    }
    func submitReply(tid: String, replyContent: String) {
        NetworkManager.shared.submitReply(tid: tid, replyContent: replyContent, formhash: formhash ?? "") { success, error in
            DispatchQueue.main.async {
                if success {
                    // 回复成功后，重新获取帖子内容
                    self.reloadPostContent()
                } else {
                    // 处理错误，例如弹出提示
                }
            }
        }
    }
    func returnToListButtonHTML() -> String {
        return """
        <div style="margin:20px 0; display: flex; justify-content: center;">
            <div style="width: 95%; max-width: 600px;">
                <textarea id="replyContent" style="width: 100%; height:100px; padding:10px; font-size:16px; transition: background-color 0.3s, color 0.3s; text-indent: 0em; border: 1px solid #ccc; border-radius: 5px;">
                </textarea>
                <div style="margin-top:10px; display: flex; justify-content: space-between; align-items: center;">
                    <button onclick="submitReply()" style="padding:10px 20px; font-size:16px; background-color:#28a745; color:white; border:none; border-radius:5px;">提交回复</button>
                    <button onclick="window.webkit.messageHandlers.returnToList.postMessage(null)" style="padding:10px 20px; font-size:16px; background-color:#007BFF; color:white; border:none; border-radius:5px;">返回列表</button>
                </div>
            </div>
        </div>
        <style>
            /* 默认浅色模式 */
            textarea {
                background-color: #ffffff;
                color: #000000;
            }

            /* 深色模式 */
            @media (prefers-color-scheme: dark) {
                textarea {
                    background-color: #333333;
                    color: #ffffff;
                }

                button {
                    background-color: #28a745;
                    color: #ffffff;
                }
            }
        </style>
        <script>
            function submitReply() {
                var content = document.getElementById('replyContent').value;
                window.webkit.messageHandlers.submitReply.postMessage(content);
            }
        </script>
        """
    }
}
func extractTid(from url: String) -> String? {
    if let range = url.range(of: "tid=([0-9]+)", options: .regularExpression) {
        let tid = String(url[range]).replacingOccurrences(of: "tid=", with: "")
        return tid
    }
    return nil
}
extension Notification.Name {
    static let returnToList = Notification.Name("returnToList")
}
