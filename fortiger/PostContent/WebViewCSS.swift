//
//  WebViewCSS.swift
//  FourFour
//
//  Created by Charles Thomas on 12/1/24.

import SwiftUI
import WebKit

struct WebViewUpdater {
    static func updateUIView(_ uiView: WKWebView, htmlContent: String, baseURL: URL?) {
        uiView.loadHTMLString(htmlContent, baseURL: baseURL)
        let customCSS = """
        <style>
          body {
            margin: 0;
            padding: 0;
            font-size: 21px;
            line-height: 1.4;
            background-color: transparent; 
        overflow-wrap: break-word;
          }
        
          .post {
            padding: 0 15px;
            box-sizing: border-box;
          }
        
          img {
            max-width: 100vw;  /* 使用视口宽度 */
            /*width: 100vw;      //强制图片宽度等于视口 //把所有的表情图片都放大了*/
            height: auto;
            display: block;
            margin-left: calc(-50vw + 50%);  /* 水平居中并拉伸 */
            margin-right: calc(-50vw + 50%);
            object-fit: cover; /* 确保图片填满 */
          }
        
          a {
            display: inline-block;
            max-width: 100%;
          }
        
          .author {
            color: gray;
            margin-top: 10px;
            position: relative;  /* 用于伪元素定位 */
          }
          .author::before {
            content: '';
            position: absolute;
            top: -5px;  /* 根据需要调整位置 */
            left: -5px;  /* 与屏幕左侧对齐 */
            right: -5px;  /* 与屏幕右侧对齐 */
            height: 0.2px;
            background-color: gray;
          }
        /* 下面是设置正文字体颜色的 */
                @media (prefers-color-scheme: light) {
                    body { color: black; }
                    a { color: blue; }
                }
                @media (prefers-color-scheme: dark) {
                    body { color: white; }
                    a { color: lightblue; }
                }
          .t_attach, span[style*="display: none"] {
            display: none !important;
          }
        </style>
        """
        
        let finalHTML = """
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1">
            \(customCSS)
        </head>
        <body>
        \(htmlContent)
        </body>
        </html>
        """
        
        uiView.loadHTMLString(finalHTML, baseURL: baseURL)
        
        // 可选：打印最终HTML以便调试
        uiView.evaluateJavaScript("document.documentElement.outerHTML") { result, error in
            if let html = result as? String {
                print("最终HTML内容：\n\(html)")
            }
            if let error = error {
                print("获取HTML失败：\(error)")
            }
        }
    }
}
