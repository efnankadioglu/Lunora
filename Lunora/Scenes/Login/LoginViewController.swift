//
//  LoginViewController.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 28.10.2025.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices
import CryptoKit

class LoginViewController: UIViewController {
    
    // MARK: - Delegate
    
    private weak var delegate: LoginDelegate?
    private var currentNonce: String?
    
    private var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    
    // MARK: - Background
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.image = UIImage(named: "welcome_background_phone")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    // MARK: - Lunora Logo
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.image = UIImage(named: "lunora_logo")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    
    // MARK: - Hero Aura
    
    private let heroImageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.image = UIImage(named: "welcome_hero_aura")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    
    // MARK: - Title
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Gökyüzü rehberliğinde\nkendini inşa et"
        
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(
            .required,
            for: .vertical
        )
        label.textAlignment = .center
        
        label.font = UIFont(
            name: "Georgia",
            size: 32
        ) ?? UIFont.systemFont(
            ofSize: 32,
            weight: .medium
        )
        
        label.textColor = UIColor(
            red: 74 / 255,
            green: 48 / 255,
            blue: 93 / 255,
            alpha: 1
        )
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    
    // MARK: - Subtitle
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Günlük astroloji rehberi, kişisel gelişim programları ve sana özel ilerleme yolculuğu tek yerde."
        
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center

        label.setContentCompressionResistancePriority(
            .required,
            for: .vertical
        )
        
        label.font = UIFont.systemFont(
            ofSize: 16,
            weight: .regular
        )
        
        label.textColor = UIColor(
            red: 92 / 255,
            green: 72 / 255,
            blue: 110 / 255,
            alpha: 1
        )
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    
    // MARK: - Feature Stack
    
    private lazy var featureStackView: UIStackView = {

        let daily = makeFeatureCard(
            imageName: "feature_daily_icon",
            title: "Günlük İçgörü",
            iconSize: 46
        )

        let programs = makeFeatureCard(
            imageName: "feature_program_icon",
            title: "Programlar",
            iconSize: 46
        )

        let badges = makeFeatureCard(
            imageName: "feature_badge_icon",
            title: "Rozetler",
            iconSize: 46
        )

        let stack = UIStackView(
            arrangedSubviews: [
                daily,
                programs,
                badges
            ]
        )

        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .fill
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        return stack
    }()
    
    
    // MARK: - Apple Button
    
    private lazy var appleButton: UIButton = {
        
        var configuration = UIButton.Configuration.filled()
        
        configuration.title = "Apple ile devam et"
        
        configuration.image = UIImage(
            systemName: "apple.logo"
        )
        
        configuration.imagePadding = 14
        
        configuration.baseBackgroundColor = .black
        configuration.baseForegroundColor = .white
        
        configuration.cornerStyle = .capsule
        
        configuration.titleTextAttributesTransformer =
        UIConfigurationTextAttributesTransformer { incoming in
            
            var outgoing = incoming
            
            outgoing.font = UIFont.systemFont(
                ofSize: 18,
                weight: .medium
            )
            
            return outgoing
        }
        
        let button = UIButton(configuration: configuration)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(
            self,
            action: #selector(appleButtonTapped),
            for: .touchUpInside
        )
        
        return button
    }()
    
    
    // MARK: - Google Button
    
    private lazy var signinWithGoogleButton: UIButton = {
        
        var configuration = UIButton.Configuration.filled()
        
        configuration.title = "Google ile devam et"
        
        configuration.image = UIImage(
            named: "google_g"
        )
        
        configuration.imagePadding = 14
        
        configuration.baseBackgroundColor = .white
        configuration.baseForegroundColor = .black
        
        configuration.cornerStyle = .capsule
        
        configuration.titleTextAttributesTransformer =
        UIConfigurationTextAttributesTransformer { incoming in
            
            var outgoing = incoming
            
            outgoing.font = UIFont.systemFont(
                ofSize: 18,
                weight: .medium
            )
            
            return outgoing
        }
        
        let button = UIButton(configuration: configuration)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.06
        button.layer.shadowRadius = 10
        button.layer.shadowOffset = CGSize(
            width: 0,
            height: 4
        )
        
        button.addTarget(
            self,
            action: #selector(signInWithGoogleTapped),
            for: .touchUpInside
        )
        
        return button
    }()

    // MARK: - Email Button

