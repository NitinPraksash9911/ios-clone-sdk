//
//  MessageView.swift
//  WebviewTest
//
//  Created by Nitin Prakash on 22/03/23.
//

import SwiftUI
import MessageUI

struct MessageView: UIViewControllerRepresentable {
    @Binding var isShowingMessageView: Bool
    var recipients:String
    var body:String
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = MFMessageComposeViewController()
        controller.messageComposeDelegate = context.coordinator
        controller.recipients = [self.recipients]
        controller.body = self.body
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Nothing to do here
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(isShowingMessageView: $isShowingMessageView)
    }
    
    class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        @Binding var isShowingMessageView: Bool
        
        init(isShowingMessageView: Binding<Bool>) {
            _isShowingMessageView = isShowingMessageView
        }
        
        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            switch result {
            case .cancelled:
                print("Message cancelled")
            case .sent:
                print("Message sent")
            case .failed:
                print("Message failed")
            default:
                break
            }
            
            isShowingMessageView = false
        }
    }
}
