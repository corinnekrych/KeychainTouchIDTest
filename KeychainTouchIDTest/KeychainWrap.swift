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
    
    
    func createQueryForAddItemWithTouchID(# key: String, value: String? = nil) -> NSMutableDictionary {
        var dataFromString: NSData? = value?.dataUsingEncoding(NSUTF8StringEncoding)
        var error:  Unmanaged<CFError>?
        var sac: Unmanaged<SecAccessControl>
        sac = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
            kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly, .UserPresence, &error)
        let retrievedData = Unmanaged<SecAccessControl>.fromOpaque(sac.toOpaque()).takeUnretainedValue()
        
        var keychainQuery = NSMutableDictionary()
        keychainQuery[kSecClass as String] = kSecClassGenericPassword as AnyObject?
        keychainQuery[kSecAttrService as String] = self.serviceIdentifier
        keychainQuery[kSecAttrAccount as String] = key
        keychainQuery[kSecAttrAccessControl as String] = retrievedData
        keychainQuery[kSecUseNoAuthenticationUI as String] = true
        if let unwrapped = dataFromString {
            keychainQuery[kSecValueData as String] = unwrapped
        }
        return keychainQuery
    }
    
    func createQueryForReadItemWithTouchID(# key: String, value: String? = nil) -> NSMutableDictionary {
        var dataFromString: NSData? = value?.dataUsingEncoding(NSUTF8StringEncoding)
        var keychainQuery = NSMutableDictionary()
        keychainQuery[kSecClass as String] = kSecClassGenericPassword
        keychainQuery[kSecAttrService as String] = self.serviceIdentifier
        keychainQuery[kSecAttrAccount as String] = key
        keychainQuery[kSecUseOperationPrompt as String] = "Do you really want to access the item?"
        keychainQuery[kSecReturnData as String] = true
        
        return keychainQuery
    }
    
    public func addKey(key: String, value: String) -> Int {
        //var statusAdd: OSStatus = SecItemAdd(createQuery(key: key, value: value), nil)
        var statusAdd: OSStatus = SecItemAdd(createQueryForAddItemWithTouchID(key: key, value: value), nil)
        return Int(statusAdd)
    }
    
    public func updateKey(key: String, value: String) -> Int {
        let attributesToUpdate = NSMutableDictionary()
        attributesToUpdate[kSecValueData as String] = value.dataUsingEncoding(NSUTF8StringEncoding)!
        var status: OSStatus = SecItemUpdate(createQuery(key: key, value: value), attributesToUpdate)
        return Int(status)
    }
    
    public func readKey(key: String) -> NSString? {
        
        var dataTypeRef: Unmanaged<AnyObject>?
        //let status: OSStatus = SecItemCopyMatching(createQuery(key: key), &dataTypeRef)
        let status: OSStatus = SecItemCopyMatching(createQueryForReadItemWithTouchID(key: key), &dataTypeRef)
        
        var contentsOfKeychain: NSString?
        if (status != errSecSuccess) {
            contentsOfKeychain = "\(Int(status))"
            return contentsOfKeychain
        }
        
        let opaque = dataTypeRef?.toOpaque()
        if let op = opaque {
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
        keychainQuery[kSecClass as String] = secClass
        
        let result:OSStatus = SecItemDelete(keychainQuery)
        if (result == errSecSuccess || result == errSecItemNotFound) {
            return true
        } else {
            return false
        }
    }
}
