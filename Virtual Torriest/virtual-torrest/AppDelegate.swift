//
//  AppDelegate.swift
//  Virtual tourist
//
//  Created by Eslam  on 5/11/19.
//  Copyright © 2019 Eslam. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func checkIfFirstLaunch() {
        if UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            print("App has launched before")
            dataController.load()
        } else {
            print("This is the first launch ever!")
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            UserDefaults.standard.synchronize()
            dataController.load()
        }
    }

    let dataController = DataController(modelName: "mapAnnotations")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        checkIfFirstLaunch()
        
        let navigationController = window?.rootViewController as! UINavigationController
        let notebooksListViewController = navigationController.topViewController as! MapViewController
        notebooksListViewController.dataController = dataController
        
        return true
    }
    func applicationWillTerminate(_ application: UIApplication) {
       saveViewContext ()
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        saveViewContext ()
    }
    
    func saveViewContext () {
        try? dataController.viewContext.save()
    }

}