    private lazy var emailButton: UIButton = {
        let button = UIButton(type: .system)

        let color = UIColor(
            red: 74 / 255,
            green: 48 / 255,
            blue: 93 / 255,
            alpha: 1
        )

        let attributedTitle = NSAttributedString(
            string: "E-posta ile devam et",
            attributes: [
                .font: UIFont.systemFont(
                    ofSize: 15,
                    weight: .semibold
                ),
                .foregroundColor: color,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
        )

        button.setAttributedTitle(
            attributedTitle,
            for: .normal
        )

        button.translatesAutoresizingMaskIntoConstraints = false

        button.addTarget(
            self,
            action: #selector(emailButtonTapped),
            for: .touchUpInside
        )

        return button
    }()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self

        configureForDevice()
        setupView()
        setupLayout()
    }
    
    private func configureForDevice() {

        if isPad {

            titleLabel.font = UIFont(
                name: "Georgia",
                size: 44
            ) ?? UIFont.systemFont(
                ofSize: 44,
                weight: .medium
            )

            subtitleLabel.font = UIFont.systemFont(
                ofSize: 20,
                weight: .regular
            )

        } else {

            titleLabel.font = UIFont(
                name: "Georgia",
                size: 32
            ) ?? UIFont.systemFont(
                ofSize: 32,
                weight: .medium
            )

            subtitleLabel.font = UIFont.systemFont(
                ofSize: 16,
                weight: .regular
            )
        }
    }
    
    
    // MARK: - Setup View
    
    private func setupView() {
        
        view.backgroundColor = UIColor(
            red: 1,
            green: 0.92,
            blue: 0.95,
            alpha: 1
        )
        
        view.addSubview(backgroundImageView)
        
        view.addSubview(logoImageView)
        view.addSubview(heroImageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(featureStackView)
        view.addSubview(appleButton)
        view.addSubview(signinWithGoogleButton)
        view.addSubview(emailButton)
    }
    
    
    // MARK: - Layout
    
    private func setupLayout() {

        // MARK: - Ortak Constraints

        NSLayoutConstraint.activate([

            // Background
            backgroundImageView.topAnchor.constraint(
                equalTo: view.topAnchor
            ),

            backgroundImageView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),

            backgroundImageView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),

            backgroundImageView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),


            // Logo
            logoImageView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: isPad ? 60 : 6
            ),

