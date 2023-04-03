//
//  IPublishEventToWebView.swift
//  WebviewTest
//
//  Created by Nitin Prakash on 22/03/23.
//

import WebKit

protocol IPublishEventToWebView{
    
    func publishEvent(queueEventType: QueueEventType, payload: String)
    
    func publishCallbackDataToWebApp(callbackFunction: String, data: String)
}
