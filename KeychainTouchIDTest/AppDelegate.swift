//
//  AppDelegate.swift
//  KeychainTouchIDTest
//
//  Created by Corinne Krych on 12/09/14.
//  Copyright (c) 2014 corinnekrych. All rights reserved.
//

import UIKit
import LocalAuthentication

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func promptTouchID() {
        var myContext = LAContext()
        var authError: NSError? = nil
        var myLocalizedReasonString:String = "Authenticate using your finger"
        if (myContext.canEvaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics, error:&authError)) {
            
            myContext.evaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics,
                localizedReason: myLocalizedReasonString,
                reply: {(success: Bool, error: NSError!)->() in
                    
                    if (success) {
                        println("User authenticated")
                    } else {
                        switch (error.code) {
                        case LAError.AuthenticationFailed.rawValue:
                            println("Authentication Failed")
                            
                        case LAError.UserCancel.rawValue:
                            println("User pressed Cancel button")
                            
                        case LAError.UserFallback.rawValue:
                            println("User pressed \"Enter Password\"")
                            
                        default:
                            
                            println("Touch ID is not configured")
                        }
                        
                        println("Authentication Fails");
                        let alert = UIAlertView(title: "Error", message: "Auth fails!", delegate: nil, cancelButtonTitle:"OK")
                        alert.show()
                    }
            })
        } else {
            println("Can not evaluate Touch ID");
            let alert = UIAlertView(title: "Error", message: "Your passcode should be set!", delegate: nil, cancelButtonTitle:"OK")
            alert.show()
        }
        
        
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        promptTouchID()
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        promptTouchID()
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        
        
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

