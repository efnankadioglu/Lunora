//
//  RoundedImageView.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 24.03.2026.
//

import UIKit

class RoundedImageView: UIImageView {

    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Tam yuvarlak
        self.layer.cornerRadius = self.frame.width / 2
        self.layer.masksToBounds = true
    }
}

//import UIKit
//
//final class RoundedImageView: UIImageView {
//    
//    private let sparkleLabel = UILabel() // EKLENDİ: köşedeki ✨ için
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupView()       // EKLENDİ
//        setupSparkle()    // EKLENDİ
//    }
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupView()       // EKLENDİ
//        setupSparkle()    // EKLENDİ
//    }
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        
//        // GÜNCELLENDİ: tam yuvarlak görünüm
//        layer.cornerRadius = bounds.width / 2
//        layer.masksToBounds = true
//    }
//    
//    private func setupView() { // EKLENDİ
//        contentMode = .scaleAspectFill
//        clipsToBounds = true
//    }
//    
//    private func setupSparkle() { // EKLENDİ
//        sparkleLabel.text = "✨"
//        sparkleLabel.font = .systemFont(ofSize: 14) // GÜNCELLENDİ: biraz küçük tuttuk
//        sparkleLabel.translatesAutoresizingMaskIntoConstraints = false
//        
//        addSubview(sparkleLabel)
//        
//        NSLayoutConstraint.activate([
//            // SİLİNDİ:
//            // sparkleLabel.topAnchor.constraint(equalTo: topAnchor, constant: -4),
//            // sparkleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 4)
//            
//            // EKLENDİ: sağ alt köşe
//            sparkleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6),
//            sparkleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6)
//            // Not: -6 verdiğimiz için köşede ama merkeze biraz daha yakın durur
//        ])
//        
//        // EKLENDİ: hafif parlama efekti
//        sparkleLabel.layer.shadowColor = UIColor.white.cgColor
//        sparkleLabel.layer.shadowRadius = 4
//        sparkleLabel.layer.shadowOpacity = 0.8
//        sparkleLabel.layer.shadowOffset = .zero
//        
//        // EKLENDİ: hafif animasyon
//        sparkleLabel.alpha = 0.75
//        UIView.animate(withDuration: 1.2,
//                       delay: 0,
//                       options: [.autoreverse, .repeat],
//                       animations: {
//            self.sparkleLabel.alpha = 1.0
//        })
//    }
//}
