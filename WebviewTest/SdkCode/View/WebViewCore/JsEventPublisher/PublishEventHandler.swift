//
//  PublishEventHandler.swift
//  WebviewTest
//
//  Created by Nitin Prakash on 24/03/23.
//

import Foundation

extension WebView {
    
    func publishEventToLoadURL(url: String) {
        let payload = ["url": url]
        if let jsonString = encodeToJsonString(payload: payload) {
            publishJsEvent(queueEventType: QueueEventType.LOAD_URL, payload: jsonString)
        }
    }
    
    func publishEventWhenPersistentLoaded(payload: String) {
        publishJsEvent(queueEventType: QueueEventType.PERSISTENT_STORAGE_FILE_LOADED, payload: payload)
    }
    
    
    func publishSDKEventForSimSubscription(
        payload: String
    ) {
        publishJsEvent(queueEventType: QueueEventType.SIM_SUBSCRIPTION_ID_CHOSEN, payload: payload)
    }
    
    func publishFragmentResumedEvent(payload: String) {
        publishJsEvent(queueEventType: QueueEventType.FRAGMENT_RESUMED, payload: payload)
    }
    
    func publishEventForCustomerInitSet(payload: String) {
        publishJsEvent(queueEventType: QueueEventType.CUSTOMER_INITIALIZER_SET, payload: payload)
    }
    
    func publishEventForFetchIciFailed(payload: String) {
        publishJsEvent(queueEventType: QueueEventType.PCI_FETCH_FAILED, payload: payload)
    }
    
    func publishEventForPublicKeyCreated( publicKeyEncoded: String,
                                          guestSessionTokenEncoded: String,
                                          guestSessionToken: String,
                                          internalCustomerId: String) {
        
        let payload = [
            "publicKeyEncoded": publicKeyEncoded,
            "guestSessionTokenEncoded": guestSessionTokenEncoded,
            "guestSessionToken": guestSessionToken,
            "internalCustomerId": internalCustomerId
        ]
        
        if let jsonString = encodeToJsonString(payload: payload) {
            publishJsEvent(queueEventType: QueueEventType.PUBLIC_KEY_CREATED, payload: jsonString)
        }
        
    }
    
    func publishEventForDeviceBackBtnPressed(payload: String) {
        publishJsEvent(queueEventType: QueueEventType.DEVICE_BACK_BUTTON_PRESSED, payload: payload)
    }
    
    
    func publishEventForSuccessSendSMS(msg: String) {
        let payload = ["status": msg]
        if let jsonString = encodeToJsonString(payload: payload) {
            publishJsEvent(queueEventType: .SEND_SMS_SUCCESS, payload: jsonString)
        }
    }
    
    func publishEventForFailureSendSMS(errorMsg: String) {
        let payload = ["status": errorMsg]
        if let jsonString = encodeToJsonString(payload: payload) {
            publishJsEvent(queueEventType: .SEND_SMS_FAILED, payload: jsonString)
        }
    }
    
    
    
    //        func publishEventForPermissionStatus(permissionStatus: PermissionStatus) {
    //            iPublishEventToWebView.publishEvent(
    //                QueueEventType.PERMISSION_REQUEST_RESULT,
    //                gson.toJson(permissionStatus.name)
    //            )
    //        }
    
    
    
    //        fun publishEventYesBankTokenOnSuccess(
    //            successResponse: YesBankDeviceTokenResponse,
    //            isBindingHappen: Boolean
    //        ) {
    //            val payload = getPayloadForYesBank(
    //                "SUCCESS",
    //                successResponse.statusCode,
    //                successResponse.result,
    //                successResponse.deviceToken,
    //                successResponse.yppReferenceNumber,
    //                isBindingHappen
    //            )
    //            iPublishEventToWebView.publishEvent(
    //                QueueEventType.YES_BANK_TOKEN_RECEIVED,
    //                payload
    //            )
    //        }
    
    //        fun publishEventYesBankTokenOnFailure(errorResponse: YesBankErrorResponse) {
    //            val payload = getPayloadForYesBank(
    //                "ERROR",
    //                errorResponse.statusCode,
    //                errorResponse.errorMsg,
    //                null,
    //                null,
    //                false
    //            )
    //            iPublishEventToWebView.publishEvent(
    //                QueueEventType.YES_BANK_TOKEN_GENERATION_FAILED,
    //                payload
    //            )
    //        }
    
    //        private fun getPayloadForYesBank(
    //            status: String, statusCode: String,
    //            msg: String, deviceToken: String?,
    //            yppRefNum: String?, isBindingComplete: Boolean
    //        ): String {
    //            val jsResponseYesBankDeviceToken = JsResponseYesBankDeviceToken(
    //                statusCode = statusCode,
    //                status = status,
    //                msg = msg,
    //                deviceToken = deviceToken,
    //                yppReferenceNumber = yppRefNum,
    //                isBindingComplete = isBindingComplete
    //            )
    //            return gson.toJson(jsResponseYesBankDeviceToken)
    //        }
    
    
    
    private func encodeToJsonString<T: Encodable>(payload: [String: T]) -> String? {
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(payload)
            return String(data: jsonData, encoding: .utf8)
        } catch {
            UpswingLogger.logDebug("encodeToJsonString error: \(error.localizedDescription)")
            return nil
        }
    }
}
