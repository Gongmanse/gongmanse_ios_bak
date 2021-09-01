//
//  SceneDelegate.swift
//  gongmanse
//
//  Created by 김현수 on 2021/03/04.
//

import UIKit
import FBSDKCoreKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        setRootViewController(scene)
//        guard let windows = (scene as? UIWindowScene) else { return }
//        window = UIWindow(windowScene: windows)
//
//        window?.rootViewController = LecturePlaylistVC("1766")
//
//        window?.makeKeyAndVisible()
        
        
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        NotificationCenter.default.post(name: Notification.Name("become_active"), object: nil, userInfo: nil)
    }

    func sceneWillResignActive(_ scene: UIScene) {
        NotificationCenter.default.post(name: Notification.Name("resign_active"), object: nil, userInfo: nil)
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }

        ApplicationDelegate.shared.application(
            UIApplication.shared,
            open: url,
            sourceApplication: nil,
            annotation: [UIApplication.OpenURLOptionsKey.annotation]
        )
    }
}

extension SceneDelegate {
    private func setRootViewController(_ scene: UIScene) {
        if Storage.isFirstTime() {
            setRootViewController(scene, name: "Onboarding", identifier: "OnboardingViewController")
        } else {
            setRootViewController(scene, name: "Main", identifier: "MainTabBarController")
        }
    }
    
    private func setRootViewController(_ scene: UIScene, name: String, identifier: String) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            let storyboard = UIStoryboard(name: name, bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: identifier)
            window.rootViewController = viewController
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}
