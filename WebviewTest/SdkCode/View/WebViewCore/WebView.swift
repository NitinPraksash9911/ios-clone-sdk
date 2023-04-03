//
//  WebView.swift
//  WebviewTest
//
//  Created by Nitin Prakash on 18/03/23.
//

import SwiftUI
import WebKit
import CalendarControl
import CryptoKit

internal final class WebView: UIViewRepresentable {
    @ObservedObject var viewModel: WebViewModel
    
    let jsonEncoder: JSONEncoder = JSONEncoder()
    let iosBridge: String = "iosBridge"
    
    private var guestSessionToken: String = ""
    private var privateKey: Curve25519.Signing.PrivateKey?
    private var publicKey: Curve25519.Signing.PublicKey?
    
    private  var publishEventToWebView: IPublishEventToWebView?
    var parentDismiss: DismissAction
    
    init(viewModel: WebViewModel, dismiss:DismissAction){
        self.viewModel = viewModel
        self.parentDismiss = dismiss
        loadPrivateKey()
    }
    
    private func loadPrivateKey(){
        if (KeychainWrapper.sharedInstance.hasPrivateKey()) {
            privateKey = KeychainWrapper.sharedInstance.getPrivateKey()
            publicKey = privateKey?.publicKey
        }
    }
    
    
    
    //overridden function
    func makeUIView(context: Context) -> WKWebView {
        
        let configuration = WKWebViewConfiguration()
        let preferences = WKWebpagePreferences()
        
        preferences.allowsContentJavaScript = true
        configuration.defaultWebpagePreferences = preferences
        let coordinator = self.makeCoordinator()
        // Here "iOSNative" is our interface name that we pushed to the website that is being loaded
        // Safely unwrap coordinator using optional binding
        configuration.userContentController.add(coordinator, name: iosBridge)
        
        let webView = constructWkWebView(context: context, configuration: configuration)
        publishEventToWebView = PublishEventToWebView(webView: webView)
        
        loadUrl(webView: webView)
        
        return webView
    }
    
    private func loadUrl(webView: WKWebView){
        let request = URLRequest(url: URL(string: viewModel.url)!)
        UpswingLogger.logDebug("initial load url: \(viewModel.url)")
        webView.load(request)
    }
    
    private func constructWkWebView(context: Context, configuration: WKWebViewConfiguration)->WKWebView{
        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        
        webView.navigationDelegate = context.coordinator
        
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.isScrollEnabled = true
        
        return webView
    }
    
    
    
    // Add an activity indicator view to the web view's superview and start it
    func startLoading(in webView: WKWebView) {
        let activityIndicatorView = UIActivityIndicatorView(style: .medium)
        activityIndicatorView.color = .black
        activityIndicatorView.center = webView.center
        activityIndicatorView.startAnimating()
        webView.addSubview(activityIndicatorView)
        
        let label = UILabel()
        label.text = "Loading..."
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        label.sizeToFit()
        label.center = CGPoint(x: activityIndicatorView.center.x, y: activityIndicatorView.center.y + 30)
        webView.addSubview(label)
    }
    
    // Remove the activity indicator view from the web view and stop it
    func stopLoading(in webView: WKWebView) {
        for subview in webView.subviews {
            if subview is UIActivityIndicatorView || subview is UILabel {
                subview.removeFromSuperview()
            }
        }
    }
    
    //overridden function to load local url
    //    func updateUIView(_ uiView: WKWebView, context: Context) {
    //        if let indexURL = Bundle.main.url(forResource: "local", withExtension: "html", subdirectory: "LocalWebApp") {
    //            uiView.loadFileURL(indexURL, allowingReadAccessTo: indexURL)
    //        }
    //    }
    
    
    //overridden function
    func updateUIView(_ uiView: WKWebView, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    internal func publishJsEvent(queueEventType: QueueEventType, payload: String){
        publishEventToWebView!.publishEvent(queueEventType: queueEventType, payload: payload)
    }
    
    internal func publishJsCallbackDataToWebApp(callbackFunction: String, data: String){
        publishEventToWebView!.publishCallbackDataToWebApp(callbackFunction: callbackFunction, data: data)
    }
    
}

extension WebView {
    
    enum CustomerInitiationError: Error {
        case failureResponse(String)
        case unknownResponse(String)
    }
    
    func initiatePartnerCustomer() {
        viewModel.initiateCustomer.initiate { [weak self] response in
            guard let self = self else { return }
            
            do {
                
                try self.handleResponse(response)
                
            }catch{
                UpswingLogger.logDebug("initiateCustomer error: \(error)")
            }
        }
    }
    
    func handleResponse(_ response: CustomerInitiationResponse) throws {
        
        switch response {
            
        case let successResponse as SuccessCustomerInitiationResponse:
            
            let customerId = successResponse.internalCustomerId
            let sessionToken = successResponse.guestSessionToken
            
            UpswingLogger.logDebug("Received success response: internalCustomerId=\(customerId), guestSessionToken=\(sessionToken)")
            
            onCustomerInitiated(internaCutomerId: customerId, guestSessionToken: sessionToken)
            
        case is FailureCustomerInitiationResponse:
            throw CustomerInitiationError.failureResponse("failure response from partner")
            
        default:
            throw CustomerInitiationError.failureResponse("Unknow response from parter")
        }
    }
    
    
    private func onCustomerInitiated(internaCutomerId: String, guestSessionToken: String){
        let url = "/\(Constant.WebRoute.AUTH)/\(Constant.WebRoute.CUSTOMER_INITIATE)"
        publishEventToLoadURL(url: url)
        
        privateKey = Curve25519.Signing.PrivateKey()
        
        self.publicKey = privateKey?.publicKey
        self.guestSessionToken = guestSessionToken
        
        let guestTokenStr = guestSessionToken.data(using: .utf8)?.base64EncodedString() // find a way to convert string to
        let pubKeyStr = publicKey?.rawRepresentation.base64EncodedString()
        
        UpswingLogger.logDebug("onCustomerInitiated-> guestTokenStr size: \(String(describing: guestTokenStr?.count))")
        UpswingLogger.logDebug("onCustomerInitiated-> pubKeyStr size: \(String(describing: pubKeyStr?.count))")
        
        publishEventForPublicKeyCreated(
            publicKeyEncoded: pubKeyStr ?? "NA",
            guestSessionTokenEncoded: guestTokenStr ?? "NA",
            guestSessionToken: guestSessionToken,
            internalCustomerId: internaCutomerId
        )
        
    }
    
    
    func nullifyKeypair() {
        privateKey = nil
        publicKey = nil
        KeychainWrapper.sharedInstance.removePrivateKey()
    }
    
    func validateGuestSessionToken(guestSessionToken: String) {
        if (self.guestSessionToken == guestSessionToken) {
            KeychainWrapper.sharedInstance.setPrivateKey(pvtKey: privateKey!)
        }
    }
    
    func exitSdk() {
        UpswingLogger.logDebug("exist sdk called in webview class")
        parentDismiss()
    }
}
