//
//  MentorshipCallManager.swift
//  CallKit integration for mentorship sessions
//

import Foundation
import CallKit
import PushKit
import AVFoundation

class MentorshipCallManager: NSObject, CXProviderDelegate {
    static let shared = MentorshipCallManager()
    
    private let provider: CXProvider
    private let callController: CXCallController
    private var currentCall: UUID?
    
    override init() {
        let configuration = CXProviderConfiguration(localizedName: "QodeX Mentorship")
        configuration.supportsVideo = true
        configuration.supportedHandleTypes = [.generic]
        configuration.iconTemplateImageData = UIImage(named: "AppIcon")?.pngData()
        configuration.ringtoneSound = "ringtone.caf"
        
        provider = CXProvider(configuration: configuration)
        callController = CXCallController()
        
        super.init()
        
        provider.setDelegate(self, queue: nil)
    }
    
    // MARK: - Report Incoming Call
    func reportIncomingCall(from mentorName: String, sessionId: String) {
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: mentorName)
        update.hasVideo = true
        update.localizedCallerName = "\(mentorName) - QodeX Mentorship"
        
        let uuid = UUID()
        currentCall = uuid
        
        provider.reportNewIncomingCall(with: uuid, update: update) { error in
            if let error = error {
                print("❌ Failed to report call: \(error)")
            } else {
                print("✅ Incoming call reported")
            }
        }
    }
    
    // MARK: - Start Outgoing Call
    func startCall(to mentorId: String, mentorName: String) {
        let handle = CXHandle(type: .generic, value: mentorId)
        let startCallAction = CXStartCallAction(call: UUID(), handle: handle)
        startCallAction.isVideo = true
        startCallAction.contactIdentifier = mentorName
        
        let transaction = CXTransaction(action: startCallAction)
        
        callController.request(transaction) { error in
            if let error = error {
                print("❌ Failed to start call: \(error)")
            } else {
                print("✅ Call started")
            }
        }
    }
    
    // MARK: - End Call
    func endCall() {
        guard let uuid = currentCall else { return }
        
        let endCallAction = CXEndCallAction(call: uuid)
        let transaction = CXTransaction(action: endCallAction)
        
        callController.request(transaction) { error in
            if let error = error {
                print("❌ Failed to end call: \(error)")
            }
        }
    }
    
    // MARK: - CXProviderDelegate
    func providerDidReset(_ provider: CXProvider) {
        print("Provider reset")
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        // User answered the call
        configureAudioSession()
        
        // Connect to video session
        connectToSession()
        
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        // User ended the call
        disconnectFromSession()
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        // User put call on hold
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        // User muted/unmuted
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        print("Audio session activated")
    }
    
    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        print("Audio session deactivated")
    }
    
    // MARK: - Private Methods
    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, mode: .videoChat, options: .defaultToSpeaker)
        try? session.setActive(true)
    }
    
    private func connectToSession() {
        // Connect to WebRTC or video provider
    }
    
    private func disconnectFromSession() {
        // Disconnect from video session
        currentCall = nil
    }
}

// MARK: - PushKit for VoIP
class MentorshipPushRegistry: NSObject, PKPushRegistryDelegate {
    static let shared = MentorshipPushRegistry()
    private let pushRegistry = PKPushRegistry(queue: .main)
    
    func registerForPushNotifications() {
        pushRegistry.delegate = self
        pushRegistry.desiredPushTypes = [.voIP]
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
        // Send credentials to server
        let token = credentials.token.map { String(format: "%02.2hhx", $0) }.joined()
        print("✅ VoIP token: \(token)")
        
        // Upload to Firebase
        Task {
            await uploadToken(token)
        }
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        // Handle incoming call notification
        guard let dictionaryPayload = payload.dictionaryPayload as? [String: Any],
              let mentorName = dictionaryPayload["mentorName"] as? String,
              let sessionId = dictionaryPayload["sessionId"] as? String else {
            completion()
            return
        }
        
        MentorshipCallManager.shared.reportIncomingCall(from: mentorName, sessionId: sessionId)
        completion()
    }
    
    private func uploadToken(_ token: String) async {
        guard let userId = AuthManager.shared.currentUser?.id else { return }
        
        let db = Firestore.firestore()
        try? await db.collection("users").document(userId).updateData([
            "voIPToken": token,
            "tokenUpdatedAt": FieldValue.serverTimestamp()
        ])
    }
}
