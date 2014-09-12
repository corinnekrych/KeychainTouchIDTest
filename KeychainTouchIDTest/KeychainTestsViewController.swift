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
    
    override func viewDidLoad() {
        self.tests = [Test(name: "Add item", details: "Using SecItemAdd()"),
            Test(name: "Query item", details: "Using SecItemCopyMatching()"),
            Test(name: "Update item", details: "Using SecItemUpdate()"),
            Test(name: "Delete item", details: "Using SecItemDelete()")]
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
                UIAlertView(title: "Add item", message: "", delegate: self, cancelButtonTitle: "Cancel").show()
            } else if unwrappedTest.name == "Query item" {
                UIAlertView(title: "Query item", message: "", delegate: self, cancelButtonTitle: "Cancel").show()
            } else if unwrappedTest.name == "Update item" {
                UIAlertView(title: "Update item", message: "", delegate: self, cancelButtonTitle: "Cancel").show()
            } else if unwrappedTest.name == "Add item" {
                UIAlertView(title: "Delete item", message: "", delegate: self, cancelButtonTitle: "Cancel").show()
            }
        }
    }
    
}
