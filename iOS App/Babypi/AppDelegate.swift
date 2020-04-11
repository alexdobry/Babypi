//
//  AppDelegate.swift
//  Babypi
//
//  Created by Alex on 24.12.17.
//  Copyright © 2017 Alexander Dobrynin. All rights reserved.
//

import UIKit
import UserNotifications

final class App {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let navigationController: UINavigationController
    
    init(window: UIWindow) {
        navigationController = window.rootViewController as! UINavigationController
        
        let mainVC = navigationController.viewControllers.first as! BabypiTableViewController
        mainVC.viewModel = WebbasedBabypiViewModel(baseUrl: URLs.Webservice)
        mainVC.didTapSettings = showSettings
    }
    
    func showSettings() {
        let settingsVC = storyboard.instantiateViewController(withIdentifier: "Settings") as! SettingsTableViewController
        let settingsNC = UINavigationController(rootViewController: settingsVC)
        settingsVC.didTapDone = {
            self.navigationController.dismiss(animated: true, completion: nil)
        }
        navigationController.present(settingsNC, animated: true, completion: nil)
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var app: App?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        app = App(window: window!)
        
        if UserDefaults.standard.token == nil {
            resigerForNotifications { granted in
                guard granted else { return }
                application.registerForRemoteNotifications()
            }
        }
        
        window?.tintColor = .primaryColor
        
        return true
    }
    
    private func resigerForNotifications(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .badge, .alert]) { (granted, error) in
            DispatchQueue.main.async { completion(granted) }
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        debugPrint(#function, token)
        
        let ressource =  Ressource(
            url: URLs.Webservice.appendingPathComponent("apns"),
            body: ["token" : token],
            method: "POST",
            parse: { try JSONDecoder().decode(SimpleResponse.self, from: $0) }
        )
        
        Webservice().request(ressource: ressource, completion: { result in
            switch result {
            case .success(let s):
                debugPrint(s)
                UserDefaults.standard.token = token
            case .failure(let e):
                debugPrint(e)
            }
        })
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugPrint(#function, error)
    }
}
