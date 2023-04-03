//
//  SdkInfo.swift
//  WebviewTest
//
//  Created by Nitin Prakash on 30/03/23.
//
import Foundation

struct SdkInfo {
    
    var sdkName : String {
        return readFromInfoPlist(withKey: "CFBundleName") ?? "(unknown app name)"
    }
    
    var version : String {
        return readFromInfoPlist(withKey: "CFBundleShortVersionString") ?? "(unknown app version)"
    }
    
    var build : String {
        return readFromInfoPlist(withKey: "CFBundleVersion") ?? "(unknown build number)"
    }
    
    var minimumOSVersion : String {
        return readFromInfoPlist(withKey: "MinimumOSVersion") ?? "(unknown minimum OSVersion)"
    }
    
    var copyrightNotice : String {
        return readFromInfoPlist(withKey: "NSHumanReadableCopyright") ?? "(unknown copyright notice)"
    }
    
    var bundleIdentifier : String {
        return readFromInfoPlist(withKey: "CFBundleIdentifier") ?? "(unknown bundle identifier)"
    }
    
    var developer : String { return "Upswing Team" }
    
    // lets hold a reference to the Info.plist of the framework as Dictionary
    private let infoPlistDictionary = Bundle(identifier: "Upswing.WebviewTest")?.infoDictionary
    
    /// Retrieves and returns associated values (of Type String) from info.Plist of the framework.
    private func readFromInfoPlist(withKey key: String) -> String? {
        return infoPlistDictionary?[key] as? String
    }
}
