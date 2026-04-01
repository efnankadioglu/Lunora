//
//  CreateProfileViewController.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 29.10.2025.
//

import UIKit
import TOCropViewController
import FirebaseAuth

class CreateProfileViewController: UIViewController,
                                   UIImagePickerControllerDelegate,
                                   UINavigationControllerDelegate,
                                   TOCropViewControllerDelegate  {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var motivationTextField: UITextField!
    
    // MARK: - Private
        private let imagePicker = UIImagePickerController()
        private var selectedImage: UIImage?
        private var hasCustomAvatar = false

        // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()

            // Image Picker
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false // kırpma işini biz yapıyoruz (TOCrop)

            // Avatar görünümü
            avatarImageView.contentMode = .scaleAspectFill
            avatarImageView.clipsToBounds = true
            avatarImageView.layer.borderWidth = 0
            avatarImageView.layer.borderColor = UIColor.clear.cgColor
        }

        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            // Kare imageView'i daire yap
            avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2
        }

        // MARK: - Actions
        @IBAction func addPhotoButtonTapped(_ sender: UIButton) {
            present(imagePicker, animated: true, completion: nil)
        }

    @IBAction func saveAndContinueButtonTapped(_ sender: Any) {
        let name = (nameTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let username = (usernameTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let motivation = (motivationTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        // UI: işlem süresince tekrar tıklamayı önle
        view.isUserInteractionEnabled = false
        defer { view.isUserInteractionEnabled = true }
        
        // 0) Zorunlu alanlar
        guard !name.isEmpty else {
            showAlert(title: "Name Required", message: "Please enter your name.")
            nameTextField.becomeFirstResponder()
            return
        }
        guard !username.isEmpty else {
            showAlert(title: "Username Required",
                      message: "Please choose a username (3–20 letters or numbers).")
            usernameTextField.becomeFirstResponder()
            return
        }
        
        // 1) Username formatı
        guard isValidUsername(username) else {
            showAlert(title: "Invalid Username",
                      message: "Username must be 3–20 characters and contain only letters and numbers.")
            usernameTextField.becomeFirstResponder()
            return
        }
        
        // 2) Aktif kullanıcı
        guard let uid = Auth.auth().currentUser?.uid else {
            showAlert(title: "Oops", message: "User session not found.")
            return
        }
        
        // 3) Benzersizlik (kendi kaydını hariç tut)
        guard ProfileStore.shared.isUsernameAvailable(username, excluding: uid) else {
            showAlert(title: "Username Taken",
                      message: "This username is already in use. Please choose another one.")
            usernameTextField.becomeFirstResponder()
            return
        }
        
        // 4) Yerel kaydet (avatar seçilmediyse store defaultAvatar kullanır)
        let avatar = hasCustomAvatar ? avatarImageView.image : nil
        do {
            _ = try ProfileStore.shared.saveProfile(
                uid: uid,
                name: name,
                username: username,
                motivation: motivation,
                avatar: avatar
            )
        } catch {
            showAlert(title: "Error",
                      message: "Your profile could not be saved. Please try again.")
            return
        }
        
        // 4.5) Uzağa senkronizasyon (async; başarısızlık navigasyonu engellemez)
        ProfileSyncService.shared.pushProfileToRemote(
            uid: uid,
            name: name,
            username: username,
            motivation: motivation,
            avatar: avatar
        ) { [weak self] err in
            DispatchQueue.main.async {
                if let err = err {
                    print("Remote push error:", err)
                    // Hata varsa kullanıcıya gösterelim ki neden gitmediğini anlasın
                    self?.showAlert(title: "Sync Error", message: "Photo could not be uploaded, but profile saved locally.")
                    self?.view.isUserInteractionEnabled = true // Butonu tekrar aktif et
                } else {
                    print("Firebase kaydı ve fotoğraf yüklemesi başarılı! ✅")
                    // SADECE BAŞARILIYSA veya HATA YÖNETİMİNDEN SONRA SAYFA DEĞİŞTİR
                    self?.routeToProgramList()
                }
            }

        }
    }
                
                private func routeToProgramList() {
                    // Önce tab bar’ı root yapmayı dene (SceneDelegate üzerinden)      // ?????
                    if                                                                // ?????
                        let scene = view.window?.windowScene,                         // ?????
                        let sceneDelegate = scene.delegate as? SceneDelegate          // ?????
                    {                                                                 // ?????
                        let tab = sceneDelegate.buildMainTabBar()                     // ?????
                        sceneDelegate.setRoot(tab, animated: true)                    // ?????
                        return                                                        // ?????
                    }

                    // Fallback: Her ihtimale karşı sadece ProgramList ekranını aç
                    let sb = UIStoryboard(name: "ProgramList", bundle: nil)
                    let vc = sb.instantiateViewController(withIdentifier: "ProgramListVC")

                    if let nav = self.navigationController {
                        // Geri butonunu engellemek için stack’i tek ekrana indir.
                        nav.setViewControllers([vc], animated: true)
                    } else {
                        // Bu VC bir NavigationController içinde değilse fallback olarak modal aç.
                        present(vc, animated: true)
                    }
                }

                // MARK: - Validation
                private func isValidUsername(_ username: String) -> Bool {
                    guard !username.isEmpty else { return false }
                    let regex = "^[A-Za-z0-9]{3,20}$"
                    let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
                    return predicate.evaluate(with: username)
                }

                // MARK: - Alerts
                private func showAlert(title: String, message: String) {
                    let alert = UIAlertController(title: title,
                                                  message: message,
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    present(alert, animated: true, completion: nil)
                }

                // MARK: - UIImagePickerControllerDelegate
                func imagePickerController(_ picker: UIImagePickerController,
                                           didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

                    if let image = info[.originalImage] as? UIImage {
                        selectedImage = image
                    }

                    picker.dismiss(animated: true) { [weak self] in
                        guard let self = self, let selectedImage = self.selectedImage else { return }

                        let cropVC = TOCropViewController(croppingStyle: .circular, image: selectedImage)
                        cropVC.delegate = self
                        cropVC.title = "Adjust your photo"
                        self.present(cropVC, animated: true, completion: nil)
                    }
                }

                func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                    picker.dismiss(animated: true, completion: nil)
                }

                // MARK: - TOCropViewControllerDelegate
                func cropViewController(_ cropViewController: TOCropViewController,
                                        didFinishCancelled cancelled: Bool) {
                    cropViewController.dismiss(animated: true, completion: nil)
                }

                func cropViewController(_ cropViewController: TOCropViewController,
                                        didCropToCircularImage image: UIImage,
                                        with cropRect: CGRect,
                                        angle: Int) {

                    avatarImageView.image = image
                    avatarImageView.layer.borderWidth = 3
                    avatarImageView.layer.borderColor = UIColor.white.cgColor
                    hasCustomAvatar = true
                    selectedImage = nil

                    cropViewController.dismiss(animated: true, completion: nil)
                }
            }
