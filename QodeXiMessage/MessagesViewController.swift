//
//  iMessageExtension.swift
//  iMessage app for sharing numerology insights
//

import Messages
import SwiftUI

class MessagesViewController: MSMessagesAppViewController {
    
    override func willBecomeActive(with conversation: MSConversation) {
        super.willBecomeActive(with: conversation)
        
        // Present SwiftUI view
        let contentView = NumerologyShareView { message in
            self.sendMessage(message)
        }
        
        let hostingController = UIHostingController(rootView: contentView)
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.frame = view.bounds
        hostingController.didMove(toParent: self)
    }
    
    private func sendMessage(_ text: String) {
        guard let conversation = activeConversation else { return }
        
        let message = MSMessage(session: conversation.selectedMessage?.session ?? MSSession())
        let layout = MSMessageTemplateLayout()
        layout.caption = text
        layout.subcaption = "QodeX Numerology"
        layout.image = generateShareImage()
        message.layout = layout
        
        conversation.send(message)
    }
    
    private func generateShareImage() -> UIImage? {
        let size = CGSize(width: 300, height: 300)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor(hex: "12121A")!.cgColor)
        context?.fill(CGRect(origin: .zero, size: size))
        
        let text = "✨" as NSString
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 100),
        ]
        let textSize = text.size(withAttributes: attributes)
        text.draw(at: CGPoint(x: (size.width - textSize.width) / 2, y: (size.height - textSize.height) / 2), withAttributes: attributes)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

struct NumerologyShareView: View {
    let onSend: (String) -> Void
    @State private var selectedNumber = 7
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Share Your Number")
                .font(.headline)
            
            // Number selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(1..<10) { number in
                        NumberBubble(
                            number: number,
                            isSelected: selectedNumber == number,
                            action: { selectedNumber = number }
                        )
                    }
                }
                .padding(.horizontal)
            }
            
            // Preview
            VStack(spacing: 8) {
                Text("\(selectedNumber)")
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .foregroundColor(.gold)
                
                Text(getVibe(for: selectedNumber))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.deepVoid)
            .cornerRadius(16)
            
            Button("Send") {
                let message = "My number today is \(selectedNumber) - \(getVibe(for: selectedNumber))"
                onSend(message)
            }
            .buttonStyle(QXPrimaryButtonStyle())
            .padding(.horizontal)
        }
        .padding()
        .background(Color.cosmicBlack)
    }
    
    private func getVibe(for number: Int) -> String {
        let vibes = ["", "New Beginnings", "Partnership", "Creativity", "Foundation", "Freedom", "Harmony", "Wisdom", "Abundance", "Completion"]
        return vibes[number]
    }
}

struct NumberBubble: View {
    let number: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("\(number)")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .black : .gold)
                .frame(width: 50, height: 50)
                .background(isSelected ? Color.gold : Color.deepVoid)
                .clipShape(Circle())
        }
    }
}
