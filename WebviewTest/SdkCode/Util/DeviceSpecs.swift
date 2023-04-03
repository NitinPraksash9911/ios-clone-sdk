//
//  DeviceSpecs.swift
//  WebviewTest
//
//  Created by Nitin Prakash on 29/03/23.
//

import UIKit

class DeviceSpecs {
    static func getDeviceSpecs() -> [String: String] {
        var deviceSpecs: [String: String] = [:]
        
        deviceSpecs["Device Model"] = UIDevice.current.model
        deviceSpecs["Device Name"] = UIDevice.current.name
        deviceSpecs["System Name"] = UIDevice.current.systemName
        deviceSpecs["System Version"] = UIDevice.current.systemVersion
        deviceSpecs["Version"] = String(ProcessInfo.processInfo.operatingSystemVersion.majorVersion)
        deviceSpecs["Version Release"] = ProcessInfo.processInfo.operatingSystemVersionString
        
        return deviceSpecs
    }
    
    static func getDeviceSpecsAsJSON() -> String {
        let deviceSpecs = getDeviceSpecs()
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        do {
            let jsonData = try jsonEncoder.encode(deviceSpecs)
            guard let jsonString = String(data: jsonData, encoding: .utf8) else { return "{}" }
            return jsonString
        } catch {
            print("Error converting device specs to JSON: \(error.localizedDescription)")
            return "{}"
        }
    }
}



