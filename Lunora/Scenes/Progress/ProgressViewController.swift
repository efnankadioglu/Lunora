//
//  ProgressViewController.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 28.10.2025.
//

import UIKit
import UICircularProgressRing

class ProgressViewController: UIViewController {

    @IBOutlet weak var progressRing: UICircularProgressRing!

    override func viewDidLoad() {
            super.viewDidLoad()   // ❗️ BUNU UNUTMA

            setupRing()
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)

            animateRing()
        }

        // MARK: - Setup
        private func setupRing() {
            progressRing.maxValue = 100

            progressRing.outerRingColor = UIColor.systemOrange.withAlphaComponent(0.2)
            progressRing.innerRingColor = UIColor.systemOrange

            progressRing.outerRingWidth = 10
            progressRing.innerRingWidth = 10

            progressRing.font = UIFont.systemFont(ofSize: 32, weight: .bold)
            progressRing.fontColor = UIColor.black

            progressRing.shouldShowValueText = true
            progressRing.startAngle = -90
        }

        // MARK: - Animation
        private func animateRing() {
            // Önce sıfırla
            progressRing.startProgress(to: 0, duration: 0)

            // Sonra animasyonu başlat
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.progressRing.startProgress(to: 75, duration: 1.5)
            }
        }
    }
