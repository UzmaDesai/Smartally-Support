//
//  AppDelegate.swift
//  Smartally Support
//
//  Created by Muqtadir Ahmed on 19/05/17.
//  Copyright © 2017 Bitjini. All rights reserved.
//

import IQKeyboardManagerSwift
import Kingfisher
import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications
import FirebaseInstanceID

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate,UNUserNotificationCenterDelegate {

    var window: UIWindow?
    // Http Utility Class' instance.
    lazy var http: HTTPUtility = {
        let http = HTTPUtility.shared
        return http
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //Apn registration.
        registerForPushNotifications(application)
        FirebaseApp.configure()
        
        // Add observer for InstanceID token refresh callback.
        NotificationCenter
            .default
            .addObserver(self, selector: #selector(AppDelegate.tokenRefreshNotificaiton),
                         name: NSNotification.Name.InstanceIDTokenRefresh, object: nil)

        // IQKeyboardManager preferences.
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        // Show login screen if app isn't logged in.
        isLoggedIn()
        return true
    }

    
//    // Token Refresh Delegate.
//    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
//        print("fcm token = \(fcmToken)")
//        if UserDefaults.standard.bool(forKey: "isLoggedIn") {
//            Middleware().update(token: fcmToken)
//        }
//    }
    
    // Login flow.
    func isLoggedIn() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        let root = !UserDefaults.standard.bool(forKey: "isLoggedIn") ?
            storyboard.instantiateViewController(withIdentifier: "LoginRegisterViewController") as! LoginRegisterViewController :
            storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        let nav = UINavigationController(rootViewController: root)
        nav.navigationBar.tintColor = .darkGray
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        print(userInfo)
        delegate?.getJobs()
    }
    
    // Firebase register for remote notifications.
//    func registerRemoteNotifications(_ application: UIApplication) {
//        if #available(iOS 10.0, *) {
//            // For iOS 10 display notification (sent via APNS)
//            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
//            Messaging.messaging().delegate = self
//
//            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in })
//        }
//
//        else {
//            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
//            application.registerUserNotificationSettings(settings)
//        }
//
//        application.registerForRemoteNotifications()
//    }
    
    
    func registerForPushNotifications(_ application: UIApplication) {
        
        if #available(iOS 10.0, *) {
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            // For iOS 10 data message (sent via FCM)
            Messaging.messaging().delegate = self
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != UIUserNotificationType() {
            application.registerForRemoteNotifications()
        }
    }
    
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenChars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
        var tokenString = ""
        
        for i in 0..<deviceToken.count {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        InstanceID.instanceID().setAPNSToken(deviceToken, type: InstanceIDAPNSTokenType.unknown)
        
        print("Device Token:", tokenString)
    }
    
    @objc func tokenRefreshNotificaiton(notification: NSNotification) {
        if let refreshedToken = InstanceID.instanceID().token(){
            print("InstanceID token: \(refreshedToken)")
            http.registerDevice(withToken: refreshedToken) //tokenString
            
            // Connect to FCM since connection may have failed when attempted before having a token.
            connectToFcm()
        }
    }
    
    func connectToFcm() {
        
        Messaging.messaging().connect { (error) in
            if (error != nil) {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
        }
    }
    
    @nonobjc func application(received remoteMessage: MessagingRemoteMessage) {
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // Print message ID.
        //        if let messageID = userInfo[gcmMessageIDKey] {
        //            print("Message ID: \(messageID)")
        //        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register:", error)
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Handle push from background or closed" );
        print("%@", response.notification.request.content.userInfo);
    }
    
    
    func applicationWillResignActive(_      application: UIApplication) {}
    func applicationDidEnterBackground(_    application: UIApplication) {}
    func applicationWillEnterForeground(_   application: UIApplication) {}
    func applicationDidBecomeActive(_       application: UIApplication) {}
    func applicationWillTerminate(_         application: UIApplication) {}
}

public extension UINavigationController {
    
}

