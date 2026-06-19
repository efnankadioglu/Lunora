//
//  GradientPrimaryButton.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 11.04.2026.
//

import UIKit

final class GradientPrimaryButton: UIButton {

    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = layer.cornerRadius
        
        layer.sublayers?.forEach { layer in
            if let gradient = layer as? CAGradientLayer {
                gradient.frame = bounds
            }
        }
    }

    private func commonInit() {
        setupAppearance()
        setupGradient()
    }

    private func setupAppearance() {
        layer.cornerRadius = 22
        clipsToBounds = true

        setTitleColor(.white, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)

        bringSubviewToFront(titleLabel ?? UIView())

    }

    private func setupGradient() {

        gradientLayer.colors = [
            UIColor(red: 250/255, green: 185/255, blue: 219/255, alpha: 1).cgColor,
            UIColor(red: 245/255, green: 56/255, blue: 154/255, alpha: 1).cgColor
            
        ]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)

        if gradientLayer.superlayer == nil {
            layer.insertSublayer(gradientLayer, at: 0)
        }
    }

    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.88 : 1.0
        }
    }
    
}
