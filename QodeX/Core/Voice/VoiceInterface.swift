//
//  VoiceInterface.swift
//  Voice control and accessibility
//

import SwiftUI
import Speech
import AVFoundation

class VoiceInterfaceManager: NSObject, ObservableObject, SFSpeechRecognizerDelegate {
    static let shared = VoiceInterfaceManager()
    
    @Published var isListening = false
    @Published var transcribedText = ""
    @Published var recognizedCommand: VoiceCommand?
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    enum VoiceCommand {
        case calculateLifePath
        case showDailyNumber
        case startMeditation(minutes: Int)
        case openChart(type: String)
        case explainNumber(Int)
        case unknown
    }
    
    override init() {
        super.init()
        speechRecognizer?.delegate = self
        requestAuthorization()
    }
    
    // MARK: - Authorization
    private func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    print("✅ Speech recognition authorized")
                case .denied, .restricted, .notDetermined:
                    print("❌ Speech recognition not available")
                @unknown default:
                    break
                }
            }
        }
        
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            print(granted ? "✅ Microphone access granted" : "❌ Microphone access denied")
        }
    }
    
    // MARK: - Start Listening
    func startListening() {
        guard !isListening else { return }
        
        resetAudioSession()
        
        request = SFSpeechAudioBufferRecognitionRequest()
        guard let request = request else { return }
        
        request.shouldReportPartialResults = true
        request.taskHint = .confirmation
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request) { [weak self] result, error in
            guard let self = self else { return }
            
            if let result = result {
                self.transcribedText = result.bestTranscription.formattedString
                
                if result.isFinal {
                    self.processCommand(self.transcribedText)
                    self.stopListening()
                }
            }
            
            if error != nil {
                self.stopListening()
            }
        }
        
        // Configure audio engine
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request?.append(buffer)
        }
        
        audioEngine.prepare()
        try? audioEngine.start()
        
        isListening = true
    }
    
    // MARK: - Stop Listening
    func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        request?.endAudio()
        request = nil
        
        recognitionTask?.cancel()
        recognitionTask = nil
        
        isListening = false
    }
    
    // MARK: - Process Command
    private func processCommand(_ text: String) {
        let lowercased = text.lowercased()
        
        if lowercased.contains("life path") || lowercased.contains("my number") {
            recognizedCommand = .calculateLifePath
        } else if lowercased.contains("today") || lowercased.contains("daily") {
            recognizedCommand = .showDailyNumber
        } else if lowercased.contains("meditate") {
            let minutes = extractNumber(from: text) ?? 10
            recognizedCommand = .startMeditation(minutes: minutes)
        } else if lowercased.contains("chart") {
            recognizedCommand = .openChart(type: "full")
        } else if lowercased.contains("explain") {
            if let number = extractNumber(from: text) {
                recognizedCommand = .explainNumber(number)
            }
        } else {
            recognizedCommand = .unknown
        }
        
        // Provide haptic feedback
        if recognizedCommand != .unknown {
            QXHaptic.success()
        }
    }
    
    private func extractNumber(from text: String) -> Int? {
        let numbers = text.components(separatedBy: CharacterSet.decimalDigits.inverted)
            .compactMap { Int($0) }
        return numbers.first
    }
    
    // MARK: - Text to Speech
    func speak(_ text: String, completion: (() -> Void)? = nil) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
    
    // MARK: - Voice Responses
    func respondToCommand(_ command: VoiceCommand) {
        let response: String
        
        switch command {
        case .calculateLifePath:
            response = "I'll calculate your life path number now. Please enter your birth date."
        case .showDailyNumber:
            response = "Today's number is 8, representing power and abundance."
        case .startMeditation(let minutes):
            response = "Starting a \(minutes) minute meditation session."
        case .openChart:
            response = "Opening your complete numerology chart."
        case .explainNumber(let number):
            response = "Number \(number) represents \(getNumberMeaning(number))."
        case .unknown:
            response = "I'm not sure what you're asking. Try saying 'show my daily number' or 'calculate my life path'."
        }
        
        speak(response)
    }
    
    private func getNumberMeaning(_ number: Int) -> String {
        let meanings: [Int: String] = [
            1: "leadership and independence",
            2: "partnership and diplomacy",
            3: "creativity and expression",
            4: "stability and foundation",
            5: "freedom and adventure",
            6: "harmony and responsibility",
            7: "wisdom and spirituality",
            8: "power and abundance",
            9: "completion and humanitarianism"
        ]
        return meanings[number] ?? "spiritual growth"
    }
    
    private func resetAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    }
}

// MARK: - Voice Button
struct VoiceButton: View {
    @StateObject private var voiceManager = VoiceInterfaceManager.shared
    @State private var pulseAnimation = false
    
    var body: some View {
        Button(action: {
            if voiceManager.isListening {
                voiceManager.stopListening()
            } else {
                voiceManager.startListening()
            }
        }) {
            ZStack {
                Circle()
                    .fill(voiceManager.isListening ? Color.red : Color.gold)
                    .frame(width: 64, height: 64)
                
                if voiceManager.isListening {
                    Circle()
                        .stroke(Color.red, lineWidth: 2)
                        .frame(width: 80, height: 80)
                        .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                        .opacity(pulseAnimation ? 0 : 1)
                }
                
                Image(systemName: voiceManager.isListening ? "waveform" : "mic.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }
        }
        .onAppear {
            if voiceManager.isListening {
                withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    pulseAnimation = true
                }
            }
        }
        .onChange(of: voiceManager.isListening) { isListening in
            if isListening {
                withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    pulseAnimation = true
                }
            } else {
                pulseAnimation = false
            }
        }
    }
}

// MARK: - Voice Interface Overlay
struct VoiceInterfaceOverlay: View {
    @StateObject private var voiceManager = VoiceInterfaceManager.shared
    
    var body: some View {
        VStack {
            Spacer()
            
            if voiceManager.isListening {
                VStack(spacing: 20) {
                    Text(voiceManager.transcribedText.isEmpty ? "Listening..." : voiceManager.transcribedText)
                        .font(.title3)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    VoiceButton()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black.opacity(0.8))
                .cornerRadius(20)
                .padding()
            }
        }
    }
}
