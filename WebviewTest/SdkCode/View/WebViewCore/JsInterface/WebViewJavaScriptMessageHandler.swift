//
//  WebViewJavaScriptMessageHandler.swift
//  UpswingSdk
//
//  Created by Nitin Prakash on 22/03/23.
//

import WebKit
import MessageUI
import CryptoKit



extension WebView.Coordinator: WKScriptMessageHandler, MFMessageComposeViewControllerDelegate {
    
    private typealias JSFunction = (Dictionary<String, Any>) -> Void

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        //proxy check
        guard isURLAllowed(message.webView?.url, parentURLString: parent.viewModel.url), message.name == parent.iosBridge else {
            UpswingLogger.logDebug("not allowed")
            return
        }
        
        guard let dict = message.body as? [String : Any], let functionName = dict["functionName"] as? String else {
            return
        }
        
        UpswingLogger.logDebug("js called \(functionName)")
        
        
        let functionMap: [String: JSFunction] = [
            // Permissions
            "askPermissionsFromSettings":          askPermissionsFromSettings,
            "hasReadPhoneStatePermission":         hasReadPhoneStatePermission,
            "hasSmsPermission":                    hasSmsPermission,
            "getSmsAndReadPhoneStatePermissions":  getSmsAndReadPhoneStatePermissions,
            "getSmsPermission":                    getSmsPermission,
            
            // Customer
            "initiateCustomer":                    initiateCustomer,
            "isCustomerInitialized":               isCustomerInitialized,
            
            // Device
            "clear":                               clear,
            "getDeviceId":                         getDeviceId,
            "getDeviceSpecs":                      getDeviceSpecs,
            "getWebViewVersion":                   getWebViewVersion,
            "isDeviceRooted":                      isDeviceRooted,
            
            // External services
            "getFcmToken":                         getFcmToken,
            "getPartnerUid":                       getPartnerUid,
            "getYesBankDeviceToken":               getYesBankDeviceToken,
            
            // Guest session
            "onGuestSessionPollingOver":           onGuestSessionPollingOver,
            "validateGuestSessionToken":           validateGuestSessionToken,
            
            // Item storage
            "getItem":                             getItem,
            "removeItem":                          removeItem,
            "setItem":                             setItem,
            
            // Messaging
            "canSendSms":                          canSendSms,
            "getSimSubscriptionIdFromSlot":        getSimSubscriptionIdFromSlot,
            "selectSIMCard":                       selectSIMCard,
            "sendSms":                             sendSms,
            
            // Miscellaneous
            "createToast":                         createToast,
            "existSdk":                            existSdk,
            "generateSignature":                   generateSignature,
            "isPersistentStorageLoaded":           isPersistentStorageLoaded,
            "logout":                              logout,
            "pciSubmitHandler":                    pciSubmitHandler,
            "isPciSubmitHandlerEnabled":           isPciSubmitHandlerEnabled,
            "setExternalUrls":                     setExternalUrls,
            "version":                             version,
        ]
        
        guard let function = functionMap[functionName] else {
            UpswingLogger.logDebug("js called \(functionName)(), which not defined on sdk")
            return
        }
        
        function(dict)
        
        
    }
    
    //this will be the call back from sms send
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case .cancelled:
            UpswingLogger.logDebug("Sms Cancelled")
            parent.publishEventForFailureSendSMS(errorMsg: "Sms Cancelled")
        case .sent:
            parent.publishEventForSuccessSendSMS(msg: "Sms Sent")
            UpswingLogger.logDebug("Sms sent")
        case .failed:
            parent.publishEventForFailureSendSMS(errorMsg: "Sms failed")
            UpswingLogger.logDebug("Sms failed")
        default:
            break
        }
    }
    
    //Poxy check for js function
    private func isURLAllowed(_ url: URL?, parentURLString: String) -> Bool {
        guard let url = url, url.absoluteString.hasPrefix(parentURLString) else {
            UpswingLogger.logDebug("Blocked JavaScript call from: \(url?.absoluteString ?? "unknown")")
            return false
        }
        
        UpswingLogger.logDebug("Allowed JavaScript call")
        return true
    }
}


private extension WebView.Coordinator {
    
    private func createToast(_ dict: [String: Any]) {
        if let message = dict["message"] as? String {
            UpswingLogger.logDebug(message)
        }
        
    }
    
    private  func isPersistentStorageLoaded(_ dict: [String: Any]) {
        executeJsCallback(with: dict){
            return String(true)
        }
    }
    
