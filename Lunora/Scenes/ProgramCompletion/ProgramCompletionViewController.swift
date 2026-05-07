//
//  ProgramCompletion.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 24.04.2026.
//

import UIKit

final class ProgramCompletionViewController: UIViewController, UITextViewDelegate {
    
    var programTitle: String?
    var programImageName: String?
    var userId: String?
    var enrollmentId: String?

    private let enrollmentRepository = EnrollmentRepository()
    private let notePlaceholder = "Bu yolculukta neler hissettin?"
    
    private var confettiLayer: CAEmitterLayer?
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let girlImageView = UIImageView()
    private let imageView = UIImageView()
    private let badgeTitleLabel = UILabel()
    private let badgeSubtitleLabel = UILabel()
    private let textView = UITextView()
    private let startButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startGirlFloatingAnimation()
        startConfetti()
    }
    
    private func setupUI() {
        
        // 🎨 Background (#FFE8F4)
        view.backgroundColor = UIColor(
            red: 255/255,
            green: 232/255,
            blue: 244/255,
            alpha: 1
        )
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        setupHeader()
        setupGirlImage()
        setupBadge()
        setupTextArea()
        setupButton()
    }
    
    // MARK: - HEADER
    
    private func setupHeader() {
        
        titleLabel.text = "✨ Harikasın! ✨"
        titleLabel.font = .systemFont(ofSize: 30, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        subtitleLabel.text = "Programını başarıyla tamamladın 🎉"
        subtitleLabel.textAlignment = .center
        subtitleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            subtitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
    // MARK: - GIRL IMAGE
    
    private func setupGirlImage() {
        
        girlImageView.translatesAutoresizingMaskIntoConstraints = false
        girlImageView.image = UIImage(named: "lunoraGirl")
        girlImageView.contentMode = .scaleAspectFit
        
        contentView.addSubview(girlImageView)
        
        NSLayoutConstraint.activate([
            girlImageView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: -10),
            girlImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            girlImageView.widthAnchor.constraint(equalToConstant: 200),
            girlImageView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    // MARK: - BADGE
    
    private func setupBadge() {
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 100
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        // 🔥 ROZET GÖRSELİ
        if let name = programImageName {
            imageView.image = UIImage(named: name)
        }
        
        // 🎯 DAHA GÜZEL GÖRÜNÜM
        imageView.backgroundColor = .white
        imageView.layer.borderWidth = 4
        imageView.layer.borderColor = UIColor.white.cgColor
        
        contentView.addSubview(imageView)
        
        badgeTitleLabel.text = programTitle ?? "Rozet"
        badgeTitleLabel.font = .boldSystemFont(ofSize: 20)
        badgeTitleLabel.textAlignment = .center
        badgeTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        badgeSubtitleLabel.text = "Bu rozeti kazandın!"
        badgeSubtitleLabel.font = .systemFont(ofSize: 14)
        badgeSubtitleLabel.textAlignment = .center
        badgeSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(badgeTitleLabel)
        contentView.addSubview(badgeSubtitleLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: girlImageView.bottomAnchor, constant: -26),
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 200),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            
            badgeTitleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            badgeTitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            badgeSubtitleLabel.topAnchor.constraint(equalTo: badgeTitleLabel.bottomAnchor, constant: 6),
            badgeSubtitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
    // MARK: - TEXT AREA
    
    private func setupTextArea() {
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.cornerRadius = 16
        textView.backgroundColor = .white
        textView.text = notePlaceholder
        textView.textColor = .gray
        textView.delegate = self
        textView.font = .systemFont(ofSize: 15)
        
        contentView.addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: badgeSubtitleLabel.bottomAnchor, constant: 30),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            textView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    // MARK: - BUTTON
    
    private func setupButton() {
        
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.setTitle("Yeni Programa Başla →", for: .normal)
        startButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        startButton.backgroundColor = UIColor(red: 241/255, green: 64/255, blue: 154/255, alpha: 1)
        startButton.setTitleColor(
            UIColor(red: 250/255, green: 244/255, blue: 248/255, alpha: 1),
            for: .normal
        )
        startButton.layer.cornerRadius = 25
        startButton.addTarget(self, action: #selector(didTapStartNewProgram), for: .touchUpInside)
        
        contentView.addSubview(startButton)
        
        NSLayoutConstraint.activate([
            startButton.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 18),
            startButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            startButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            startButton.heightAnchor.constraint(equalToConstant: 50),
            startButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    private func startGirlFloatingAnimation() {
        UIView.animate(
            withDuration: 1.8,
            delay: 0,
            options: [.autoreverse, .repeat, .allowUserInteraction],
            animations: {
                self.girlImageView.transform = CGAffineTransform(translationX: 0, y: -20)
            }
        )
    }
    private func startConfetti() {
        confettiLayer?.removeFromSuperlayer()

        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: view.bounds.midX, y: -20)
        emitter.emitterShape = .line
        emitter.emitterSize = CGSize(width: view.bounds.width * 1.4, height: 1)

        let colors: [UIColor] = [
            UIColor(red: 241/255, green: 64/255, blue: 154/255, alpha: 1),
            UIColor(red: 255/255, green: 205/255, blue: 90/255, alpha: 1),
            UIColor.white,
            UIColor(red: 190/255, green: 120/255, blue: 255/255, alpha: 1)
        ]

        emitter.emitterCells = colors.map { color in
            let cell = CAEmitterCell()
            cell.birthRate = 12
            cell.lifetime = 6
            cell.velocity = 220
            cell.velocityRange = 120
            cell.yAcceleration = 90
            cell.xAcceleration = 0
            cell.emissionLongitude = .pi
            cell.emissionRange = .pi / 2
            cell.spin = 4
            cell.spinRange = 6
            cell.scale = 0.08
            cell.scaleRange = 0.05
            cell.contents = makeConfettiImage(color: color).cgImage
            return cell
        }

        view.layer.addSublayer(emitter)
        confettiLayer = emitter

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            emitter.birthRate = 0
        }
    }

    private func makeConfettiImage(color: UIColor) -> UIImage {
        let size = CGSize(width: 10, height: 14)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            color.setFill()
            UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: 2).fill()
        }
    }
    
    @objc private func didTapStartNewProgram() {
        guard let userId = userId,
              let enrollmentId = enrollmentId else {
            print("🔴 completion: userId veya enrollmentId yok")
            return
        }

        let rawNote = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let note = rawNote == "Bu yolculukta neler hissettin?" ? "" : rawNote

        enrollmentRepository.completeJourney(
            userId: userId,
            enrollmentId: enrollmentId,
            note: note
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                switch result {
                case .success:
                    ProgressCacheManager.shared.clear()
                    NotificationCenter.default.post(name: .activeEnrollmentDidChange, object: nil)

                    self.dismiss(animated: true) {
                        if let tabBarController = UIApplication.shared.connectedScenes
                            .compactMap({ $0 as? UIWindowScene })
                            .flatMap({ $0.windows })
                            .first(where: { $0.isKeyWindow })?
                            .rootViewController as? UITabBarController {
                            tabBarController.selectedIndex = 0
                        }
                    }

                case .failure(let error):
                    print("🔴 Program completion hata:", error.localizedDescription)
                }
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == notePlaceholder {
            textView.text = ""
            textView.textColor = .black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = notePlaceholder
            textView.textColor = .gray
        }
    }
    
}
