//
//  正确的返回列表WV.swift
//  FourFour
//
//  Created by Charles Thomas on 11/30/24.
//

// WV.swift
import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    var htmlContent: String
    var baseURL: URL?
    var postURL: String?
    @Binding var additionalContent: String
    var loadNextPage: () -> Void
    var viewModel: PostViewModel
    var submitReplyHandler: (String) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(postURL: postURL, loadNextPage: loadNextPage, submitReplyHandler: { replyContent in
            // 在这里处理回复内容
            if let tid = extractTid(from: postURL ?? "") {
                viewModel.submitReply(tid: tid, replyContent: replyContent)
            }
        }, viewModel: viewModel)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        // 配置 WKWebView
        let contentController = WKUserContentController()
        contentController.add(context.coordinator, name: "scrollPosition")
        contentController.add(context.coordinator, name: "loadNextPage")
        contentController.add(context.coordinator, name: "returnToList") // 添加 "returnToList" 处理器
        contentController.add(context.coordinator, name: "submitReply")
        
        // 注入 JavaScript 监听滚动事件和检测底部，以及处理提交回复
        let js = """
        window.addEventListener('scroll', function() {
            var scrollTop = window.scrollY || document.documentElement.scrollTop;
            window.webkit.messageHandlers.scrollPosition.postMessage(scrollTop);
            
            // 检测是否接近底部(100 像素)
            var scrollHeight = document.body.scrollHeight;
            var clientHeight = window.innerHeight;
            if (scrollTop + clientHeight >= scrollHeight - 100) {
                window.webkit.messageHandlers.loadNextPage.postMessage(null);
            }
        });

        function submitReply() {
            var replyContent = document.getElementById('replyContent').value;
            window.webkit.messageHandlers.submitReply.postMessage(replyContent);
        }
        """
        let userScript = WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        contentController.addUserScript(userScript)
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        let webView = WKWebView(frame: .zero, configuration: config)
        context.coordinator.webView = webView
        webView.navigationDelegate = context.coordinator
        
        // 配置 WebView 外观
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.bounces = true
        
        // 初始化滑动手势处理
        let swipeHandler = SwipeGestureHandler(view: webView)
        swipeHandler.scrollAction = { direction in
            context.coordinator.scrollPage(direction: direction)
        }
        context.coordinator.swipeHandler = swipeHandler
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // 加载初始内容
        if uiView.isLoading == false && uiView.url == nil && !htmlContent.isEmpty {
            WebViewUpdater.updateUIView(uiView, htmlContent: htmlContent, baseURL: baseURL)
        }
        
        // 追加内容
        if !additionalContent.isEmpty {
            let escapedContent = escapeForJavaScript(additionalContent)
            let js = "document.body.innerHTML += '\(escapedContent)';"
            uiView.evaluateJavaScript(js, completionHandler: nil)
            DispatchQueue.main.async {
                self.additionalContent = ""
            }
        }
    }
    
    // 转义字符串以避免 JavaScript 注入问题
    func escapeForJavaScript(_ string: String) -> String {
        var escaped = string.replacingOccurrences(of: "\\", with: "\\\\")
        escaped = escaped.replacingOccurrences(of: "'", with: "\\'")
        escaped = escaped.replacingOccurrences(of: "\n", with: "\\n")
        escaped = escaped.replacingOccurrences(of: "\r", with: "\\r")
        return escaped
    }

    // Coordinator 类
    class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
        var swipeHandler: SwipeGestureHandler?
        weak var webView: WKWebView?
        var postURL: String?
        var loadNextPage: () -> Void
        var submitReplyHandler: (String) -> Void
        var viewModel: PostViewModel // 新增

        init(postURL: String?, loadNextPage: @escaping () -> Void, submitReplyHandler: @escaping (String) -> Void, viewModel: PostViewModel) {
            self.postURL = postURL
            self.loadNextPage = loadNextPage
            self.submitReplyHandler = submitReplyHandler
            self.viewModel = viewModel
        }
        
        func submitReplyHandler(replyContent: String) {
            if let tid = extractTid(from: postURL ?? "") {
                viewModel.submitReply(tid: tid, replyContent: replyContent)
                // 在 WebView 中清空回复框
                webView?.evaluateJavaScript("document.getElementById('replyContent').value = '';")
            }
        }
        // 处理来自 JavaScript 的消息
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "scrollPosition", let scrollTop = message.body as? CGFloat, let postURL = postURL {
                // 保存 scrollTop 到 UserDefaults
                UserDefaults.standard.set(scrollTop, forKey: postURL)
            } else if message.name == "loadNextPage" {
                // 触发加载下一页
                loadNextPage()
            } else if message.name == "returnToList" {
                // 触发返回列表
                NotificationCenter.default.post(name: .returnToList, object: nil)
            } else if message.name == "submitReply", let replyContent = message.body as? String {
                    submitReplyHandler(replyContent: replyContent)
            }
        }
        
        // 页面加载完成后，恢复滚动位置
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            if let postURL = postURL,
               let scrollTop = UserDefaults.standard.value(forKey: postURL) as? CGFloat {
                let js = "window.scrollTo(0, \(scrollTop));"
                webView.evaluateJavaScript(js, completionHandler: nil)
            }
        }
        
        // 执行页面滚动
        func scrollPage(direction: ScrollDirection) {
            guard let webView = webView else { return }
            let script = """
            (function() {
                var lineHeight = parseFloat(getComputedStyle(document.body).lineHeight);
                var scrollAmount = window.innerHeight - lineHeight;
                if ("\(direction)" === "up") {
                    window.scrollBy(0, -scrollAmount);
                } else if ("\(direction)" === "down") {
                    window.scrollBy(0, scrollAmount);
                }
            })();
            """
            webView.evaluateJavaScript(script, completionHandler: nil)
        }
    }
}
