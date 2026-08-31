//
//  NotificationPromptCoordinator.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 25.08.2026.
//

import UIKit

final class NotificationPromptCoordinator {

    static let shared = NotificationPromptCoordinator()

    private init() {}


    // MARK: - Public

    func presentIfAppropriate(
        from presenter: UIViewController,
        context: NotificationPromptContext
    ) {

        // Ekranda zaten başka bir modal varsa
        // üstüne yeni popup bindirmiyoruz.
        guard presenter.presentedViewController == nil else {
            return
        }

        NotificationPromptManager.shared
            .evaluatePrompt(for: context) { [weak presenter] decision in

                DispatchQueue.main.async {

                    guard let presenter else {
                        return
                    }

                    switch decision {

                    case .none:

                        // Her şey zaten doğru durumda.
                        // Kullanıcıyı rahatsız etme.
                        return


                    case .requestSystemPermission:

                        self.presentPrompt(
                            from: presenter,
                            context: context
                        ) {

                            NotificationManager.shared
                                .requestNotificationPermission { granted in

                                    if granted {

                                        NotificationPreferences.shared
                                            .setNotificationsEnabled(true)

                                        NotificationPromptManager.shared
                                            .markNotificationsEnabled()

                                        print(
                                            "🟢 Notification permission enabled"
                                        )

                                    } else {

                                        print(
                                            "🟡 Notification permission not granted"
                                        )
                                    }
                                }
                        }


                    case .openSystemSettings:

                        self.presentPrompt(
                            from: presenter,
                            context: context
                        ) {

                            NotificationManager.shared
                                .openSystemNotificationSettings()
                        }


                    case .enableLunoraNotifications:

                        self.presentPrompt(
                            from: presenter,
                            context: context
                        ) {

                            NotificationPreferences.shared
                                .setNotificationsEnabled(true)

                            NotificationPromptManager.shared
                                .markNotificationsEnabled()

                            print(
                                "🟢 Lunora notifications enabled"
                            )
                        }
                    }
                }
            }
    }


    // MARK: - Presentation

    private func presentPrompt(
        from presenter: UIViewController,
        context: NotificationPromptContext,
        action: @escaping () -> Void
    ) {

        NotificationPromptManager.shared
            .markPromptShown()


        let promptViewController =
            NotificationPermissionPromptViewController(
                context: context
            )


        promptViewController.onContinue = {

            action()
        }


        promptViewController.modalPresentationStyle = .pageSheet


        if let sheet =
            promptViewController.sheetPresentationController {

            sheet.detents = [.large()]

            sheet.prefersGrabberVisible = true

            sheet.preferredCornerRadius = 28
        }


        presenter.present(
            promptViewController,
            animated: true
        )
    }
}
