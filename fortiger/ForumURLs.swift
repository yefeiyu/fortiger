//
//  ForumURLs.swift
//  FourDay
//
//  Created by Charles Thomas on 2024/5/8.
//
import Foundation

struct ForumURLs {
    static let baseURL = URL(string: "https://www.4d4y.com/forum/")!
    static let discuzURL = URL(string: "https://www.4d4y.com/forum/index.php")!
    static let cbaseURL = URL(string: "https://c.4d4y.com/forum/attachments/")!
    
    static func loginPage() -> URL? {
        return URL(string: "\(baseURL)logging.php?action=login&sid=2eddoC")
    }

    static func forumDisplay(fid: Int, page: Int) -> URL? {
        return URL(string: "\(baseURL)forumdisplay.php?fid=\(fid)&page=\(page)")
    }

    static func viewThread(tid: Int, page: Int) -> URL? {
        return URL(string: "\(baseURL)viewthread.php?tid=\(tid)&extra=page%3D1&page=\(page)")
    }
}
