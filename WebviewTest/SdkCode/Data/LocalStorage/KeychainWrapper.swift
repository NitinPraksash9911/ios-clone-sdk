//
//  KeychainWrapper.swift
//  WebviewTest
//
//  Created by Nitin Prakash on 25/03/23.
//

import Foundation
import Security
import SwiftUI
import CryptoKit


//https://medium.com/@jakkornat/saving-data-in-ios-keychain-e9ae885abc48

extension KeychainWrapper {
    
    //TODO: Remove these setData and loadData functions
    func loadData(key: String) -> String {
        return loadString(key: key)
    }
    
    //TODO: Remove these setData and loadData functions
    func savedata(key: String, value: String)->Bool{
        return save(key: key, value: value)
    }
    
    func getValueForWebView(key: String) -> String? {
        if RESTRICTED_KEYS.contains(key) {
            return nil
        }
        return loadString(key: key)
    }
    
    func setValueFromWebView(key: String, value: String) {
        if RESTRICTED_KEYS.contains(key) {
            return
        }
        
        let status = save(key: key, value: value)
        UpswingLogger.logDebug("setValueFromWebView status \(status)")
    }
    
    func removeValueFromWebView(key: String) {
        if RESTRICTED_KEYS.contains(key) {
            return
        }
        let status = delete(key: key)
        UpswingLogger.logDebug("removeValueFromWebView status \(status)")
    }
    
    
    func setPrivateKey(pvtKey: Curve25519.Signing.PrivateKey) {
        let status = save(key: StorageConstant.PRIVATE_KEY, value: pvtKey.rawRepresentation.base64EncodedString())
        UpswingLogger.logDebug("setPrivateKey status \(status)")
    }
    
    func getPrivateKey() -> Curve25519.Signing.PrivateKey {
        let keyString = loadString(key: StorageConstant.PRIVATE_KEY)
        UpswingLogger.logDebug("getPrivateKey: \(keyString)")
        guard let data = Data(base64Encoded: keyString) else {
            UpswingLogger.logDebug("Failed to decode private key while getPrivateKey")
            return Curve25519.Signing.PrivateKey()
        }
        do {
            let privateKey = try Curve25519.Signing.PrivateKey(rawRepresentation: data)
            return privateKey
        } catch {
            UpswingLogger.logDebug("Failed to getPrivateKey private key: \(error)")
            return Curve25519.Signing.PrivateKey()
        }
    }
    
    func hasPrivateKey() -> Bool {
        let privateKey = loadString(key: StorageConstant.PRIVATE_KEY)
        return (!privateKey.isEmpty)
    }
    
    func removePrivateKey() {
        let status = delete(key: StorageConstant.PRIVATE_KEY)
        UpswingLogger.logDebug("removePrivateKey status \(status)")
    }
    
    func savePartnerConfigData(
        partnerUid: String,
        statusBarColorRes: String,
        isDeviceLockEnabled: Bool
    ) -> Bool {
        return  save(key: StorageConstant.PARTNER_UID, value: partnerUid) &&
        save(key: StorageConstant.STATUS_BAR_COLOR, value: statusBarColorRes) &&
        save(key :StorageConstant.IS_DEVICE_LOCK_ENABLED, value: isDeviceLockEnabled)
    }
    
    func saveFcmToken(fcmToken: String) {
        let status = save(key: StorageConstant.FCM_TOKEN, value: fcmToken)
        UpswingLogger.logDebug("saveFcmToken status \(status)")
    }
    
    func getFcmToken()-> String{
        return loadString(key: StorageConstant.FCM_TOKEN)
    }
    
    func getPartnerUid()-> String{
        return loadString(key: StorageConstant.PARTNER_UID)
    }
    
    func getStatusBarColor()-> UIColor{
        let statusBarColor = loadString(key: StorageConstant.STATUS_BAR_COLOR)
        let color = UIColor(named: statusBarColor) ?? .black
        return color
    }
    
    func getIsDeviceLockedEnabled()->Bool {
        return loadBool(key: StorageConstant.IS_DEVICE_LOCK_ENABLED)
    }
    
    func clear() {
        deleteAllKeychainData()
    }
    
    func getDeviceId()-> String{
        var deviceID = loadString(key: StorageConstant.DEVICE_ID)
        if(deviceID.isEmpty){
            deviceID = UIDevice.current.identifierForVendor?.uuidString ?? ""
            save(key: StorageConstant.DEVICE_ID, value: deviceID)
        }
        return deviceID
    }
    
}

class KeychainWrapper {
    
    static let sharedInstance = KeychainWrapper()
    
    fileprivate let RESTRICTED_KEYS: [String] = [StorageConstant.PRIVATE_KEY]
    
    private init(){
        if(!isAppAlreadyLaunchedOnce()){
            deleteAllKeychainData()
        }
    }
    
