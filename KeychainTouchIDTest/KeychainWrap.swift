//
//  KeychainWrap.swift
//  KeychainTouchIDTest
//
//  Created by Corinne Krych on 12/09/14.
//  Copyright (c) 2014 corinnekrych. All rights reserved.
//

import Foundation

public class KeychainWrap {
    public var serviceIdentifier: String
    
    public init() {
        if let bundle = NSBundle.mainBundle().bundleIdentifier {
            self.serviceIdentifier = bundle
        } else {
            self.serviceIdentifier = "unkown"
        }
    }
    
    func createQuery(# key: String, value: String? = nil) -> NSMutableDictionary {
        var dataFromString: NSData? = value?.dataUsingEncoding(NSUTF8StringEncoding)
        var keychainQuery = NSMutableDictionary()
        keychainQuery[kSecClass] = kSecClassGenericPassword
        keychainQuery[kSecAttrService] = self.serviceIdentifier
        keychainQuery[kSecAttrAccount] = key
        keychainQuery[kSecAttrAccessible] = kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
        if let unwrapped = dataFromString {
            keychainQuery[kSecValueData] = unwrapped
        } else {
            keychainQuery[kSecReturnData] = true
        }
        return keychainQuery
    }
    
    public func addKey(key: String, value: String) -> Int {
        var statusAdd: OSStatus = SecItemAdd(createQuery(key: key, value: value), nil)
        return Int(statusAdd)
    }
    
    public func updateKey(key: String, value: String) -> Int {
        let attributesToUpdate = NSMutableDictionary()
        attributesToUpdate[kSecValueData] = value.dataUsingEncoding(NSUTF8StringEncoding)!
        var status: OSStatus = SecItemUpdate(createQuery(key: key, value: value), attributesToUpdate)
        return Int(status)
    }
    
    public func readKey(key: String) -> NSString? {
        
        var dataTypeRef: Unmanaged<AnyObject>?
        let status: OSStatus = SecItemCopyMatching(createQuery(key: key), &dataTypeRef)
        
        var contentsOfKeychain: NSString?
        if (Int(status) != errSecSuccess) {
            contentsOfKeychain = "\(Int(status))"
            return contentsOfKeychain
        }
        
        let opaque = dataTypeRef?.toOpaque()
        if let op = opaque? {
            let retrievedData = Unmanaged<NSData>.fromOpaque(op).takeUnretainedValue()
            // Convert the data retrieved from the keychain into a string
            contentsOfKeychain = NSString(data: retrievedData, encoding: NSUTF8StringEncoding)
        } else {
            println("Nothing was retrieved from the keychain. Status code \(status)")
        }
        
        return contentsOfKeychain
    }
    
    // when uninstalling app you may wish to clear keyclain app info
    public func resetKeychain() -> Bool {
        return self.deleteAllKeysForSecClass(kSecClassGenericPassword) &&
            self.deleteAllKeysForSecClass(kSecClassInternetPassword) &&
            self.deleteAllKeysForSecClass(kSecClassCertificate) &&
            self.deleteAllKeysForSecClass(kSecClassKey) &&
            self.deleteAllKeysForSecClass(kSecClassIdentity)
    }
    
    func deleteAllKeysForSecClass(secClass: CFTypeRef) -> Bool {
        var keychainQuery = NSMutableDictionary()
        keychainQuery[kSecClass] = secClass
        
        let result:OSStatus = SecItemDelete(keychainQuery)
        if (Int(result) == errSecSuccess || Int(result) == errSecItemNotFound) {
            return true
        } else {
            return false
        }
    }
}
