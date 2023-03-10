//
//  AgoraRTMManager.swift
//  AgoraRtm-Basic
//
//  Created by Max Cobb on 08/03/2023.
//

import Foundation
import AgoraRtmKit

class AgoraRTMManager: NSObject, ObservableObject {

    private var agoraRTM: AgoraRtmKit!
    private let appId: String = <#Agora App ID#>
    private let channelName = "lobby"
    private var channel: AgoraRtmChannel?
    public struct RtmDisplayMessage: Equatable, Identifiable {
        var message: AgoraRtmMessage
        var id: String
        var sender: String
        var text: String { message.text }
    }
    @Published var messages: [RtmDisplayMessage] = []

    override init() {
        super.init()
        self.agoraRTM = AgoraRtmKit(appId: appId, delegate: self)
    }

    func login(userName: String) async {
        let loginErr = await agoraRTM?.login(byToken: <#Agora Token or nil#>, user: userName)
        if loginErr != .alreadyLogin, loginErr != .ok {
            fatalError("Failed to log in: \(String(describing: loginErr?.rawValue))")
        }
        await self.joinChannel()
    }

    func sendMessage(_ message: String) async {
        let agoraMessage = AgoraRtmMessage(text: message)
        let sendMsgErr = await channel?.send(agoraMessage)
        if sendMsgErr == .errorOk {
            DispatchQueue.main.async {
                self.messages.append(RtmDisplayMessage(message: agoraMessage, id: UUID().uuidString, sender: ""))
            }
        }
    }

    private func joinChannel() async {
        guard let channel = agoraRTM?.createChannel(withId: channelName, delegate: self) else {
            return
        }
        self.channel = channel
        let joinErr = await channel.join()
        if joinErr != .channelErrorOk && joinErr != .channelErrorAlreadyJoined {
            print("Failed to join channel: \(joinErr.rawValue)")
        }
    }
}

extension AgoraRTMManager: AgoraRtmDelegate {
    func rtmKit(_ kit: AgoraRtmKit, messageReceived message: AgoraRtmMessage, fromPeer peerId: String) {
        DispatchQueue.main.async { [weak self] in
            self?.messages.append(RtmDisplayMessage(message: message, id: UUID().uuidString, sender: peerId))
        }
    }
}

extension AgoraRTMManager: AgoraRtmChannelDelegate {
    func channel(_ channel: AgoraRtmChannel, messageReceived message: AgoraRtmMessage, from member: AgoraRtmMember) {
        DispatchQueue.main.async { [weak self] in
            self?.messages.append(RtmDisplayMessage(message: message, id: UUID().uuidString, sender: member.userId))
        }
    }
}
