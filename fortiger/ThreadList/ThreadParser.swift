// Thread.swift
import SwiftSoup

struct Thread: Identifiable, Equatable {
    let id: Int
    var titlecommon: String?
    var titlenew: String?
    let url: String
    var imageAttachments: [String]
    let authorName: String
    let authorUrl: String
    let date: String
    let replies: Int
    let views: Int
    let lastPosterName: String
    let lastPosterUrl: String
    let lastPostDate: String
    
    // 简单合并标题字段
    var title: String {
        titlenew ?? titlecommon ?? "SUPER TITLE"
    }
    
    static func == (lhs: Thread, rhs: Thread) -> Bool {
        lhs.id == rhs.id
    }
}

// ThreadParser.swift
import SwiftSoup

class ThreadParser {
    enum ParseError: Error {
        case invalidIdFormat
    }

    static func parseThreadList(html: String) throws -> [Thread] {
        let doc: Document = try SwiftSoup.parse(html)
        let threadElements = try doc.select("tbody[id^=normalthread_]")

        var threads = [Thread]()

        for threadElement in threadElements.array() {
            let thread = try parseThread(threadElement: threadElement)
            threads.append(thread)
        }

        return threads
    }

    static func parseThread(threadElement: Element) throws -> Thread {
        let threadIdString = try threadElement.attr("id").replacingOccurrences(
            of: "normalthread_", with: ""
        )

        guard let threadId = Int(threadIdString) else {
            throw ParseError.invalidIdFormat
        }

        let titleCommon = try threadElement.select("th.subject.common").text()
        let titleNew = try threadElement.select("th.subject.new").text()
        let url = try threadElement.select("th.subject a").attr("href")
        let images = try threadElement.select("img.attach").array().map { try $0.attr("src") }
        let replyPages = try threadElement.select("span.threadpages a").array().map { try Int($0.text()) ?? 1 }

        let authorElement = try threadElement.select("td.author cite a").first()
        let authorName = try authorElement?.text() ?? ""
        let authorUrl = try authorElement?.attr("href") ?? ""

        let dateElement = try threadElement.select("td.author em").first()
        let date = try dateElement?.text() ?? ""

        let counts = try threadElement.select("td.nums").text().split(separator: "/").map(String.init)
        let replies = Int(counts[0]) ?? 0
        let views = Int(counts[1]) ?? 0

        let lastPostElement = try threadElement.select("td.lastpost").first()
        let lastPosterElement = try lastPostElement?.select("cite a").first()
        let lastPosterName = try lastPosterElement?.text() ?? ""
        let lastPosterUrl = try lastPosterElement?.attr("href") ?? ""
        let lastPostDateElement = try lastPostElement?.select("em a").first()
        let lastPostDate = try lastPostDateElement?.text() ?? ""

        return Thread(
            id: threadId,
            titlecommon: titleCommon.isEmpty ? nil : titleCommon,
            titlenew: titleNew.isEmpty ? nil : titleNew,
            url: url,
            imageAttachments: images,
            authorName: authorName,
            authorUrl: authorUrl,
            date: date,
            replies: replies,
            views: views,
            lastPosterName: lastPosterName,
            lastPosterUrl: lastPosterUrl,
            lastPostDate: lastPostDate
        )
    }
}
