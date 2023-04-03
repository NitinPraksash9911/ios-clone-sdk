//
//  Logger.swift
//  WebviewTest
//
//  Created by Nitin Prakash on 18/03/23.
//

import os
import UIKit
import WebKit

internal class UpswingLogger {
    private init(){}
    
    private static let logger = Logger()
    
    static func logDebug(_ message: String) {
        logger.debug("debug: \(message)")
    }
    
    
    

   static func showToast(message: String, webView: WKWebView) {
       guard let webViewSuperview = webView.superview else { return }
        
        let toastLabel = UILabel()
        toastLabel.textColor = UIColor.white
        toastLabel.font = UIFont.systemFont(ofSize: 16.0)
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        
        let maxWidth = webViewSuperview.bounds.width - 40
        let toastWidth = min(maxWidth, toastLabel.intrinsicContentSize.width + 20)
        let toastHeight = toastLabel.intrinsicContentSize.height + 10
        toastLabel.frame = CGRect(x: 0, y: 0, width: toastWidth, height: toastHeight)
        toastLabel.center = CGPoint(x: webViewSuperview.bounds.width / 2, y: webViewSuperview.bounds.height / 2)
        
        webViewSuperview.addSubview(toastLabel)
        
        UIView.animate(withDuration: 2.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }

    
    
}
