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

class LoginViewController: UIViewController {

    @IBOutlet weak var signinWithGoogleButton: UIButton!
    
//    @IBOutlet weak var signinWithGoogleButton: UIButton!
    
//    @IBOutlet weak var signinWithGoogleButton: UIButton!
    private weak var delegate: LoginDelegate?

    override func viewDidLoad() {
           super.viewDidLoad()
           delegate = self
       }
    
    @IBAction func signInWithGoogleTapped(_ sender: Any) {
        signInGoogle( )
    }
    
    // MARK: - Google Sign-In
       private func signInGoogle() {
           guard let clientID = FirebaseApp.app()?.options.clientID else { return }

           let config = GIDConfiguration(clientID: clientID)
           GIDSignIn.sharedInstance.configuration = config

           signinWithGoogleButton.isEnabled = false

           GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
               guard let self = self else { return }

               if let error = error {
                   print("GoogleSignIn error:", error)
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

               let credential = GoogleAuthProvider.credential(
                   withIDToken: idToken,
                   accessToken: user.accessToken.tokenString
               )

               Auth.auth().signIn(with: credential) { _, error in
                   self.signinWithGoogleButton.isEnabled = true

                   if let error = error {
                       print("Firebase signIn error:", error)
                       return
                   }

                   // Login başarıyla bitti → senaryolara göre yönlendir
                   self.delegate?.navigateToHome()
               }
           }
       }
   }

   // MARK: - LoginDelegate
   extension LoginViewController: LoginDelegate {

       func navigateToHome() {
           guard let uid = Auth.auth().currentUser?.uid else { return }

           // 1) Hızlı yol: Local Core Data'da profil varsa direkt ana uygulama
           if ProfileStore.shared.fetchProfile(uid: uid) != nil {
               routeToMainApp()
               return
           }

           // 2) Local yoksa: uzaktan profili çekmeyi dene
           ProfileSyncService.shared.pullProfileIfExists(uid: uid) { [weak self] profile in
               guard let self = self else { return }

               if profile != nil {
                   // Firestore’dan geldi ve Core Data’ya yazıldı → ana uygulama
                   self.routeToMainApp()
               } else {
                   // Uzakta da profil yok → yeni kullanıcı → CreateProfile
                   self.routeToCreateProfile()
               }
           }
       }

       // MARK: - Routing helpers

       /// Ana uygulamaya (tab bar) geçiş
       private func routeToMainApp() {
           // SceneDelegate üzerinden root’u tab bar yapıyoruz
           if
               let scene = view.window?.windowScene,
               let sceneDelegate = scene.delegate as? SceneDelegate
           {
               let tab = sceneDelegate.buildMainTabBar()
               sceneDelegate.setRoot(tab, animated: true)
           } else {
               // Fallback: sadece ProgramList aç (her ihtimale karşı)
               let sb = UIStoryboard(name: "ProgramList", bundle: nil)
               let vc = sb.instantiateViewController(withIdentifier: "ProgramListVC")
               navigationController?.setViewControllers([vc], animated: true)
           }
       }

       /// Profil oluşturma ekranına geçiş
       private func routeToCreateProfile() {
           let sb = UIStoryboard(name: "CreateProfile", bundle: nil)
           let vc = sb.instantiateViewController(withIdentifier: "CreateProfileVC")

           if let nav = navigationController {
               nav.pushViewController(vc, animated: true)
           } else {
               present(vc, animated: true)
           }
       }
   }
