//
//  KeychainTestsViewController.swift
//  KeychainTouchIDTest
//
//  Created by Corinne Krych on 12/09/14.
//  Copyright (c) 2014 corinnekrych. All rights reserved.
//

import Foundation
import UIKit

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
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tests?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cellIdentifier = "TestCell"
        
        var cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as UITableViewCell
        cell = UITableViewCell(style: .Subtitle, reuseIdentifier:cellIdentifier)
        
        
        var test:Test? = self.testForIndexPath(indexPath)
        cell.textLabel?.text = test?.name;
        cell.detailTextLabel?.text = test?.details;
        
        return cell;
    }
    
    func testForIndexPath(indexPath: NSIndexPath) -> Test? {
        if (indexPath.section > 0 || indexPath.row >= self.tests?.count) {
            return nil;
        }
        return self.tests?[indexPath.row] ?? nil
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let testSelected:Test? = self.testForIndexPath(indexPath)
        if let unwrappedTest = testSelected {
            if unwrappedTest.name == "Add item" {
                let result = keychain!.addKey("key1", value: "value1")
                let message = keychainErrorToString(result)
                UIAlertView(title: "Add item", message: message, delegate: self, cancelButtonTitle: "Cancel").show()
            } else if unwrappedTest.name == "Query item" {
                let result: String = keychain!.readKey("key1")!
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
    
    func keychainErrorToString(error: Int) -> String {
        
        var msg: String?
        switch(error) {
        case errSecSuccess: msg = "Success"
        case errSecDuplicateItem: msg = "Duplicate item, please delete first"
        case errSecItemNotFound: msg = "Item not found"
        case -26276: msg = "Item authenticationFailed"
        case errSecAuthFailed: msg = "Auth failed"
        default: msg = "Error: \(error)"
        }
        
        return msg!
    }
}
