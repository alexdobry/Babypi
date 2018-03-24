//
//  AppDelegate.swift
//  Babypi
//
//  Created by Alex on 24.12.17.
//  Copyright © 2017 Alexander Dobrynin. All rights reserved.
//

import UIKit

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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if let window = window {
            app = App(window: window)
        }
        
        window?.tintColor = .primaryColor
        
        return true
    }
}