    private func canSendSms(_ dict: [String: Any]) {
        let canSendText = MFMessageComposeViewController.canSendText()
        let response = String(canSendText)
        executeJsCallback(with: dict){
            return response
        }
    }
    
    
    // TODO: check publish send sms event
    private func sendSms(_ dict: [String: Any]) {
        
        guard MFMessageComposeViewController.canSendText() else {
            UpswingLogger.logDebug("sendSms called but device cannot send message")
            return
        }
        
        guard let message = dict["message"] as? String,
              let recipient = dict["recipient"] as? String else {
            UpswingLogger.logDebug("sendSms invalid params")
            return
        }
        
        let messageVC = MFMessageComposeViewController()
        messageVC.messageComposeDelegate = self
        messageVC.recipients = [recipient]
        messageVC.body = message
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let viewController = windowScene.windows.first?.rootViewController {
            viewController.present(messageVC, animated: true, completion: nil)
        }
    }
    
    
    private func version(_ dict: [String: Any]) {
        executeJsCallback(with: dict) {
            return SdkInfo().version
        }
    }
    
    
    private func isCustomerInitialized(_ dict: [String: Any]) {
        executeJsCallback(with: dict){
            let hasPrivateKey = KeychainWrapper.sharedInstance.hasPrivateKey()
            let response = String(hasPrivateKey)
            return response
        }
    }
    
    
    //TODO: check for permission
    func hasSmsPermission(_ dict: [String: Any]) {
        executeJsCallback(with: dict){
            return String(true)
        }
    }
    
    //    //TODO: not required
    func getSmsPermission(_ dict: [String: Any]) {}
    
    
    //TODO: check for permission Phone state when device available
    func hasReadPhoneStatePermission(_ dict: [String: Any]) {
        executeJsCallback(with: dict){
            return String(true)
        }
    }
    
    //TODO: check for permission Phone state when device available
    func getSmsAndReadPhoneStatePermissions(_ dict: [String: Any]) {
    }
    
    
    //TODO: check for permission Phone state when device available
    func askPermissionsFromSettings(_ dict: [String: Any]) {
        //           permissionUtil.goToSettingForPermissions()
    }
    
    func initiateCustomer(_ dict: [String: Any]) {
        parent.initiatePartnerCustomer()
    }
    
    
    func getItem(_ dict: [String: Any]) {
        guard let key = dict["key"] as? String else {
            UpswingLogger.logDebug("getItem invalid params")
            return
        }
        
        executeJsCallback(with: dict){
            let value = KeychainWrapper.sharedInstance.getValueForWebView(key: key) ?? ""
            return value
        }
    }
    
    
    func setItem(_ dict: [String: Any]) {
        guard let key = dict["key"] as? String,
              let value = dict["value"] as? String else {
            UpswingLogger.logDebug("setItem invalid params")
            return
        }
        
        KeychainWrapper.sharedInstance.setValueFromWebView(key: key, value: value)
    }
    
    func removeItem(_ dict: [String: Any]) {
        guard let key = dict["key"] as? String else {
            UpswingLogger.logDebug("removeItem invalid params")
            return
        }
        
        KeychainWrapper.sharedInstance.removeValueFromWebView(key: key)
    }
    
    func getDeviceSpecs(_ dict: [String: Any]){
        
        executeJsCallback(with: dict){
            return DeviceSpecs.getDeviceSpecsAsJSON()
        }
    }
    
    func getWebViewVersion(_ dict: [String: Any]){
        executeJsCallback(with: dict){
            let webViewVersion = WKWebView().configuration.applicationNameForUserAgent
            return webViewVersion ?? "Not found"
        }
    }
    
    func clear(_ dict: [String: Any]) {
        KeychainWrapper.sharedInstance.clear()
    }
    
    func validateGuestSessionToken(_ dict: [String: Any]) {
        guard let guestSessionToken = dict["guestSessionToken"] as? String else {
            UpswingLogger.logDebug("validateGuestSessionToken invalid params")
            return
        }
        parent.validateGuestSessionToken(guestSessionToken: guestSessionToken)
    }
    
    
    func generateSignature(_ dict: [String: Any]) {
        
        guard let payload = dict["payload"] as? String else {
            UpswingLogger.logDebug("generateSignature invalid params")
            return
        }
        
        executeJsCallback(with: dict){
            do {
                let payloadData = Data(payload.utf8)
                let privateKey = KeychainWrapper.sharedInstance.getPrivateKey().rawRepresentation.base64EncodedString()
                let privateKeyData = Data(base64Encoded: privateKey)!
                let signature = try Curve25519.Signing.PrivateKey(rawRepresentation:privateKeyData).signature(for: payloadData)
                return signature.base64EncodedString()
            }catch{
                UpswingLogger.logDebug("generateSignature failed: \(error)")
                return ""
            }
        }
    }
    
    
    func onGuestSessionPollingOver(_ dict: [String: Any]) {
        parent.nullifyKeypair()
    }
    