    private lazy var service: String = {
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            return "one.upswing.sdk.service.\(bundleIdentifier)"
        } else {
            return "one.upswing.sdk.service.unknown"
        }
    }()
    
    private func isAppAlreadyLaunchedOnce() -> Bool {
        let defaults = UserDefaults.standard
        
        if defaults.bool(forKey: StorageConstant.IS_SDK_ALREADY_LAUNCHED) {
            UpswingLogger.logDebug("Upswing sdk already launched")
            return true
        } else {
            defaults.set(true, forKey: StorageConstant.IS_SDK_ALREADY_LAUNCHED)
            UpswingLogger.logDebug("Upswing sdk launched first time")
            return false
        }
    }
    
    private func deleteAllKeychainData() {
        //need to keep deviceID and partner uid in Keychain
        let keepDeviceID = getDeviceId()
        let keepPartnerUid = getPartnerUid()
        
        let query = [kSecClass: kSecClassGenericPassword]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess else {
            UpswingLogger.logDebug("Error deleting keychain data: \(status)")
            return
        }
        UpswingLogger.logDebug("Successfully deleted all keychain data")
        
        save(key: StorageConstant.DEVICE_ID, value: keepDeviceID)
        save(key: StorageConstant.PARTNER_UID, value: keepPartnerUid)
    }
    
    fileprivate func save<T: Codable>(key: String, value: T)->Bool {
        return  saveOrUpdate(key: key, value: value)
    }
    
    
    fileprivate  func loadString(key: String)->String {
        return load(key: key, type: String.self) ?? ""
    }
    
    fileprivate func loadInt(key: String)->Int {
        return load(key: key, type: Int.self) ?? -1
    }
    
    fileprivate  func loadBool(key: String)->Bool {
        return load(key: key, type: Bool.self) ?? false
    }
    
    fileprivate func delete(key: String) -> Bool {
        return deleteData(key: key)
    }
    
}

extension KeychainWrapper{
    
    // Save or update the specified value in the keychain
    fileprivate func saveOrUpdate<T: Codable>(key: String, value: T) -> Bool {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(value)
            
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                kSecAttrService as String: service,
                kSecAttrAccount as String: key
            ]
            
            let attributes: [String: Any] = [
                kSecValueData as String: data
            ]
            
            var status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
            
            if status == errSecItemNotFound {
                var queryWithAttributes = query
                queryWithAttributes[kSecValueData as String] = data
                
                status = SecItemAdd(queryWithAttributes as CFDictionary, nil)
            }
            
            return status == errSecSuccess
        } catch {
            UpswingLogger.logDebug("Failed to encode value: \(error)")
            return false
        }
    }
    
    
    fileprivate  func load<T: Codable>(key: String, type: T.Type) -> T? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            kSecAttrAccount as String: key,
            kSecAttrService as String: service,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        guard status == errSecSuccess, let actualData = dataTypeRef as? Data else {
            return nil
        }
        
        do {
            let decodedData = try JSONDecoder().decode(T.self, from: actualData)
            return decodedData
        } catch {
            UpswingLogger.logDebug("Failed to decode data: \(error)")
            return nil
        }
    }
    
    // Delete the specified value from the keychain
    fileprivate func deleteData(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            kSecAttrAccount as String: key,
            kSecAttrService as String: service
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        return status == errSecSuccess
    }
}

//Encryption
extension KeychainWrapper{
    
    //    fileprivate  func encryptData(_ data: Data) -> (status: OSStatus, encryptedData: Data?) {
    //        do {
    //            // Encrypt the input data and return the resulting ciphertext
    //            let ciphertext = try aes!.encrypt(data.bytes)
    //            return (errSecSuccess, Data(ciphertext))
    //        } catch {
    //            // Return an error if the encryption fails
    //            return (errSecInternalError, nil)
    //        }
    //    }
    
    //    fileprivate  func decryptData(_ encryptedData: Data) -> (status: OSStatus, decryptedData: Data?) {
    //        do {
    //
    //            // Decrypt the input ciphertext and return the resulting plaintext data
    //            let decryptedBytes = try aes!.decrypt(encryptedData.bytes)
    //            let decryptedData = Data(decryptedBytes)
    //            return (errSecSuccess, decryptedData)
    //        } catch {
    //            // Return an error if the decryption fails
    //            return (errSecInternalError, nil)
    //        }
    //    }
    //
    //    fileprivate  func getAes(completion: @escaping (AES?) -> Void) {
    //        dispatchQueue.async {
    //            if let aes = self.aes {
    //                // return the cached instance
    //                completion(aes)
    //                return
    //            }
    //
    //            do {
    //                let password: [UInt8] = Array("upswing_ios_sdk_key_chain".utf8)
    //                let salt: [UInt8] = Array("upswing_ios_sdk_key_chain_salt".utf8)
    //                // Generate a key from the password and salt using PBKDF2
    //                let key = try PKCS5.PBKDF2(password: password, salt: salt, iterations: 4096, keyLength: 32/* AES-256 */, variant: .sha2(SHA2.Variant.sha256)).calculate()
    //
    //                // Create an AES instance with the generated key, IV, block mode, and padding
    //                let iv = "7oBzD#fWx@9jGK1E"
    //                let aes = try AES(key: key, blockMode: CBC(iv: iv.bytes), padding: .pkcs7)
    //
    //                self.aes = aes
    //
    //                DispatchQueue.main.async {
    //                    completion(aes)
    //                }
    //            } catch {
    //                print("Error creating AES instance: \(error.localizedDescription)")
    //                DispatchQueue.main.async {
    //                    completion(nil)
    //                }
    //            }
    //        }
    //    }
    
}
