//
//  UpswingSdk.swift
//  WebviewTest
//
//  Created by Nitin Prakash on 31/03/23.
//

import Foundation
import SwiftUI

public class UpswingViewBuilder {
    
    public init(){}
    
    private var partnerUid: String?
    private var initiateCustomer: InitiateCustomer?
    private var pciListener: PciListener?
    private var isDeviceLockEnabled: Bool = false
    
    public func setPartnerUid(_ partnerUid: String) -> Self {
        self.partnerUid = partnerUid
        return self
    }
    
    public func setInitiateCustomer(_ initiateCustomer: InitiateCustomer) -> Self {
        self.initiateCustomer = initiateCustomer
        return self
    }
    
    public func setDeviceLockedEnabled(_ isDeviceLockEnabled: Bool) -> Self {
        self.isDeviceLockEnabled = isDeviceLockEnabled
        return self
    }
    
    public func setPciListener(_ pciListener: PciListener?) -> Self {
        self.pciListener = pciListener
        return self
    }
    
    public func build() -> some View {
        guard let partnerUid = partnerUid,
              !partnerUid.trimmingCharacters(in: .whitespaces).isEmpty else {
            let error = "Unable to create Upswing view: missing or empty PartnerUid"
            return AnyView(throwErrorView(error: error))
        }
        
        guard let initiateCustomer = initiateCustomer else {
            let error = "Unable to create Upswing view: missing InitiateCustomer"
            return AnyView(throwErrorView(error: error))
        }
        
        ConfigurePciListner.shared.pciListener = pciListener
        savePartneConfigrDataToKeychain(partnerUid, "#000000", isDeviceLockEnabled)
        
        let upswingView = UpswingView(initiateCustomer: initiateCustomer)
        return AnyView(upswingView)
    }
    
    private func throwErrorView(error: String) -> some View {
        VStack {
            Text("Error: \(error)")
                .foregroundColor(.red)
                .font(.headline)
                .padding()
        }
    }

    private func savePartneConfigrDataToKeychain(_ partnerUid:String, _ statusBarColorRes:String, _ isDeviceLockEnabled:Bool){
        KeychainWrapper.sharedInstance.savePartnerConfigData(partnerUid: partnerUid, statusBarColorRes: "#000000" , isDeviceLockEnabled: isDeviceLockEnabled)
    }
    
}

