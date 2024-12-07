// ForumListView+Login.swift
import SwiftUI

extension ForumListView {
    /// 登录视图
    var loginView: some View {
        LoginView(
            loginInfo: $loginInfo,
            isLoggingIn: $isLoggingIn,
            errorMessage: $errorMessage,
            onLoginSuccess: {
                self.showLogin = false
                Task {
                    await self.loadThreads()
                }
            }
        )
    }
}
