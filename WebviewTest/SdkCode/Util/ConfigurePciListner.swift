//
//  ConfigurePciListner.swift
//  WebviewTest
//
//  Created by Nitin Prakash on 31/03/23.
//

import Foundation

public protocol PciListener {
    func onPciSubmitted(pci: String)
}

class ConfigurePciListner {
    
    static let shared = ConfigurePciListner()
    
    private init(){}
    
    var pciListener: PciListener?
    
    func initialize(pciListener: PciListener) {
        self.pciListener = pciListener
    }
}
