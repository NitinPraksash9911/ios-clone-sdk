//
//  WebViewModel.swift
//  WebviewTest
//
//  Created by Nitin Prakash on 18/03/23.
//

import Foundation
import SwiftUI

internal class WebViewModel: ObservableObject {
    var url: String
    var initiateCustomer : InitiateCustomer
    
    init(url: String, initiateCustomer : InitiateCustomer) {
        self.url = url
        self.initiateCustomer = initiateCustomer
    }
}
