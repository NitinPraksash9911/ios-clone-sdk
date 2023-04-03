//
//  CustomerInitiationResponse.swift
//  WebviewTest
//
//  Created by Nitin Prakash on 30/03/23.
//
import Foundation

@objcMembers
public class CustomerInitiationResponse: NSObject {}

@objcMembers
public class SuccessCustomerInitiationResponse: CustomerInitiationResponse {
    let internalCustomerId: String
    let guestSessionToken: String
    
   public init(internalCustomerId: String, guestSessionToken: String) {
        self.internalCustomerId = internalCustomerId
        self.guestSessionToken = guestSessionToken
        super.init()
    }
}

@objcMembers
public class FailureCustomerInitiationResponse: CustomerInitiationResponse {}


@objc public protocol InitiateCustomer {
    func initiate(responseCallback: @escaping (CustomerInitiationResponse) -> Void)
}
