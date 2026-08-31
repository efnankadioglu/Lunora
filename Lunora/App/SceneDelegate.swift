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

    // MARK: - Scene

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {

        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let rootVC: UIViewController

        // MARK: Kullanıcı giriş yapmış mı?

        if let uid = Auth.auth().currentUser?.uid,
           ProfileStore.shared.fetchProfile(uid: uid) != nil {

            // Kullanıcı giriş yapmış ve profili var.
            let firstExperienceCoordinator = FirstExperienceCoordinator(
                userID: uid
            )

            if firstExperienceCoordinator.shouldStartFirstExperience {

                // First Experience henüz tamamlanmamış.
                rootVC = buildFirstExperience(
                    coordinator: firstExperienceCoordinator
                )

            } else {

                // First Experience daha önce tamamlanmış.
                rootVC = buildMainTabBar()
            }

        } else {

            // Kullanıcı giriş yapmamış veya profili henüz yok.
            let loginViewController = LoginViewController()

            let navigationController = UINavigationController(
                rootViewController: loginViewController
            )

            navigationController.setNavigationBarHidden(
                true,
                animated: false
            )

            rootVC = navigationController
        }

        window.rootViewController = rootVC
        window.makeKeyAndVisible()
    }

    // MARK: - First Experience

    func buildFirstExperience(
        coordinator: FirstExperienceCoordinator
    ) -> UIViewController {

        let needViewController =
            FirstExperienceNeedViewController(
                coordinator: coordinator
            )

        let navigationController =
            UINavigationController(
                rootViewController: needViewController
            )

        navigationController.setNavigationBarHidden(
            true,
            animated: false
        )

        // MARK: 1 / 3 → 2 / 3

        needViewController.onContinue = {
            [weak navigationController] need in

            guard let navigationController else {
                return
            }

            print(
                "🧭 PREVIEW WILL OPEN:",
                need.rawValue
            )

            let previewViewController =
                FirstExperienceSelectedPreviewViewController(
                    coordinator: coordinator,
                    need: need
                )

            // 2. ekrandan geri → 1. ekran
            previewViewController.onBack = {
                [weak navigationController] in

                navigationController?
                    .popViewController(
                        animated: true
                    )
            }

            // MARK: 2 / 3 → 3 / 3

            previewViewController.onContinue = {
                [weak navigationController, weak self] in

                guard
                    let navigationController,
                    let self
                else {
                    return
                }

                let handoffViewController =
                    FirstExperienceHandoffViewController(
                        coordinator: coordinator
                    )

                // 3. ekrandan geri → 2. ekran
                handoffViewController.onBack = {
                    [weak navigationController] in

                    navigationController?
                        .popViewController(
                            animated: true
                        )
                }

                // MARK: 3 / 3 → Gerçek Lunora

                handoffViewController.onContinue = {
                    [weak self] in

                    guard let self else {
                        return
                    }

                    let mainTabBar =
                        self.buildMainTabBar()

                    // Programlar sekmesi
                    mainTabBar.selectedIndex = 0

                    self.setRoot(
                        mainTabBar,
                        animated: true
                    )
                }

                navigationController
                    .pushViewController(
                        handoffViewController,
                        animated: true
                    )
            }

            navigationController
                .pushViewController(
                    previewViewController,
                    animated: true
                )
        }

        return navigationController
    }

    // MARK: - Main Tab Bar

    func buildMainTabBar() -> UITabBarController {

        let pembe = UIColor(
            red: 242/255,
            green: 92/255,
            blue: 184/255,
            alpha: 1
        )

        let sari = UIColor(
            red: 224/255,
            green: 210/255,
            blue: 54/255,
            alpha: 1
        )

        // Programlar
        let programListViewController = ProgramListViewController()

        let programList = LunoraNavigationController(
            rootViewController: programListViewController
        )

        programList.tabBarItem = UITabBarItem(
            title: "Programlar",
            image: UIImage(systemName: "square.grid.2x2")?
                .withTintColor(
                    pembe,
                    renderingMode: .alwaysOriginal
                ),
            selectedImage: UIImage(systemName: "square.grid.2x2")?
                .withTintColor(
                    pembe,
                    renderingMode: .alwaysOriginal
                )
        )

        // İlerleme
        let progress = UIStoryboard(
            name: "Progress",
            bundle: nil
        ).instantiateViewController(
            withIdentifier: "ProgressNav"
        )

        progress.tabBarItem = UITabBarItem(
            title: "İlerleme",
            image: UIImage(systemName: "chart.bar")?
                .withTintColor(
                    pembe,
                    renderingMode: .alwaysOriginal
                ),
            selectedImage: UIImage(systemName: "chart.bar")?
                .withTintColor(
                    pembe,
                    renderingMode: .alwaysOriginal
                )
        )

        // Tamamlanan
        let completed = UIStoryboard(
            name: "CompletedPrograms",
            bundle: nil
        ).instantiateViewController(
            withIdentifier: "CompletedProgramsNav"
        )

        completed.tabBarItem = UITabBarItem(
            title: "Tamamlanan",
            image: UIImage(systemName: "checkmark.circle")?
                .withTintColor(
                    pembe,
                    renderingMode: .alwaysOriginal
                ),
            selectedImage: UIImage(systemName: "checkmark.circle")?
                .withTintColor(
                    pembe,
                    renderingMode: .alwaysOriginal
                )
        )

        // Profil
        let profile = UIStoryboard(
            name: "Profile",
            bundle: nil
        ).instantiateViewController(
            withIdentifier: "ProfileNav"
        )

        profile.tabBarItem = UITabBarItem(
            title: "Profil",
            image: UIImage(systemName: "person.circle")?
                .withTintColor(
                    pembe,
                    renderingMode: .alwaysOriginal
                ),
            selectedImage: UIImage(systemName: "person.circle")?
                .withTintColor(
                    pembe,
                    renderingMode: .alwaysOriginal
                )
        )

        let controllers = [
            programList,
            progress,
            completed,
            profile
        ]

        for controller in controllers {

            controller.tabBarItem.setTitleTextAttributes(
                [.foregroundColor: UIColor.black],
                for: .normal
            )

            controller.tabBarItem.setTitleTextAttributes(
                [.foregroundColor: UIColor.black],
                for: .selected
            )
        }

        let tab = MainTabBarController()

        tab.viewControllers = controllers

        tab.tabBar.unselectedItemTintColor = pembe
        tab.tabBar.tintColor = sari

        return tab
    }

    // MARK: - Root Geçiş Yardımcısı

    func setRoot(
        _ vc: UIViewController,
        animated: Bool = true
    ) {

        guard let window = window else {
            return
        }

        if animated {

            UIView.transition(
                with: window,
                duration: 0.3,
                options: .transitionCrossDissolve
            ) {
                window.rootViewController = vc
            }

        } else {

            window.rootViewController = vc
        }

        window.makeKeyAndVisible()
    }
}
