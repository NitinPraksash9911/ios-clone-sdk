//
//  Constant.swift
//  WebviewTest
//
//  Created by Nitin Prakash on 30/03/23.
//

import Foundation

class Constant {
    enum WebRoute {
        static let LOADING = "loading"
        static let CUSTOMER_INITIATE = "customerInitiate"
        static let AUTH = "auth"
        static let PCI_INPUT = "pciInput"
        static let LOGOUT = "\(AUTH)/logout"
    }
    
    enum WebViewRestrictedUrls {
        private static var videoKycUrls = Set<String>(["https://workapps.com/", "https://www.videocx.io/"])
        
        static func addVideoKycUrls(urls: [String]) {
            videoKycUrls.formUnion(urls)
        }
        
        static func getVideoKycUrls() -> [String] {
            return Array(videoKycUrls)
        }
    }
}
