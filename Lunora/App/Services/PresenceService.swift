//
//  PresenceService.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 30.08.2026.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

final class PresenceService {

    static let shared = PresenceService()

    private let database = Database.database()
    private var userRef: DatabaseReference?
    private var connectedRef: DatabaseReference?
    private var connectedHandle: UInt?

    private var uid: String?
    private var currentScreen = "unknown"
    private var isAppActive = true

    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }

    // MARK: - Start

    func start() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }

        if self.uid == uid {
            return
        }

        removeConnectionObserver()

        self.uid = uid
        self.userRef = database
            .reference()
            .child("presence")
            .child(uid)

        let connectedRef = database.reference(withPath: ".info/connected")
        self.connectedRef = connectedRef

        connectedHandle = connectedRef.observe(.value) { [weak self] snapshot in
            guard let self else { return }

            let connected = snapshot.value as? Bool ?? false

            guard connected, self.isAppActive else {
                return
            }

            self.configureOnlinePresence(startNewSession: true)
        }
    }

    // MARK: - Screen

    func updateScreen(_ screen: String) {
        currentScreen = screen

        guard isAppActive else {
            return
        }

        userRef?.updateChildValues([
            "currentScreen": screen,
            "lastSeenAt": ServerValue.timestamp()
        ])
    }

    // MARK: - Online

    private func configureOnlinePresence(startNewSession: Bool) {
        guard let userRef else {
            return
        }

        // Bağlantı koparsa Firebase sunucusu kullanıcıyı offline yapar.
        userRef.onDisconnectUpdateChildValues([
            "online": false,
            "lastSeenAt": ServerValue.timestamp()
        ])

        var values: [AnyHashable: Any] = [
            "online": true,
            "currentScreen": currentScreen,
            "lastSeenAt": ServerValue.timestamp(),
            "appVersion": appVersion
        ]

        if startNewSession {
            values["sessionStartedAt"] = ServerValue.timestamp()
        }

        userRef.updateChildValues(values)
    }

    // MARK: - App Lifecycle

    @objc
    private func appDidBecomeActive() {
        isAppActive = true

        connectedRef?.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self else { return }

            let connected = snapshot.value as? Bool ?? false

            if connected {
                self.configureOnlinePresence(startNewSession: true)
            }
        }
    }

    @objc
    private func appDidEnterBackground() {
        isAppActive = false

        userRef?.updateChildValues([
            "online": false,
            "lastSeenAt": ServerValue.timestamp()
        ])
    }

    // MARK: - Cleanup

    func prepareForSignOut() {
        userRef?.updateChildValues([
            "online": false,
            "lastSeenAt": ServerValue.timestamp()
        ])

        userRef?.cancelDisconnectOperations()
        removeConnectionObserver()

        uid = nil
        userRef = nil
    }

    private func removeConnectionObserver() {
        if let connectedHandle {
            connectedRef?.removeObserver(withHandle: connectedHandle)
        }

        connectedHandle = nil
        connectedRef = nil
    }

    private var appVersion: String {
        Bundle.main.object(
            forInfoDictionaryKey: "CFBundleShortVersionString"
        ) as? String ?? "unknown"
    }
}
