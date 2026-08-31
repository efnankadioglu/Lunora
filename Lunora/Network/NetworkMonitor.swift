////
////  NetworkMonitor.swift
////  Lunora
////
////  Created by Efnan Kadıoğlu on 17.04.2026.
////
//
//import Foundation
//import Network
//
//final class NetworkMonitor {
//    static let shared = NetworkMonitor()
//
//    private let monitor = NWPathMonitor()
//    private let queue = DispatchQueue(label: "NetworkMonitorQueue")
//
//    private(set) var isConnected: Bool = true
//
//    var onConnectionRestored: (() -> Void)?
//
//    private init() {
//        startMonitoring()
//    }
//
//    private func startMonitoring() {
//        monitor.pathUpdateHandler = { [weak self] path in
//            guard let self = self else { return }
//
//            let wasConnected = self.isConnected
//            let isNowConnected = path.status == .satisfied
//
//            self.isConnected = isNowConnected
//
//            print("🌐 Network status:", isNowConnected ? "ONLINE" : "OFFLINE")
//
//            if wasConnected == false && isNowConnected == true {
//                print("🟢 Internet geri geldi")
//                DispatchQueue.main.async {
//                    self.onConnectionRestored?()
//                }
//            }
//        }
//
//        monitor.start(queue: queue)
//    }
//}

//
//  NetworkMonitor.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 17.04.2026.
//

import Foundation
import Network

final class NetworkMonitor {

    static let shared = NetworkMonitor()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")
    private let lock = NSLock()

    private var _isConnected: Bool = false

    var isConnected: Bool {
        lock.lock()
        defer { lock.unlock() }

        return _isConnected
    }

    var onConnectionRestored: (() -> Void)?

    private init() {
        startMonitoring()
    }

    private func startMonitoring() {

        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }

            let isNowConnected = path.status == .satisfied

            self.lock.lock()

            let wasConnected = self._isConnected
            self._isConnected = isNowConnected

            self.lock.unlock()

            print(
                "🌐 Network status:",
                isNowConnected ? "ONLINE" : "OFFLINE"
            )

            if wasConnected == false && isNowConnected == true {

                print("🟢 Internet geri geldi")

                DispatchQueue.main.async {
                    self.onConnectionRestored?()
                }
            }
        }

        monitor.start(queue: queue)
    }
}
