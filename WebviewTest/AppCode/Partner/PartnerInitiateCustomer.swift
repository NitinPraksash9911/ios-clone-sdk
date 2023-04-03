//
//  PartnerInitiateCustomer.swift
//  WebviewTest
//
//  Created by Nitin Prakash on 30/03/23.
//

import Foundation


class PartnerInitiatCustomer : InitiateCustomer {
    
    func initiate(responseCallback: @escaping (CustomerInitiationResponse) -> Void) {
        var pci = PciHolder.shared.pci
        
        if pci == nil {
            print("pci is nil, assigning default value")
            pci = "webtest-default-pci-1212"
        }
        
        print("PartnerInitiatCustomer pci: \(pci ?? "null")")
        
        let response = SuccessCustomerInitiationResponse(internalCustomerId: "WEBTest-ICI12345-AMCE", guestSessionToken:"WEBTest-GST1234-ACME")
        
        responseCallback(response)
    }
}
