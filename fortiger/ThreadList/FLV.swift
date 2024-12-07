// ForumListView.swift
import SwiftSoup
import SwiftUI

struct ForumListView: View {
    // MARK: - State Properties
    @State  var threads: [Thread] = []
    @State  var isLoading = false
    @State  var errorMessage: String?
    @State  var showLogin = true
    @State  var loginInfo = LoginInfo()
    @State  var isLoggingIn = false
    @State  var currentPage: Int = 1  // 当前页码
    @State  var fid: Int = 2  // 论坛ID，根据实际情况设置
    @State  var scrollIndex: Int = 0  // 用于记录当前滚动位置
    @State  var selectedThread: Thread? = nil  // 当前选中的帖子
    @State  var isSwiping = false             // 是否正在滑动
    
    // 新增：管理已读状态
    @StateObject  var readStatusManager = ReadStatusManager()
    
     let threadLoader = ThreadLoader()
    
    var body: some View {
        NavigationView {
            if showLogin {
                loginView
            } else {
                ZStack {
                    mainContent
                    // 隐藏的 NavigationLink，用于手动导航
                    NavigationLink(
                        destination: selectedThread.map { PostView(postURL44: $0.url) },
                        isActive: Binding(
                            get: { selectedThread != nil },
                            set: { if !$0 { selectedThread = nil } }
                        )
                    ) {
                        EmptyView()
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview{
    ForumListView()
}
