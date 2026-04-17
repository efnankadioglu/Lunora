//
//  ProgramTableViewCell.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 9.12.2025.
//

import UIKit

class ProgramTableViewCell: UITableViewCell {
    
    @IBOutlet weak var programImage: UIImageView!
    @IBOutlet weak var programName: UILabel!
    @IBOutlet weak var programLevel: UIButton!
    @IBOutlet weak var programDuration: UIButton!
    @IBOutlet weak var oneSentence: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var programStartButton: UIButton!
    
    var onTapStartButton: (() -> Void)?
    
    override func awakeFromNib() {
            super.awakeFromNib()
            setupUI()
        }

        override func prepareForReuse() {
            super.prepareForReuse()
            
            programImage.image = nil
            programName.text = nil
            programDuration.setTitle(nil, for: .normal)
            oneSentence.text = nil
            programLevel.setTitle(nil, for: .normal)
        }

        func configure(with program: Program) {
            programName.text = program.name
            programDuration.setTitle(program.durationText, for: .normal)
            oneSentence.text = program.oneSentenceSummary
            programImage.image = UIImage(named: program.imageName) ?? UIImage(named: "program_placeholder")
            programLevel.setTitle("Zorluk \(program.difficultyLevel)/\(program.difficultyScale)", for: .normal)
        }
    func applyStartButtonState(isActiveProgram: Bool) {
        if isActiveProgram {
            programStartButton.setTitle("Aktif", for: .normal)
            programStartButton.alpha = 0.75
        } else {
            programStartButton.setTitle("Başlat", for: .normal)
            programStartButton.alpha = 1.0
        }
    }
    
        
        private func setupUI() {
            programStartButton.addTarget(self, action: #selector(didTapProgramStartButton), for: .touchUpInside)
            selectionStyle = .none
            backgroundColor = .clear
            contentView.backgroundColor = .clear
            
            // Kart görünümü
            cardView.backgroundColor = UIColor.white.withAlphaComponent(0.55)
            cardView.layer.cornerRadius = 24
            cardView.layer.masksToBounds = true
            cardView.layer.borderWidth = 1
            cardView.layer.borderColor = UIColor.white.withAlphaComponent(0.30).cgColor
            
            // Başlık
            programName.numberOfLines = 2
            programName.font = .systemFont(ofSize: 22, weight: .semibold)
            programName.textColor = UIColor.label.withAlphaComponent(0.95)
            
            // Süre
           // programDuration.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
          //  programDuration.setTitleColor(.systemPink, for: .normal)
            
            // Açıklama
            oneSentence.numberOfLines = 6
            oneSentence.font = .systemFont(ofSize: 16, weight: .regular)
            oneSentence.textColor = UIColor.label.withAlphaComponent(0.65)
            
            // Zorluk butonu / badge
            configureLevelButtonStyle()
        }
        
        private func configureLevelButtonStyle() {
            programLevel.isUserInteractionEnabled = false
            programLevel.clipsToBounds = true
            programLevel.layer.cornerRadius = 18
            
            if #available(iOS 15.0, *) {
                var config = UIButton.Configuration.filled()
                config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 14, bottom: 8, trailing: 14)
                config.cornerStyle = .capsule
                programLevel.configuration = config
            } else {
                programLevel.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
                programLevel.contentEdgeInsets = UIEdgeInsets(top: 8, left: 14, bottom: 8, right: 14)
            }
            
            programLevel.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        }
    
    
    @IBAction func didTapProgramStartButton(_ sender: UIButton) {
        onTapStartButton?()
    }
    
    }
