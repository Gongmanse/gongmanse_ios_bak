//
//  AppDelegate.swift
//  gongmanse
//
//  Created by 김현수 on 2021/03/04.
//

import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications
import FBSDKCoreKit
import KakaoSDKCommon

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //설정 디폴트 값
        UserDefaults.standard.register(defaults: ["subtitle" : true,
                                                  "mobileData" : true,
                                                  "push" : true,
                                                  "specialist" : true,
                                                  "inquiry" : true,
                                                  "schedule" : true,
                                                  "notice" : true])
        
        Thread.sleep(forTimeInterval: 2.0)
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in })
        application.registerForRemoteNotifications()
        
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        KakaoSDKCommon.initSDK(appKey: "66773aa669c7d7d858ebebf335f1dc80")
        
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.shadowColor = UIColor.lightGray
            appearance.backgroundColor = .white
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            UINavigationBar.appearance().standardAppearance = appearance
            
            UITableView.appearance().sectionHeaderTopPadding = 0.0
        }
        
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return ApplicationDelegate.shared.application(
                app,
                open: url,
                sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                annotation: options[UIApplication.OpenURLOptionsKey.annotation]
            )

    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        NotificationCenter.default.post(name: Notification.Name("resign_active"), object: nil, userInfo: nil)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        NotificationCenter.default.post(name: Notification.Name("become_active"), object: nil, userInfo: nil)
    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        
        Constant.refreshToken = UserDefaults.standard.string(forKey: "refreshToken") ?? ""
        
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    var orientationLock = UIInterfaceOrientationMask.portrait

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    struct AppUtility {
        static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                delegate.orientationLock = orientation
            }
        }

        static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
            self.lockOrientation(orientation)
            UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        }
        
        
    }
}


extension UIApplication {
    
    func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("\(#function)")
        
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(fcmToken)")
        let dataDict:[String: String] = ["token": fcmToken!]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        
        UserDefaults.standard.setValue(fcmToken, forKey: "fcm_token")
    }
}
