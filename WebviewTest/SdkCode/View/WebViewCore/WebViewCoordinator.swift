//
//  WebViewContainer.swift
//  WebviewTest
//
//  Created by Nitin Prakash on 18/03/23.
//
import SwiftUI
import WebKit

internal extension WebView {
    class Coordinator: NSObject, WKNavigationDelegate {
        @State var isShowingMessageView = false
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        // This function is called when the page start loading
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.startLoading(in: webView)
        }
        
        // This function is called when the page finishes loading
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.stopLoading(in: webView) // Stop the activity indicator view
        }
        
        //  This function is called when the web view fails to load the page
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            UpswingLogger.logDebug("didFail: error: \(error)")
            parent.stopLoading(in: webView) // Stop the activity indicator view
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            UpswingLogger.logDebug("didFailProvisionalNavigation: error \(error)")
            parent.stopLoading(in: webView) // Stop the activity indicator view
        }
        
        // This function is called when the page is redirected to another url
        func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
            if let url = webView.url {
                UpswingLogger.logDebug("Redirected to: \(url.absoluteString)")
            }
        }
        
    }
}

