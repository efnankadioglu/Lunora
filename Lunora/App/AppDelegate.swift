//
//  AppDelegate.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 19.10.2025.
//

import UIKit
import CoreData
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import UserNotifications
import FirebaseMessaging
import FirebaseAnalytics

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Application Lifecycle

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // Firebase kurulumu
        FirebaseApp.configure()
        
        // Firebase Analytics
        Analytics.setAnalyticsCollectionEnabled(true)
        
#if DEBUG
Analytics.logEvent("lunora_debug_test", parameters: nil)
#endif
        
        // Firebase Cloud Messaging
        Messaging.messaging().delegate = self
        
        

        // Network monitor
        _ = NetworkMonitor.shared

        // Bildirim merkezi delegate'i
        UNUserNotificationCenter.current().delegate = self
        
        // APNs'e bu cihazı remote notifications için kaydet
        application.registerForRemoteNotifications()

        // Kullanıcı giriş yaptıysa notification verilerini hazırla
        Auth.auth().addStateDidChangeListener { _, user in
            guard user != nil else {
                return
            }
            
            // Kullanıcı presence takibini başlat
               PresenceService.shared.start()

            NotificationPreferencesSyncService.shared.bootstrap { result in
                switch result {

                case .success:
                    NotificationDeviceService.shared.registerCurrentDevice()

                case .failure(let error):
                    print(
                        "❌ Notification bootstrap failed: \(error.localizedDescription)"
                    )
                }
            }
        }

        return true
    }

    // MARK: - UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {

        return UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
    }

    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {
    }

    // MARK: - Core Data Stack

    lazy var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "Lunora")

        container.loadPersistentStores { _, error in

            if let error = error as NSError? {
                fatalError(
                    "Unresolved error \(error), \(error.userInfo)"
                )
            }

            container.viewContext.mergePolicy =
                NSMergeByPropertyObjectTrumpMergePolicy

            container.viewContext.automaticallyMergesChangesFromParent = true
        }

        return container
    }()

    // MARK: - Core Data Saving Support

    func saveContext() {

        let context = persistentContainer.viewContext

        if context.hasChanges {

            do {
                try context.save()
            } catch {

                let nserror = error as NSError

                fatalError(
                    "Unresolved error \(nserror), \(nserror.userInfo)"
                )
            }
        }
    }

    // MARK: - Remote Notifications

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        // Önce APNs token Firebase'e verilir
        Messaging.messaging().apnsToken = deviceToken

        let tokenString = deviceToken
            .map { String(format: "%02x", $0) }
            .joined()

        print("🟢 APNs device token alındı")
        print("🟢 APNs Token: \(tokenString)")

        // APNs token hazır olduktan SONRA FCM registration
        Task {
            do {
                try await Messaging.messaging().register()
                print("🟢 Firebase Messaging register() başarılı")
            } catch {
                print(
                    "🔴 Firebase Messaging register() failed: \(error.localizedDescription)"
                )
            }
        }
    }
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print(
            "🔴 Remote notification registration failed: \(error.localizedDescription)"
        )
    }

    // MARK: - Google Sign-In URL Handling

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {

        return GIDSignIn.sharedInstance.handle(url)
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {

    // Uygulama açıkken bildirim geldiğinde
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {

        return [.banner, .sound, .badge]
    }

    // Kullanıcı bildirime dokunduğunda
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {

        let userInfo =
            response.notification.request.content.userInfo

        print("🔔 Notification tapped")
        print("🔔 userInfo: \(userInfo)")

        // Daha sonra ilgili Lunora ekranına yönlendireceğiz.
    }
}

// MARK: - MessagingDelegate

extension AppDelegate: MessagingDelegate {

    func messaging(
        _ messaging: Messaging,
        didReceiveRegistration installationId: String?
    ) {
        guard let installationId else {
            print("🟡 Firebase Messaging installation ID alınamadı")
            return
        }

        print("🟢 Firebase Messaging registered")
        print("🟢 FID: \(installationId)")

        // Firestore'daki mevcut cihaz kaydını yenile.
        // NotificationDeviceService zaten Firebase Installation ID'yi
        // document ID olarak kullanıyor.
        NotificationDeviceService.shared.registerCurrentDevice()
    }
}
