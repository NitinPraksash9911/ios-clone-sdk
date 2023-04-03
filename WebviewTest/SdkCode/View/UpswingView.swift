//
//  UpswingView.swift
//  WebviewTest
//
//  Created by Nitin Prakash on 22/03/23.
//

import SwiftUI
import CryptoKit
import Foundation

public struct UpswingView: View {
    
    private let partnerUid: String
    private let initiateCustomer: InitiateCustomer
    private let viewModel: WebViewModel
    private let biometricOrPasscodeAuthenticator: BiometricOrPasscodeAuthenticator
    @Environment(\.dismiss) private var dismiss
    @State private var showWebView = false
    
    init(initiateCustomer: InitiateCustomer) {
        self.biometricOrPasscodeAuthenticator = BiometricOrPasscodeAuthenticator()
        
        self.partnerUid = KeychainWrapper.sharedInstance.getPartnerUid()
        
        self.initiateCustomer = initiateCustomer
        
        print("partnerUID: \(partnerUid)")
        
        viewModel =  WebViewModel(url: "http://127.0.0.1:5500/local.html", initiateCustomer: initiateCustomer)
    }
    
    public var body: some View {
        Group {
            if showWebView {
                VStack {
                    WebView(viewModel: viewModel, dismiss: dismiss)
                }
            } else {
                ProgressView("Authenticating...")
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            authenticate()
        }
    }
    
    private func authenticate() {
        if(KeychainWrapper.sharedInstance.getIsDeviceLockedEnabled()){
        biometricOrPasscodeAuthenticator.authenticate { result in
            switch result {
            case .success:
                // Authentication succeeded. Show the WebView.
                showWebView = true
            case .failure(let error):
                // Authentication failed. Handle the error here.
                self.handleAuthenticationError(error: error)
            }
        }
        }else{
            showWebView = true
        }
    }
    
    private func handleAuthenticationError(error: BiometricOrPasscodeAuthenticator.BiometricOrPasscodeAuthenticatorError) {
        switch error {
        case .unavailable:
            // Biometric or passcode authentication is not available on the device. Show the WebView.
            showWebView = true
        case .authenticationFailed:
            // Authentication failed.
            break
        }
    }
}






internal struct UpswingView_Previews: PreviewProvider {
    static var previews: some View {
        UpswingView(initiateCustomer: MyInitiateCustomer())
    }
}

class MyInitiateCustomer: NSObject, InitiateCustomer {
    
    func initiate(responseCallback: @escaping (CustomerInitiationResponse) -> Void) {
        let response = SuccessCustomerInitiationResponse(internalCustomerId: "PriewICI", guestSessionToken:"PreviewGST")
        
        responseCallback(response)
    }
}
