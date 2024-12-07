//
//  PostParser.swift
//  FourFour
//
//  Created by Charles Thomas on 2024/11/20.
//
import Foundation
import SwiftSoup

struct PostParser {
    static func parseHTMLContent(_ html: String) -> PostContent? {
        do {
            let document = try SwiftSoup.parse(html)
            
            // 提取帖子内容（根据实际HTML结构修改选择器）
            let postElements = try document.select("div.defaultpost")
            var combinedPostHTML = ""
            
            for postElement in postElements.array() {
                if let postMessage = try postElement.select("div.postmessage").first(),
                   let msgFontFix = try postMessage.select("div.t_msgfontfix").first(),
                   let table = try msgFontFix.select("table").first(),
                   let td = try table.select("td.t_msgfont").first() {
                    
                    let postHTML = try td.html()
                    let authorInfo = extractAuthorInfo(from: postElement)
                    let processedContent = processPostContent(postHTML, baseURL: URL(string: "https://example.com")!)
                    let fullPostHTML = """
                    <div class="post">
                        \(authorInfo)
                        \(processedContent)
                    </div>
                    """
                    combinedPostHTML += fullPostHTML
                }
            }
            
            // 解析总页数和当前页
            let totalPages = parseTotalPages(from: document)
            let currentPage = parseCurrentPage(from: document)
            let isLastPage = currentPage == totalPages
            
            return PostContent(contentHTML: combinedPostHTML, totalPages: totalPages, isLastPage: isLastPage, currentPage: currentPage)
        } catch {
            print("Error parsing HTML: \(error)")
            return nil
        }
    }
    
    // 提取当前页码
    private static func parseCurrentPage(from document: Document) -> Int {
        do {
            if let currentPageElement = try document.select("div.pages strong").first() {
                return Int(try currentPageElement.text()) ?? 1
            }
        } catch {
            print("解析当前页码时出错：\(error)")
        }
        return 1
    }
    
    // 提取总页数
    private static func parseTotalPages(from document: Document) -> Int {
        do {
            if let pagesDiv = try document.select("div.pages").first() {
                let pageLinks = try pagesDiv.select("a[href*='page=']").array()
                let pageNumbers = pageLinks.compactMap { link -> Int? in
                    let href = try? link.attr("href")
                    return extractPageNumber(from: href)
                }
                return pageNumbers.max() ?? 1
            }
        } catch {
            print("解析总页数时出错：\(error)")
        }
        return 1
    }
    
    // 从URL中提取页码
    private static func extractPageNumber(from urlString: String?) -> Int? {
        guard let urlString = urlString else { return nil }
        let components = URLComponents(string: urlString)
        let pageItem = components?.queryItems?.first(where: { $0.name == "page" })
        if let pageValue = pageItem?.value, let pageNumber = Int(pageValue) {
            return pageNumber
        }
        return nil
    }
    
    // 提取作者信息
    static func extractAuthorInfo(from postElement: Element) -> String {
        do {
            guard let tr = try postElement.parent()?.parent(),
                  let authorTd = try tr.select("td.postauthor").first() else {
                return "<div class=\"author\">Unknown Author</div>"
            }
            
            if let authorName = try authorTd.select("a").first()?.text(), !authorName.isEmpty {
                return "<div class=\"author\">\(authorName)</div>"
            }
        } catch {
            print("作者信息提取错误: \(error)")
        }
        return "<div class=\"author\">Unknown Author</div>"
    }
    
    // 解析帖子内容，处理图片等元素
    static func processPostContent(_ postHTML: String, baseURL: URL) -> String {
        do {
            let contentDoc = try SwiftSoup.parse(postHTML, baseURL.absoluteString)
            let imageElements = try contentDoc.select("img")
            
            for img in imageElements.array() {
                if let onclick = try? img.attr("onclick"), let range = onclick.range(of: "zoom\\(this, '(.*?)'\\)", options: .regularExpression) {
                    let imageURLString = String(onclick[range]).replacingOccurrences(of: "zoom(this, '", with: "").replacingOccurrences(of: "')", with: "")
                    try img.attr("src", imageURLString)
                }
                try img.removeAttr("onclick")
                try img.removeAttr("onmouseover")
                try img.removeAttr("id")
            }
            
            return try contentDoc.body()?.html() ?? postHTML
        } catch {
            print("内容处理错误：\(error)")
            return postHTML
        }
    }
    static func parseFormhash(_ html: String) -> String? {
        do {
            let document = try SwiftSoup.parse(html)
            if let input = try document.select("input[name=formhash]").first() {
                return try input.attr("value")
            }
        } catch {
            print("formhash 提取错误: \(error)")
        }
        return nil
    }
    static func extractFormhash(from htmlContent: String) -> String? {
        do {
            let doc = try SwiftSoup.parse(htmlContent)
            if let formhashElement = try doc.select("input[name=formhash]").first() {
                return try formhashElement.attr("value")
            }
        } catch {
            print("提取 formhash 出错: \(error)")
        }
        return nil
    }
    static func extractFormParameters(from htmlContent: String) -> [String: String]? {
        do {
            let doc = try SwiftSoup.parse(htmlContent)
            let inputs = try doc.select("form[action*='post.php'] input")
            var parameters: [String: String] = [:]
            for input in inputs.array() {
                let name = try input.attr("name")
                let value = try input.attr("value")
                parameters[name] = value
            }
            return parameters
        } catch {
            print("提取表单参数出错: \(error)")
        }
        return nil
    }
}

// 定义帖子内容结构
struct PostContent {
    let contentHTML: String
    let totalPages: Int
    let isLastPage: Bool
    let currentPage: Int
}
