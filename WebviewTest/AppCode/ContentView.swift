//
//  ContentView.swift
//  WebviewTest
//
//  Created by Nitin Prakash on 18/03/23.
//

import SwiftUI
import MessageUI

struct ContentView: View {
    let partnerUid = "WEB-TEST-PARTNER-CODE"
    let initiateCustomer = PartnerInitiatCustomer()
    let upswingBuilder = UpswingViewBuilder()
    
    var body: some View {
        
        let upswingView = upswingBuilder
            .setInitiateCustomer(initiateCustomer)
            .setPartnerUid(partnerUid)
            .setDeviceLockedEnabled(true)
            .setPciListener(MyPciListner())
            .build()
        
        NavigationView {
            VStack {
                Text("Sample Partner App")
                    .font(.title2)
                    .padding(10)
                    .foregroundColor(.indigo)
                
                Text("Welcome to Open Finance!")
                    .font(.largeTitle)
                    .foregroundColor(.blue)
                
                NavigationLink(destination: upswingView) {
                    Text("Launch Upswing")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