            logoImageView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),


            // Hero
            heroImageView.topAnchor.constraint(
                equalTo: logoImageView.bottomAnchor,
                constant: isPad ? 18 : 4
            ),

            heroImageView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),

            heroImageView.heightAnchor.constraint(
                equalTo: heroImageView.widthAnchor
            ),


            // Title
            titleLabel.topAnchor.constraint(
                equalTo: heroImageView.bottomAnchor,
                constant: isPad ? 30 : -10
            ),

            titleLabel.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),

            titleLabel.leadingAnchor.constraint(
                greaterThanOrEqualTo: view.leadingAnchor,
                constant: 28
            ),

            titleLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: view.trailingAnchor,
                constant: -28
            ),


            // Subtitle
            subtitleLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: isPad ? 18 : 16
            ),

            subtitleLabel.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),

            subtitleLabel.leadingAnchor.constraint(
                greaterThanOrEqualTo: view.leadingAnchor,
                constant: 34
            ),

            subtitleLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: view.trailingAnchor,
                constant: -34
            ),


            // Feature Stack
            featureStackView.topAnchor.constraint(
                equalTo: subtitleLabel.bottomAnchor,
                constant: isPad ? 28 : 12
            ),

            featureStackView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),


            // Apple
            appleButton.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),


            // Google
            signinWithGoogleButton.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            
            // Email
            emailButton.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            )
        ])


        // MARK: - iPad

        if isPad {

            NSLayoutConstraint.activate([

                // Logo - iPad'de çok daha büyük
                logoImageView.widthAnchor.constraint(
                    equalToConstant: 430
                ),

                logoImageView.heightAnchor.constraint(
                    equalToConstant: 250
                ),


                // Hero
                heroImageView.widthAnchor.constraint(
                    equalToConstant: 260
                ),


                // Title
                titleLabel.widthAnchor.constraint(
                    lessThanOrEqualToConstant: 760
                ),


                // Subtitle
                subtitleLabel.widthAnchor.constraint(
                    lessThanOrEqualToConstant: 720
                ),


                // Feature cards
                featureStackView.widthAnchor.constraint(
                    equalToConstant: 720
                ),

                featureStackView.heightAnchor.constraint(
                    equalToConstant: 128
                ),


                // Google en aşağıda
                signinWithGoogleButton.widthAnchor.constraint(
                    equalToConstant: 640
                ),

                signinWithGoogleButton.heightAnchor.constraint(
                    equalToConstant: 64
                ),

                signinWithGoogleButton.bottomAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                    constant: -65
                ),


                // Apple Google'ın üstünde
                appleButton.widthAnchor.constraint(
                    equalToConstant: 640
                ),

                appleButton.heightAnchor.constraint(
                    equalToConstant: 64
                ),

                appleButton.bottomAnchor.constraint(
                    equalTo: signinWithGoogleButton.topAnchor,
                    constant: -16
                ),


                // Kartlarla butonların üst üste gelmesini engelle
                appleButton.topAnchor.constraint(
                    greaterThanOrEqualTo: featureStackView.bottomAnchor,
                    constant: 45
                )
            ])


        // MARK: - iPhone

        } else {

            NSLayoutConstraint.activate([

                // Logo
                logoImageView.widthAnchor.constraint(
                    equalToConstant: 280
                ),

                logoImageView.heightAnchor.constraint(
                    equalToConstant: 170
                ),


                // Hero
                heroImageView.widthAnchor.constraint(
                    equalTo: view.widthAnchor,
                    multiplier: 0.42
                ),

                heroImageView.widthAnchor.constraint(
                    lessThanOrEqualToConstant: 260
                ),


                // Features
                featureStackView.leadingAnchor.constraint(
                    equalTo: view.leadingAnchor,
                    constant: 22
                ),

                featureStackView.trailingAnchor.constraint(
                    equalTo: view.trailingAnchor,
                    constant: -22
                ),

                featureStackView.heightAnchor.constraint(
                    equalToConstant: 104
                ),


                // Apple
                appleButton.topAnchor.constraint(
                    equalTo: featureStackView.bottomAnchor,
                    constant: 12
                ),

                appleButton.leadingAnchor.constraint(
                    equalTo: view.leadingAnchor,
                    constant: 30
                ),

                appleButton.trailingAnchor.constraint(
                    equalTo: view.trailingAnchor,
                    constant: -30
                ),

                appleButton.heightAnchor.constraint(
                    equalToConstant: 58
                ),


                // Google
                signinWithGoogleButton.topAnchor.constraint(
                    equalTo: appleButton.bottomAnchor,
                    constant: 12
                ),

                signinWithGoogleButton.leadingAnchor.constraint(
                    equalTo: appleButton.leadingAnchor
                ),

                signinWithGoogleButton.trailingAnchor.constraint(
                    equalTo: appleButton.trailingAnchor
                ),

                signinWithGoogleButton.heightAnchor.constraint(
                    equalToConstant: 58
                ),
                
                // Email
                emailButton.topAnchor.constraint(
                    equalTo: signinWithGoogleButton.bottomAnchor,
                    constant: 4
                ),

                emailButton.heightAnchor.constraint(
                    equalToConstant: 32
                ),

                emailButton.bottomAnchor.constraint(
                    lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor,
                    constant: -6
                )

                
            ])
        }
    }
    
    
    
    // MARK: - Feature Card
    
    private func makeFeatureCard(
        imageName: String,
        title: String,
        iconSize: CGFloat = 58
    ) -> UIView {

        let card = UIView()

        card.backgroundColor = UIColor.white.withAlphaComponent(0.72)
        card.layer.cornerRadius = 24
        card.layer.cornerCurve = .continuous

        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.06
        card.layer.shadowRadius = 14
        card.layer.shadowOffset = CGSize(
            width: 0,
            height: 6
        )


        // MARK: - Invisible Icon Frame

        let iconContainer = UIView()
        iconContainer.translatesAutoresizingMaskIntoConstraints = false

        // Buraya backgroundColor / border YOK.
        // Sadece ikonları aynı hizada tutmak için kullanıyoruz.


        // MARK: - Icon

        let imageView = UIImageView()

        imageView.image = UIImage(named: imageName)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        iconContainer.addSubview(imageView)


        // MARK: - Label

        let label = UILabel()

        label.text = title
        label.textAlignment = .center

        label.textColor = UIColor(
            red: 37 / 255,
            green: 30 / 255,
            blue: 42 / 255,
            alpha: 1
        )

        label.font = UIFont.systemFont(
            ofSize: 14,
            weight: .medium
        )

        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        label.translatesAutoresizingMaskIntoConstraints = false


        // MARK: - Add Views

        card.addSubview(iconContainer)
        card.addSubview(label)


        NSLayoutConstraint.activate([

            // Invisible ortak icon frame
            iconContainer.topAnchor.constraint(
                equalTo: card.topAnchor,
                constant: 10
            ),

            iconContainer.centerXAnchor.constraint(
                equalTo: card.centerXAnchor
            ),

            iconContainer.widthAnchor.constraint(
                equalToConstant: 64
            ),

            iconContainer.heightAnchor.constraint(
                equalToConstant: 64
            ),


            // Icon
            imageView.centerXAnchor.constraint(
                equalTo: iconContainer.centerXAnchor
            ),

            imageView.centerYAnchor.constraint(
                equalTo: iconContainer.centerYAnchor
            ),

            imageView.widthAnchor.constraint(
                equalToConstant: iconSize
            ),

            imageView.heightAnchor.constraint(
                equalToConstant: iconSize
            ),


            // Label
            label.topAnchor.constraint(
                equalTo: iconContainer.bottomAnchor,
                constant: 2
            ),

            label.leadingAnchor.constraint(
                equalTo: card.leadingAnchor,
                constant: 5
            ),

            label.trailingAnchor.constraint(
                equalTo: card.trailingAnchor,
                constant: -5
            ),

            label.bottomAnchor.constraint(
                lessThanOrEqualTo: card.bottomAnchor,
                constant: -8
            )
        ])

        return card
    }
    
    // MARK: - Email Button

    @objc
    private func emailButtonTapped() {
        let vc = EmailAuthViewController()

        vc.onAuthenticationSuccess = { [weak self] in
            self?.delegate?.navigateToHome()
        }

        let nav = UINavigationController(
            rootViewController: vc
        )

        nav.modalPresentationStyle = .pageSheet

        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }

        present(
            nav,
            animated: true
        )
    }
    
    
    
    // MARK: - Google Button
    
    @objc
    private func signInWithGoogleTapped() {
        signInGoogle()
    }
    
    
    // MARK: - Google Sign-In
    //
    // BURASI SENİN ÇALIŞAN SİSTEMİN.
    // MANTIĞINI DEĞİŞTİRMİYORUZ.
    
    private func signInGoogle() {
        
        guard let clientID =
                FirebaseApp.app()?.options.clientID
        else {
            return
        }
        
        let config = GIDConfiguration(
            clientID: clientID
        )
        
        GIDSignIn.sharedInstance.configuration = config
        
        signinWithGoogleButton.isEnabled = false
        
        GIDSignIn.sharedInstance.signIn(
            withPresenting: self
        ) { [weak self] result, error in
            
            guard let self = self else {
                return
            }
            
            if let error = error {
                
                print(
                    "GoogleSignIn error:",
                    error
                )
                
                self.signinWithGoogleButton.isEnabled = true
                
                return
            }
            
            guard
                let user = result?.user,
                let idToken = user.idToken?.tokenString
            else {
                
                self.signinWithGoogleButton.isEnabled = true
                
                return
            }
            
            let credential =
            GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )
            
            Auth.auth().signIn(
                with: credential
            ) { _, error in
                
                self.signinWithGoogleButton.isEnabled = true
                
                if let error = error {
                    
                    print(
                        "Firebase signIn error:",
                        error
                    )
                    
                    return
                }
                
                self.delegate?.navigateToHome()
            }
        }
    }
    
    
    // MARK: - Apple Sign-In

    @objc
    private func appleButtonTapped() {

        let nonce = randomNonceString()
        currentNonce = nonce

        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()

        request.requestedScopes = [
            .fullName,
            .email
        ]

        request.nonce = sha256(nonce)

        let controller = ASAuthorizationController(
            authorizationRequests: [request]
        )

        controller.delegate = self
        controller.presentationContextProvider = self

        appleButton.isEnabled = false

        controller.performRequests()
    }
    
    private func sha256(_ input: String) -> String {

        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)

        return hashedData.map {
            String(format: "%02x", $0)
        }.joined()
    }


    private func randomNonceString(length: Int = 32) -> String {

        precondition(length > 0)

        var randomBytes = [UInt8](
            repeating: 0,
            count: length
        )

        let errorCode = SecRandomCopyBytes(
            kSecRandomDefault,
            randomBytes.count,
            &randomBytes
        )

        if errorCode != errSecSuccess {
            fatalError(
                "Nonce oluşturulamadı. OSStatus: \(errorCode)"
            )
        }

        let charset: [Character] =
            Array(
                "0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._"
            )

        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }

        return String(nonce)
    }
    
}

