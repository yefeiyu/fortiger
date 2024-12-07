//
//  LoginView.swift
//  FourFour
//
//  Created by Charles Thomas on 12/1/24.
//

import CryptoKit
import SwiftUI

// 登录信息
struct LoginInfo {
    var username: String = ""
    var password: String = ""
}
// 登录视图
struct LoginView: View {
    @Binding var loginInfo: LoginInfo
    @Binding var isLoggingIn: Bool
    @Binding var errorMessage: String?
    var onLoginSuccess: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("用户登录")
                .font(.largeTitle)
                .padding(.top, 40)

            TextField("用户名", text: $loginInfo.username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            SecureField("密码", text: $loginInfo.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            if isLoggingIn {
                ProgressView()
            }

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }

            Button(action: {
                self.errorMessage = nil
                self.isLoggingIn = true
                self.performLogin()
            }) {
                Text("登录")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .disabled(isLoggingIn)

            Spacer()
        }
        .navigationTitle("登录")
    }
    func MD5(_ string: String) -> String {
        let digest = Insecure.MD5.hash(
            data: string.data(using: .utf8) ?? Data())
        return digest.map {
            String(format: "%02hhx", $0)
        }.joined()
    }
    func performLogin() {
        // 创建一个共享的 URLSession，用于保持会话
        let session = URLSession.shared

        // 登录页面的 URL
        let loginURLString =
            "https://www.4d4y.com/forum/logging.php?action=login&loginsubmit=yes"
        guard let loginURL = URL(string: loginURLString) else {
            DispatchQueue.main.async {
                self.errorMessage = "无效的登录 URL"
                self.isLoggingIn = false
            }
            return
        }

        // 构造登录请求的参数
        var parameters = [
            "loginfield": "username",
            "username": loginInfo.username,
            "password": loginInfo.password,
            "questionid": "0",
            "answer": "",
            "cookietime": "2592000",  // 记住登录状态
        ]

        parameters["password"] = MD5(parameters["password"]!)
        // 构造请求体
        let bodyString = parameters.map {
            "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        }.joined(separator: "&")
        let bodyData = bodyString.data(using: .utf8)!

        var request = URLRequest(url: loginURL)
        request.httpMethod = "POST"
        request.httpBody = bodyData
        request.setValue(
            "application/x-www-form-urlencoded",
            forHTTPHeaderField: "Content-Type")
        request.httpShouldHandleCookies = true  // 确保处理 Cookies

        // 发送登录请求
        session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoggingIn = false
            }

            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "网络错误：\(error.localizedDescription)"
                }
                return
            }

            guard let data = data,
                let responseHTML = String(data: data, encoding: .gbk)
            else {
                DispatchQueue.main.async {
                    self.errorMessage = "无法解析登录响应"
                }
                return
            }

            // 检查是否登录成功，可以根据返回的页面内容判断
            if responseHTML.contains("欢迎您回来") || responseHTML.contains("欢迎您访问")
            {
                // 登录成功
                DispatchQueue.main.async {
                    self.errorMessage = nil
                    self.onLoginSuccess()
                }
            } else {
                // 登录失败，可能需要进一步解析错误信息
                DispatchQueue.main.async {
                    self.errorMessage = "登录失败，用户名或密码错误"
                }
            }
        }.resume()
    }
}
