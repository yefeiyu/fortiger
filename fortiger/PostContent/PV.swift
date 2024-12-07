//
//  PV.swift
//  FourFour
//
//  Created by Charles Thomas on 12/1/24.
//
//
import SwiftUI
import WebKit

struct PostView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel = PostViewModel()
    var postURL44: String // 将 postURL44 改为 String 类型

    init(postURL44: String) {
        _viewModel = StateObject(wrappedValue: PostViewModel())
        self.postURL44 = postURL44
    }

    var body: some View {
        VStack {
            if viewModel.contentHTML.isEmpty {
                ProgressView("Loading...")
            } else {
                WebView(
                    htmlContent: viewModel.contentHTML,
                    postURL: postURL44, // 将 postURL44 传递给 WebView
                    additionalContent: $viewModel.additionalContent,
                    loadNextPage: {
                        viewModel.loadNextPage(postURL44: postURL44)
                    },
                    viewModel: viewModel,
                    submitReplyHandler: { replyContent in
                        if let tid = extractTid(from: postURL44) {
                            viewModel.submitReply(tid: tid, replyContent: replyContent)
                        }
                    }
                )
            }
        }
        .onAppear {
            viewModel.fetchAndDisplayPost(postURL44: postURL44)  // 传递 postURL44
//             添加观察者以监听“返回列表”通知
            NotificationCenter.default.addObserver(forName: .returnToList, object: nil, queue: .main) { _ in
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        .onDisappear {
            // 移除观察者
            NotificationCenter.default.removeObserver(self, name: .returnToList, object: nil)
        }
    }
}
