//
//  KeychainTestsViewController.swift
//  KeychainTouchIDTest
//
//  Created by Corinne Krych on 12/09/14.
//  Copyright (c) 2014 corinnekrych. All rights reserved.
//

import Foundation
import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class Test: NSObject {
    var name: String?
    var details: String?
    init(name:String, details:String) {
        self.name = name
        self.details = details
    }
}

class KeychainTestsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var tests: [Test]?
    var keychain: KeychainWrap?
    
    override func viewDidLoad() {
        self.tests = [Test(name: "Add item", details: "Using SecItemAdd()"),
            Test(name: "Query item", details: "Using SecItemCopyMatching()"),
            Test(name: "Update item", details: "Using SecItemUpdate()"),
            Test(name: "Reset all", details: "Using SecItemDelete()")]
        self.keychain = KeychainWrap()
    }
    
    // MARK - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tests?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "TestCell"
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier:cellIdentifier)
        
        let test:Test? = self.testForIndexPath(indexPath)
        cell.textLabel?.text = test?.name;
        cell.detailTextLabel?.text = test?.details;
        
        return cell;
    }
    
    func testForIndexPath(_ indexPath: IndexPath) -> Test? {
        if ((indexPath as NSIndexPath).section > 0 || (indexPath as NSIndexPath).row >= self.tests?.count) {
            return nil;
        }
        return self.tests?[(indexPath as NSIndexPath).row] ?? nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let testSelected:Test? = self.testForIndexPath(indexPath)
        if let unwrappedTest = testSelected {
            if unwrappedTest.name == "Add item" {
                let result = keychain!.addKey("key1", value: "value1")
                let message = keychainErrorToString(result)
                UIAlertView(title: "Add item", message: message, delegate: self, cancelButtonTitle: "Cancel").show()
            } else if unwrappedTest.name == "Query item" {
                let result: String = keychain!.readKey("key1") as String
                var message = "Error reading"
                if result == "value1" {
                    message = "Success: \(result) found"
                } else {
                    message = "Error: \(result)"
                }
                UIAlertView(title: "Query item", message: message, delegate: self, cancelButtonTitle: "Cancel").show()
            } else if unwrappedTest.name == "Update item" {
                let result = keychain!.updateKey("key1", value: "value1")
                let message = keychainErrorToString(result)
                UIAlertView(title: "Update item", message: message, delegate: self, cancelButtonTitle: "Cancel").show()
            } else if unwrappedTest.name == "Reset all" {
                let result = keychain!.resetKeychain()
                var message = ""
                if result {
                    message = "All keychain items deleted for this app"
                } else {
                    message = "Error while resetting"
                }
                UIAlertView(title: "Delete item", message: message, delegate: self, cancelButtonTitle: "Cancel").show()
            }
        }
    }
    
    func keychainErrorToString(_ error: Int) -> String {
        
        var msg: String?
        switch(error) {
        case Int(errSecSuccess): msg = "Success"
        case Int(errSecDuplicateItem): msg = "Duplicate item, please delete first"
        case Int(errSecItemNotFound): msg = "Item not found"
        case -26276: msg = "Item authenticationFailed"
        case Int(errSecAuthFailed): msg = "Auth failed"
        default: msg = "Error: \(error)"
        }
        
        return msg!
    }
}