// MARK: - Apple Authorization

extension LoginViewController:
    ASAuthorizationControllerDelegate,
    ASAuthorizationControllerPresentationContextProviding {

    func presentationAnchor(
        for controller: ASAuthorizationController
    ) -> ASPresentationAnchor {

        return view.window ?? UIWindow()
    }


    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {

        guard
            let appleIDCredential =
                authorization.credential
                as? ASAuthorizationAppleIDCredential
        else {
            appleButton.isEnabled = true
            return
        }

        guard let nonce = currentNonce else {
            appleButton.isEnabled = true
            print("Apple Sign-In: nonce bulunamadı.")
            return
        }

        guard let appleIDToken =
                appleIDCredential.identityToken
        else {
            appleButton.isEnabled = true
            print("Apple Sign-In: identity token alınamadı.")
            return
        }

        guard let idTokenString = String(
            data: appleIDToken,
            encoding: .utf8
        ) else {
            appleButton.isEnabled = true
            print("Apple Sign-In: token String'e çevrilemedi.")
            return
        }

        let credential =
            OAuthProvider.appleCredential(
                withIDToken: idTokenString,
                rawNonce: nonce,
                fullName: appleIDCredential.fullName
            )

        Auth.auth().signIn(
            with: credential
        ) { [weak self] _, error in

            guard let self = self else {
                return
            }

            self.appleButton.isEnabled = true
            self.currentNonce = nil

            if let error = error {
                print(
                    "Firebase Apple Sign-In error:",
                    error.localizedDescription
                )
                return
            }

            print("✅ Apple Sign-In başarılı")

            self.delegate?.navigateToHome()
        }
    }


    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {

        appleButton.isEnabled = true
        currentNonce = nil

        let nsError = error as NSError

        if nsError.code ==
            ASAuthorizationError.canceled.rawValue {

            print("Apple Sign-In kullanıcı tarafından iptal edildi.")

        } else {

            print(
                "Apple Sign-In error:",
                error.localizedDescription
            )
        }
    }
}



