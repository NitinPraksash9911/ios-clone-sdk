//
//  PublishEventtoWebView.swift
//  WebviewTest
//
//  Created by Nitin Prakash on 22/03/23.
//

import WebKit

class PublishEventToWebView: IPublishEventToWebView{
    
    private var webView:WKWebView
    init(webView:WKWebView ){
        self.webView = webView
    }
    
    func publishEvent( queueEventType: QueueEventType, payload: String) {
        let jsCode = """
               publishEvent('\(queueEventType)', '\(payload)');
           """
        UpswingLogger.logDebug("jsCode-> \(jsCode)")
        webView.evaluateJavaScript(jsCode) { (result, error) in
            if let error = error {
                UpswingLogger.logDebug("Failed to call JavaScript function: \(error)")
                return
            }
            if let result = result as? String {
                UpswingLogger.logDebug("Result of JavaScript function call: \(result)")
            }
        }
    }
    
    func publishCallbackDataToWebApp(callbackFunction: String, data: String) {
        let payload = convertDataToJsonPayload(callbackFunction: callbackFunction, data: data)
        
        UpswingLogger.logDebug("jsCode callback-> \(payload)")
            
        webView.evaluateJavaScript(payload) { (result, error) in
            if let error = error {
                UpswingLogger.logDebug("Failed to call JavaScript function: \(error)")
                return
            }
            if let result = result as? String {
                UpswingLogger.logDebug("Result of JavaScript function call: \(result)")
            }
        }
    }
    
    
    private func convertDataToJsonPayload(callbackFunction: String, data: String)->String {
        do {
            let eventData = ["data": data]
            let jsonData = try JSONEncoder().encode(eventData)
            let jsonString = String(data: jsonData, encoding: .utf8) ?? "{}"
            let payload = "(\(callbackFunction))(\(jsonString));"
            return payload
        } catch {
            UpswingLogger.logDebug("Error encoding event data as JSON: \(error.localizedDescription)")
            return ""
        }
    }
}