    func isDeviceRooted(_ dict: [String: Any]) {
        executeJsCallback(with: dict){
            let isJailBroken = JailBreakUtil.isJailBroken
            return String(isJailBroken)
        }
    }
    
    func getDeviceId(_ dict: [String: Any]) {
        executeJsCallback(with: dict){
            let deviceId = KeychainWrapper.sharedInstance.getDeviceId()
            return deviceId
        }
    }
    
    
    //TODO: check for permission Phone state when device available
    func getSimSubscriptionIdFromSlot(_ dict: [String: Any]) {
        
        executeJsCallback(with: dict){
            return String(-1)
        }
        
        //           val subscriptionManager: SubscriptionManager =
        //               activity.getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as SubscriptionManager
        //           return if (permissionUtil.hasReadPhoneStatePermission()) {
        //               subscriptionManager.activeSubscriptionInfoList[slot].subscriptionId
        //           } else {
        //               -1
        //           }
        
    }
    
    
    func pciSubmitHandler(_ dict: [String: Any]) {
        guard let pci = dict["pci"] as? String else {
            UpswingLogger.logDebug("pciSubmitHandler invalid params")
            return
        }
        UpswingLogger.logDebug("pciSubmitHandler: \(pci)")
        ConfigurePciListner.shared.pciListener?.onPciSubmitted(pci: pci)
    }
    
    
    func isPciSubmitHandlerEnabled(_ dict: [String: Any]) {
        executeJsCallback(with: dict){
            return String(ConfigurePciListner.shared.pciListener != nil)
        }
    }
    
    
    func getPartnerUid(_ dict: [String: Any]) {
        executeJsCallback(with: dict){
            let partnerUid = KeychainWrapper.sharedInstance.getPartnerUid()
            return partnerUid
        }
    }
    
    
    //TODO: complete this when we get yes bank sdk for ios
    func getYesBankDeviceToken(_ dict: [String: Any]) {
        
        //           val yesBankRequestDataWrapper = YesBankRequestDataWrapper(
        //               key,
        //               encryptionKey,
        //               simSlot,
        //               partnerReferenceNumber,
        //               mobileNumber,
        //               serviceName
        //           )
        //           fragment.fetchYesBankDeviceToken(yesBankRequestDataWrapper)
    }
    
    
    
    func getFcmToken(_ dict: [String: Any]) {
        executeJsCallback(with: dict){
            let fcmToken = KeychainWrapper.sharedInstance.getFcmToken()
            return fcmToken
        }
    }
    
    
    func logout(_ dict: [String: Any]) {
        KeychainWrapper.sharedInstance.clear()
        existSdk(dict)
    }
    
    
    func setExternalUrls(_ dict: [String: Any]) {
        let urlList = dict["urlList"] as? [String] ?? []
        Constant.WebViewRestrictedUrls.addVideoKycUrls(urls: urlList)
    }
    
    
    //TODO: check for permission Phone state when device available
    func selectSIMCard(_ dict: [String: Any]) {
        //           val smsUtil = SMSUtil(activity, publishEventHandler)
        //           smsUtil.selectSIMCard()
    }
    
    
    //TODO: complete this
    func existSdk(_ dict: [String: Any]) {
        parent.exitSdk()
    }
}

extension WebView.Coordinator {
    
    // This function is used to return back the data to webview
    private func executeJsCallback(with dict: [String: Any], getData: () -> String) {
        guard let callbackFunction = getCallbackFunction(from: dict) else {
            UpswingLogger.logDebug("No callback function provided")
            return
        }
        
        let data = getData()
        parent.publishJsCallbackDataToWebApp(callbackFunction: callbackFunction, data: data)
    }
    
    private func getCallbackFunction(from dict: [String: Any]) -> String? {
        guard let callbackFunction = dict["callbackFunction"] as? String else {
            return nil
        }
        
        return callbackFunction
    }
}

//TODO check this function also for sending sms
//    func sendSms2(_ dict: [String: Any]) {
//        print("sendSms called")
//
//        if let message = dict["message"] as? String,
//           let recipient = dict["recipient"] as? String {
//
//            if MFMessageComposeViewController.canSendText() {
//                MessageView(
//                    isShowingMessageView: $isShowingMessageView,
//                    recipients: recipient,
//                    body: message)
//
//            } else {
//                print("cannot send msg")
//                let alertController = UIAlertController(title: "Error", message: "This device can't send text messages", preferredStyle: .alert)
//                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                if let viewController = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController {
//                    viewController.present(alertController, animated: true, completion: nil)
//                }
//            }
//        } else {
//            print("sendSms invalid param")
//        }
//    }

