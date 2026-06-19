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
