//
//  BiometricOrPasscodeAuthenticator.swift
//  WebviewTest
//
//  Created by Nitin Prakash on 01/04/23.
//

import LocalAuthentication

class BiometricOrPasscodeAuthenticator{
    
    typealias AuthenticationCompletionHandler = (Result<Void, BiometricOrPasscodeAuthenticatorError>) -> Void
    
    private let context = LAContext()
    
    func authenticate(completionHandler: @escaping AuthenticationCompletionHandler) {
        if canEvaluateBiometrics() {
            
            self.authenticateUsingBoimetric(completionHandler: completionHandler)
            
        } else if canEvaluatePasscode() {
            
            self.authenticateUsingPasscode(completionHandler: completionHandler)
            
        } else {
            completionHandler(.failure(.unavailable))
        }
    }
    
    
    private func authenticateUsingBoimetric(completionHandler: @escaping AuthenticationCompletionHandler){
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Authenticate using Touch ID or Face ID") {  success, error in
            if success {
                completionHandler(.success(()))
            } else {
                completionHandler(.failure(.authenticationFailed))
            }
        }
    }
    
    private func authenticateUsingPasscode(completionHandler: @escaping AuthenticationCompletionHandler) {
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Authenticate using device passcode") { success, error in
            if success {
                completionHandler(.success(()))
            } else {
                completionHandler(.failure(.authenticationFailed))
            }
        }
    }
    
    private func canEvaluatePasscode() -> Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
    }
    
    private func canEvaluateBiometrics() -> Bool {
        var error: NSError?
        
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) && error == nil
    }
    
    
    enum BiometricOrPasscodeAuthenticatorError: Error {
        case unavailable
        case authenticationFailed
    }
}
