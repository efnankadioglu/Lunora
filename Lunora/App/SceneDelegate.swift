//
//  SceneDelegate.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 19.10.2025.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let rootVC: UIViewController

        if let uid = Auth.auth().currentUser?.uid,
           ProfileStore.shared.fetchProfile(uid: uid) != nil {

            rootVC = buildMainTabBar()

        } else {
            rootVC = UIStoryboard(name: "Main", bundle: nil)
                .instantiateInitialViewController()!
        }

        window.rootViewController = rootVC
        window.makeKeyAndVisible()
    }
    
    func buildMainTabBar() -> UITabBarController {
        let pembe = UIColor(red: 242/255, green: 92/255, blue: 184/255, alpha: 1)
        let sari = UIColor(red: 224/255, green: 210/255, blue: 54/255, alpha: 1)
        let programList = UIStoryboard(name: "ProgramList", bundle: nil).instantiateViewController(withIdentifier: "ProgramListNav")
        programList.tabBarItem = UITabBarItem(
            title: "Programs",
            image: UIImage(systemName: "square.grid.2x2")?.withTintColor(pembe, renderingMode: .alwaysOriginal),
            selectedImage: UIImage(systemName: "square.grid.2x2")?.withTintColor(pembe, renderingMode: .alwaysOriginal)
        )

        let progress = UIStoryboard(name: "Progress", bundle: nil).instantiateViewController(withIdentifier: "ProgressNav")
        progress.tabBarItem = UITabBarItem(
            title: "Progress",
            image: UIImage(systemName: "chart.bar")?.withTintColor(pembe, renderingMode: .alwaysOriginal),
            selectedImage: UIImage(systemName: "chart.bar")?.withTintColor(pembe, renderingMode: .alwaysOriginal)
        )

        let completed = UIStoryboard(name: "CompletedPrograms", bundle: nil).instantiateViewController(withIdentifier: "CompletedProgramsNav")
        completed.tabBarItem = UITabBarItem(
            title: "Completed",
            image: UIImage(systemName: "checkmark.circle")?.withTintColor(pembe, renderingMode: .alwaysOriginal),
            selectedImage: UIImage(systemName: "checkmark.circle")?.withTintColor(pembe, renderingMode: .alwaysOriginal)
        )

        let profile = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "ProfileNav")
        profile.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person.circle")?.withTintColor(pembe, renderingMode: .alwaysOriginal),
            selectedImage: UIImage(systemName: "person.circle")?.withTintColor(pembe, renderingMode: .alwaysOriginal)
        )
        let controllers = [programList, progress, completed, profile]
        for controller in controllers {
            controller.tabBarItem.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
            controller.tabBarItem.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        }

        let tab = UITabBarController()
        tab.viewControllers = controllers
        tab.tabBar.unselectedItemTintColor = pembe
        tab.tabBar.tintColor = sari

        return tab
    }

    // MARK: - Root geçiş yardımcısı (ileride logout vs. için kullanırsın)
    func setRoot(_ vc: UIViewController, animated: Bool = true) {
        guard let window = window else { return }
        if animated {
            UIView.transition(with: window,
                              duration: 0.3,
                              options: .transitionCrossDissolve) {
                window.rootViewController = vc
            }
        } else {
            window.rootViewController = vc
        }
        window.makeKeyAndVisible()
    }
}