// MARK: - LoginDelegate

extension LoginViewController: LoginDelegate {

    func navigateToHome() {

        guard let uid =
                Auth.auth().currentUser?.uid
        else {
            return
        }

        if ProfileStore.shared.fetchProfile(
            uid: uid
        ) != nil {

            routeToMainApp()

            return
        }

        ProfileSyncService.shared.pullProfileIfExists(
            uid: uid
        ) { [weak self] profile in

            guard let self = self else {
                return
            }

            if profile != nil {
                self.routeToMainApp()
            } else {
                self.routeToCreateProfile()
            }
        }
    }


    // MARK: - Routing Helpers

    private func routeToMainApp() {

        if
            let scene = view.window?.windowScene,
            let sceneDelegate =
                scene.delegate as? SceneDelegate
        {

            let tab =
            sceneDelegate.buildMainTabBar()

            sceneDelegate.setRoot(
                tab,
                animated: true
            )

        } else {

            let sb = UIStoryboard(
                name: "ProgramList",
                bundle: nil
            )

            let vc =
            sb.instantiateViewController(
                withIdentifier: "ProgramListVC"
            )

            navigationController?
                .setViewControllers(
                    [vc],
                    animated: true
                )
        }
    }


    private func routeToCreateProfile() {

        let sb = UIStoryboard(
            name: "CreateProfile",
            bundle: nil
        )

//        let vc =
//        sb.instantiateViewController(
//            withIdentifier: "CreateProfileVC"
//        )
        
        let vc = CreateProfileViewController()

        if let nav = navigationController {

            nav.pushViewController(
                vc,
                animated: true
            )

        } else {

            present(
                vc,
                animated: true
            )
        }
    }
}
