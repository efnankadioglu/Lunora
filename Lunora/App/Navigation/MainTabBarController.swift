//
//  MainTabBarController.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 12.08.2026.
//

import UIKit

final class MainTabBarController: UITabBarController,
                                  UINavigationControllerDelegate {

    // Tab'lar sonradan değişirse de delegate bağlantıları kaybolmasın.
    override var viewControllers: [UIViewController]? {
        didSet {
            configureNavigationControllers()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // iPad'de de iPhone'daki klasik alt tab bar görünümünü kullan.
        if #available(iOS 18.0, *),
           UIDevice.current.userInterfaceIdiom == .pad {

            traitOverrides.horizontalSizeClass = .compact
        }

        configureNavigationControllers()
    }

    private func configureNavigationControllers() {
        viewControllers?.forEach { controller in

            if let navigationController =
                controller as? UINavigationController {

                navigationController.delegate = self
            }
        }
    }

    // Ekran açılmaya BAŞLARKEN
    func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
        updateTabBarVisibility(
            for: navigationController,
            showing: viewController,
            animated: animated
        )
    }

    // Ekran tamamen AÇILDIKTAN SONRA
    // iPad'de final durumu garanti ediyoruz.
    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        updateTabBarVisibility(
            for: navigationController,
            showing: viewController,
            animated: false
        )

        let screenName = String(describing: type(of: viewController))

        PresenceService.shared.updateScreen(screenName)
    }

    private func updateTabBarVisibility(
        for navigationController: UINavigationController,
        showing viewController: UIViewController,
        animated: Bool
    ) {
        guard let rootViewController =
                navigationController.viewControllers.first
        else {
            return
        }

        // Yalnızca tab'ın ana/root ekranında tab bar görünsün.
        let isRootScreen =
            viewController === rootViewController

        if #available(iOS 18.0, *) {
            setTabBarHidden(
                !isRootScreen,
                animated: animated
            )
        }

        print(
            "🟣 Navigation:",
            String(describing: type(of: viewController)),
            "| Root:", isRootScreen,
            "| Tab gizli:", !isRootScreen
        )
    }
}
