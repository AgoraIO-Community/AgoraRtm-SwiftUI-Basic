//
//  ContentView.swift
//  AgoraRtm-Basic
//
//  Created by Max Cobb on 08/03/2023.
//

import SwiftUI
import AgoraRtmKit

struct ContentView: View {
    @StateObject private var agoraRTMManager = AgoraRTMManager()
    @State private var userName: String = ""
    @State private var message: String = ""
    @State var showUsername = true

    var body: some View {
        VStack {
            if showUsername {
                TextField("Enter your username", text: $userName)
                    .padding().background(.gray.opacity(0.2))
                    .cornerRadius(8).padding()
                Button("Join") {
                    Task {
                        await agoraRTMManager.login(userName: userName)
                        self.showUsername = false
                    }
                }.disabled(userName.isEmpty)
            } else {
                MessagesList(agoraRTMManager: agoraRTMManager)

                MessageInput(agoraRTMManager: agoraRTMManager).onAppear {
                    self.agoraRTMManager.messages.append(contentsOf: [
                        .init(message: AgoraRtmMessage(text: "First!"), id: UUID().uuidString, sender: "Jimmy"),
                        .init(message: AgoraRtmMessage(text: "Hello world"), id: UUID().uuidString, sender: "Dorothy"),
                        .init(message: AgoraRtmMessage(text: "What time is it?"), id: UUID().uuidString, sender: ""),
                        .init(message: AgoraRtmMessage(text: "Lunch time!"), id: UUID().uuidString, sender: "Gunther")
                    ])
                }
            }
        }.padding(.top, 50)
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct MessageInput: View {
    @StateObject var agoraRTMManager: AgoraRTMManager
    @State var message: String = ""
    var body: some View {
        HStack {
            TextField("Type your message", text: $message)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)

            Button("Send") {
                Task {
                    await agoraRTMManager.sendMessage(message)
                    message = ""
                }
            }.padding(.horizontal).disabled(message.isEmpty)
        }.padding()
    }
}

struct MessagesList: View {
    @StateObject var agoraRTMManager: AgoraRTMManager
    var body: some View {
        ScrollView {
            ScrollViewReader { scrollView in
                ForEach(agoraRTMManager.messages) { message in
                    HStack {
                        if message.sender.isEmpty {
                            Spacer()
                        }
                        VStack(alignment: .leading) {
                            if !message.sender.isEmpty {
                                Text(message.sender)
                            }
                            Text("\(message.text)")
                                .padding()
                                .foregroundColor(Color.white)
                                .background(message.sender.isEmpty ? .gray : .blue)
                                .cornerRadius(8)
                        }.padding(.horizontal)
                        if !message.sender.isEmpty {
                            Spacer()
                        }
                    }
                }.onChange(of: agoraRTMManager.messages) { _ in
                    withAnimation {
                        scrollView.scrollTo(agoraRTMManager.messages.last?.id, anchor: .bottom)
                    }
                }
            }
        }
    }
}
