//
//  LunoraNavigationController.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 12.08.2026.
//

import UIKit

final class LunoraNavigationController: UINavigationController {

    override func pushViewController(
        _ viewController: UIViewController,
        animated: Bool
    ) {
        if !viewControllers.isEmpty {
            viewController.hidesBottomBarWhenPushed = true
        }

        super.pushViewController(
            viewController,
            animated: animated
        )
    }
}
