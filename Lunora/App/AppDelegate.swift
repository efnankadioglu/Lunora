//
//  AppDelegate.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 19.10.2025.
//

import UIKit
import CoreData
import FirebaseCore
import GoogleSignIn

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Application lifecycle

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Firebase kurulumu
        FirebaseApp.configure()

        return true
    }
    // MARK: - UISceneSession Lifecycle

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {

        return UISceneConfiguration(name: "Default Configuration",
                                    sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication,
                     didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
    // MARK: - Core Data stack  ✅ (Yeni eklediğimiz kısım)
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Lunora")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            container.viewContext.automaticallyMergesChangesFromParent = true           
        })
        return container
    }()
    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    // MARK: - Google Sign-In URL handling

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {

        return GIDSignIn.sharedInstance.handle(url)
    }
}
