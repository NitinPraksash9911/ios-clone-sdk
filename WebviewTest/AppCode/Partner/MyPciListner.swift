//
//  MyPciListner.swift
//  WebviewTest
//
//  Created by Nitin Prakash on 31/03/23.
//

import Foundation


class MyPciListner : PciListener {
    
    func onPciSubmitted(pci: String) {
        PciHolder.shared.pci = pci
    }
    
}

class PciHolder {
    static let shared = PciHolder()
    var pci: String?
    
    private init() {}
}
