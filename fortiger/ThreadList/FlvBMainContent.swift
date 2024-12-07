// ForumListView+MainContent.swift
import SwiftUI

extension ForumListView {
    /// 主要内容视图
    var mainContent: some View {
        Group {
            if isLoading && threads.isEmpty {
                ProgressView("加载中...")
            } else if let errorMessage = errorMessage {
                VStack {
                    Text("加载失败: \(errorMessage)")
                        .foregroundColor(.red)
                    Button("重试") {
                        Task {
                            await refreshThreads()
                        }
                    }
                    .padding(.top)
                }
            } else {
                threadListView
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("注销") {
                    self.showLogin = true
                    self.threads = []
                    self.errorMessage = nil
                    self.currentPage = 1
                    // 不清除 readStatusManager.readThreads
                }
            }
        }
    }
}
