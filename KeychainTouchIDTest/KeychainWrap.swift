//
//  KeychainWrap.swift
//  KeychainTouchIDTest
//
//  Created by Corinne Krych on 12/09/14.
//  Copyright (c) 2014 corinnekrych. All rights reserved.
//

import Foundation

open class KeychainWrap {
    open var serviceIdentifier: String
    
    public init() {
        if let bundle = Bundle.main.bundleIdentifier {
            self.serviceIdentifier = bundle
        } else {
            self.serviceIdentifier = "unkown"
        }
    }
    
    func createQuery(key: String, _ value: String? = nil) -> NSMutableDictionary {
        let dataFromString: Data? = value?.data(using: String.Encoding.utf8)
        let keychainQuery = NSMutableDictionary()
        keychainQuery[kSecClass as String] = kSecClassGenericPassword as AnyObject?
        keychainQuery[kSecAttrService as String] = self.serviceIdentifier
        keychainQuery[kSecAttrAccount as String] = key
        keychainQuery[kSecAttrAccessible as String] = kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
        if let unwrapped = dataFromString {
            keychainQuery[kSecValueData as String] = unwrapped
        } else {
            keychainQuery[kSecReturnData as String] = true
        }
        return keychainQuery
    }
    
    
    func createQueryForAddItemWithTouchID(key: String, _ value: String? = nil) -> NSMutableDictionary {
        let dataFromString: Data? = value?.data(using: String.Encoding.utf8)
        var error:  Unmanaged<CFError>?
        var sac: SecAccessControl?
        sac = SecAccessControlCreateWithFlags(kCFAllocatorDefault, kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly, .userPresence, &error)

        let keychainQuery = NSMutableDictionary()
        keychainQuery[kSecClass as String] = kSecClassGenericPassword as AnyObject?
        keychainQuery[kSecAttrService as String] = self.serviceIdentifier
        keychainQuery[kSecAttrAccount as String] = key
        keychainQuery[kSecAttrAccessControl as String] = sac
        keychainQuery[kSecUseNoAuthenticationUI as String] = true
        if let unwrapped = dataFromString {
            keychainQuery[kSecValueData as String] = unwrapped
        }
        return keychainQuery
    }
    
    func createQueryForReadItemWithTouchID(key: String, _ value: String? = nil) -> NSMutableDictionary {
        let dataFromString: Data? = value?.data(using: String.Encoding.utf8)
        let keychainQuery = NSMutableDictionary()
        keychainQuery[kSecClass as String] = kSecClassGenericPassword
        keychainQuery[kSecAttrService as String] = self.serviceIdentifier
        keychainQuery[kSecAttrAccount as String] = key
        keychainQuery[kSecUseOperationPrompt as String] = "Do you really want to access the item?"
        keychainQuery[kSecReturnData as String] = true
        
        return keychainQuery
    }
    
    open func addKey(_ key: String, value: String) -> Int {
        //var statusAdd: OSStatus = SecItemAdd(createQuery(key: key, value: value), nil)
        let statusAdd: OSStatus = SecItemAdd(createQueryForAddItemWithTouchID(key: key, value), nil)
        return Int(statusAdd)
    }
    
    open func updateKey(_ key: String, value: String) -> Int {
        let attributesToUpdate = NSMutableDictionary()
        attributesToUpdate[kSecValueData as String] = value.data(using: String.Encoding.utf8)!
        let status: OSStatus = SecItemUpdate(createQuery(key: key, value), attributesToUpdate)
        return Int(status)
    }
    
    open func readKey(_ key: String) -> String {
        
        var result: AnyObject?
        //let status: OSStatus = SecItemCopyMatching(createQuery(key: key), &dataTypeRef)
        let status: OSStatus = SecItemCopyMatching(createQueryForReadItemWithTouchID(key: key), &result)
        
        var contentsOfKeychain: String?
        
        guard status == noErr else {
            contentsOfKeychain = "\(Int(status))"
            return contentsOfKeychain ?? ""
        }
        
        if let data = result as? Data {
            // Convert the data retrieved from the keychain into a string
            contentsOfKeychain = String(data: data, encoding: String.Encoding.utf8)
        } else {
            print("Nothing was retrieved from the keychain. Status code \(status)")
        }
        
        return contentsOfKeychain ?? ""
    }
    
    // when uninstalling app you may wish to clear keyclain app info
    open func resetKeychain() -> Bool {
        return self.deleteAllKeysForSecClass(kSecClassGenericPassword) &&
            self.deleteAllKeysForSecClass(kSecClassInternetPassword) &&
            self.deleteAllKeysForSecClass(kSecClassCertificate) &&
            self.deleteAllKeysForSecClass(kSecClassKey) &&
            self.deleteAllKeysForSecClass(kSecClassIdentity)
    }
    
    func deleteAllKeysForSecClass(_ secClass: CFTypeRef) -> Bool {
        let keychainQuery = NSMutableDictionary()
        keychainQuery[kSecClass as String] = secClass
        
        let result:OSStatus = SecItemDelete(keychainQuery)
        if (result == errSecSuccess || result == errSecItemNotFound) {
            return true
        } else {
            return false
        }
    }
}
