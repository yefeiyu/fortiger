//
//  FlvHitcolor.swift
//  FourTiger
//
//  Created by Charles Thomas on 12/7/24.
//

import SwiftUICore

extension ForumListView {

    /// 根据线程状态返回标题视图
    func threadTitle(for thread: Thread) -> String {
        if readStatusManager.hasRead(threadId: thread.id) {
            // 已读
            return thread.titlecommon ?? thread.titlenew ?? "无标题"
        } else {
            // 未读
            return thread.titlenew ?? "无标题"
        }
    }
    
    /// 根据线程的读取状态和新回复情况返回颜色
    func getColor(for thread: Thread) -> Color {
        if readStatusManager.hasRead(threadId: thread.id) {
            if readStatusManager.hasNewReplies(threadId: thread.id, currentReplyCount: thread.replies) {
                return .cyan
            } else {
                return .gray
            }
        } else {
            return .primary// 或者原来的颜色
        }
    }
}
