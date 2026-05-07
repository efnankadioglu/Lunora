//
//  ProgramListViewController.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 28.10.2025.
//

import UIKit
import FirebaseDatabase
import FirebaseFirestore
import FirebaseAuth

class ProgramListViewController: UIViewController {
    
    @IBOutlet weak var astrologyCard: UIView!
    @IBOutlet weak var programsCardView: UIView!
    @IBOutlet weak var programsTableView: UITableView!
    
    @IBOutlet weak var mercuryRetrogradeView: UIButton!
    @IBOutlet weak var venusRetrogradeView: UIButton!
    @IBOutlet weak var marsRetrogradeView: UIButton!
    @IBOutlet weak var saturnRetrogradeView: UIButton!
    @IBOutlet weak var newMoonView: UIButton!
    @IBOutlet weak var fullMoonView: UIButton!
    @IBOutlet weak var lunarEclipseView: UIButton!
    @IBOutlet weak var solarEclipseView: UIButton!
    
    @IBOutlet weak var moonSignLabel: UILabel!
    @IBOutlet weak var suitabilityProgressView: UIProgressView!
    @IBOutlet weak var suitabilityLabel: UILabel!
    
    private let enrollmentRepository = EnrollmentRepository()
    private var activeEnrollment: ActiveEnrollment?
    private var todaySkyData: DailyAstrology?
    
    private var programs: [Program] = []
        private var tooltipView: UIView?
        private let programService = ProgramService.shared
        let uploader = AstrologyFirestoreUploader()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            print(">>> viewDidLoad çalıştı")
            setupUI()
            setupTableView()
            setupAstrologyCardTap()
            fetchTodayAstrology()
            fetchProgramsFromSource()
            fetchActiveEnrollmentDetails()
            
            ProgramMigrationService.shared.uploadAllProgramsFromLocalJSON { result in
                switch result {
                case .success:
                    print("✅ Tüm programlar Firestore'a yüklendi")
                case .failure(let error):
                    print("❌ Migration hatası: \(error.localizedDescription)")
                }
            }
            
            EarnedBadgeService.shared.fetchEarnedBadges { result in
                print(">>> fetchEarnedBadges callback geldi")

                switch result {
                case .success(let badges):
                    print(">>> Kazanılan rozetler:", badges)
                case .failure(let error):
                    print(">>> Rozetler çekilemedi:", error.localizedDescription)
                }
            }
           
        }
    
    
    private func checkActiveEnrollment() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("🔴 ProgramList: userId yok")
            return
        }

        enrollmentRepository.fetchActiveEnrollmentId(userId: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let activeEnrollmentId):
                    print("🟢 activeEnrollmentId:", activeEnrollmentId ?? "nil")

                case .failure(let error):
                    print("🔴 active enrollment okunamadı:", error.localizedDescription)
                }
            }
        }
    }
    
    private func fetchActiveEnrollmentDetails() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("🔴 ProgramList: userId yok")
            self.activeEnrollment = nil
            self.programsTableView.reloadData()
            return
        }

        enrollmentRepository.fetchActiveEnrollment(userId: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let enrollment):
                    self.activeEnrollment = enrollment

                    if let enrollment = enrollment {
                        print("🟢 aktif enrollment bulundu")
                        print("🟢 enrollmentId:", enrollment.enrollmentId)
                        print("🟢 programId:", enrollment.programId)
                        print("🟢 status:", enrollment.status)
                        print("🟢 currentDay:", enrollment.currentDay)
                        print("🟢 completedDaysCount:", enrollment.completedDaysCount)
                        print("🟢 isCompleted:", enrollment.isCompleted)
                        print("🟢 isFailed:", enrollment.isFailed)
                    } else {
                        print("🟡 aktif enrollment yok")
                    }

                    self.programsTableView.reloadData()

                case .failure(let error):
                    print("🔴 aktif enrollment detayları okunamadı:", error.localizedDescription)
                    self.activeEnrollment = nil
                    self.programsTableView.reloadData()
                }
            }
        }
    }
    
    
        
        // MARK: - Hibrit veri çekme
        private func fetchProgramsFromSource() {
            programService.fetchPrograms { [weak self] firestorePrograms in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    if firestorePrograms.isEmpty {
                        print("⚠️ Firestore boş/hatalı, JSON kullanılacak")
                        self.programs = ProgramLoader.loadPrograms()
                    } else {
                        print("🔥 Firestore verisi kullanılıyor")
                        self.programs = firestorePrograms
                    }
                    
                    print(">>> Ekrana basılan program sayısı: \(self.programs.count)")
                    self.programsTableView.reloadData()
                }
            }
        }
        
        func testFirebaseConnection() {
            let ref = Database.database().reference()
            
            ref.child("test_mesaji").setValue("Selam Efnan! Bağlantı başarılı 🚀") { error, _ in
                if let error = error {
                    print("Eyvah! Veri gönderilemedi: \(error.localizedDescription)")
                } else {
                    print("Yaşasın! Veri başarıyla Firebase'e uçtu.")
                }
            }
        }
        
        private func setupUI() {
            applyCardStyle(to: astrologyCard)
            applyCardStyle(to: programsCardView)
        }
    private func setupAstrologyCardTap() {
        astrologyCard.isUserInteractionEnabled = true

        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapAstrologyCard)
        )

        astrologyCard.addGestureRecognizer(tapGesture)
    }
    @objc private func didTapAstrologyCard() {
        guard let todaySkyData = todaySkyData else {
            showSimpleAlert(
                title: "Gökyüzü bilgisi hazır değil",
                message: "Bugünün astroloji verisi henüz yüklenmedi."
            )
            return
        }

        let displayData = DailySkyService.shared.makeDisplayData(from: todaySkyData)

        let vc = DailySkyViewController(displayData: displayData)
        vc.hidesBottomBarWhenPushed = true

        if let navigationController = navigationController {
            navigationController.pushViewController(vc, animated: true)
        } else {
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
    
        
        private func setupTableView() {
            programsTableView.delegate = self
            programsTableView.dataSource = self
            
            print(">>> tableView bağlandı")
            
            programsTableView.separatorStyle = .none
            programsTableView.backgroundColor = .clear
            programsTableView.rowHeight = 220
            programsTableView.showsVerticalScrollIndicator = false
            
            programsTableView.register(
                UINib(nibName: "ProgramTableViewCell", bundle: nil),
                forCellReuseIdentifier: "ProgramTableViewCell"
            )
        }
        
        private func loadPrograms() {
            programs = ProgramLoader.loadPrograms()
            programsTableView.reloadData()
        }
        
        private func fetchTodayAstrology() {
            let db = Firestore.firestore()
            let today = getTodayDateString()

            db.collection("sky_days").document(today).getDocument { snapshot, error in
                if let error = error {
                    print("Firestore hata:", error.localizedDescription)
                    return
                }

                guard let data = snapshot?.data() else {
                    print("Veri yok")
                    return
                }

                print("Gelen veri:", data)

                DispatchQueue.main.async {
                    self.updateAstrologyUI(data: data)
                }
            }
        }

        private func getTodayDateString() -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.string(from: Date())
        }
        
        private func updateAstrologyUI(data: [String: Any]) {
            let moonSign = data["moon_sign"] as? String ?? "Ay Burcu"
            let events = data["celestial_events"] as? [String] ?? []
            let score = data["suitability_score"] as? Int ?? 0
            let date = data["date"] as? String ?? ""

            moonSignLabel.text = "🌕 \(moonSign)"
            suitabilityProgressView.progress = Float(score) / 10.0

            let percentage = generateStablePercentage(score: score, date: date)
            suitabilityLabel.text = "Bugünün enerjisi %\(percentage) seninle"

            updateEventButtons(events: events)
        }
        
        private func generateStablePercentage(score: Int, date: String) -> Int {
            let base = score * 10
            let hash = abs(date.hashValue)
            let offset = (hash % 9) - 4
            let result = base + offset
            return max(0, min(100, result))
        }
        
        private func updateEventButtons(events: [String]) {
            let lowercased = events.map { $0.lowercased() }
            
            mercuryRetrogradeView.isHidden = !lowercased.contains { $0.contains("merkür retrosu") }
            venusRetrogradeView.isHidden = !lowercased.contains { $0.contains("venüs retrosu") }
            marsRetrogradeView.isHidden = !lowercased.contains { $0.contains("mars retrosu") }
            saturnRetrogradeView.isHidden = !lowercased.contains { $0.contains("satürn retrosu") }
            
            newMoonView.isHidden = !lowercased.contains { $0.contains("yeni ay") }
            fullMoonView.isHidden = !lowercased.contains { $0.contains("dolunay") }
            lunarEclipseView.isHidden = !lowercased.contains { $0.contains("ay tutulması") }
            solarEclipseView.isHidden = !lowercased.contains { $0.contains("güneş tutulması") }
        }
        
        private func showTooltip(from button: UIButton, text: String) {
            tooltipView?.removeFromSuperview()
            
            let containerView = UIView()
            containerView.translatesAutoresizingMaskIntoConstraints = false
            containerView.layer.shadowColor = UIColor.black.cgColor
            containerView.layer.shadowOpacity = 0.1
            containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
            containerView.layer.shadowRadius = 8
            
            let tooltip = UIView()
            tooltip.backgroundColor = tooltipColor(for: button)
            tooltip.layer.cornerRadius = 12
            tooltip.clipsToBounds = true
            tooltip.translatesAutoresizingMaskIntoConstraints = false
            
            let label = UILabel()
            label.text = text
            label.textColor = .white
            label.font = UIFont.systemFont(ofSize: 14)
            label.numberOfLines = 0
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            
            tooltip.addSubview(label)
            containerView.addSubview(tooltip)
            self.view.addSubview(containerView)
            
            NSLayoutConstraint.activate([
                containerView.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 8),
                containerView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
                containerView.widthAnchor.constraint(lessThanOrEqualToConstant: 220),
                
                tooltip.topAnchor.constraint(equalTo: containerView.topAnchor),
                tooltip.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
                tooltip.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                tooltip.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                
                label.topAnchor.constraint(equalTo: tooltip.topAnchor, constant: 10),
                label.bottomAnchor.constraint(equalTo: tooltip.bottomAnchor, constant: -10),
                label.leadingAnchor.constraint(equalTo: tooltip.leadingAnchor, constant: 10),
                label.trailingAnchor.constraint(equalTo: tooltip.trailingAnchor, constant: -10)
            ])
            
            containerView.alpha = 0
            UIView.animate(withDuration: 0.2) {
                containerView.alpha = 1
            }
            
            tooltipView = containerView
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleOutsideTap))
            tap.cancelsTouchesInView = false
            self.view.addGestureRecognizer(tap)
        }
        
        @objc private func handleOutsideTap(_ gesture: UITapGestureRecognizer) {
            let location = gesture.location(in: self.view)
            
            if let tooltip = tooltipView, !tooltip.frame.contains(location) {
                hideTooltip()
            }
        }
        
        private func hideTooltip() {
            UIView.animate(withDuration: 0.3, animations: {
                self.tooltipView?.alpha = 0
            }) { _ in
                self.tooltipView?.removeFromSuperview()
                self.tooltipView = nil
            }
        }
        
        private func tooltipColor(for button: UIButton) -> UIColor {
            switch button {
            case mercuryRetrogradeView:
                return UIColor.astroMercuryColor
            case venusRetrogradeView:
                return UIColor.astroVenusColor
            case marsRetrogradeView:
                return UIColor.astroMarsColor
            case saturnRetrogradeView:
                return UIColor.astroSaturnColor
            case newMoonView:
                return UIColor.astroNewMoonColor
            case fullMoonView:
                return UIColor.astroFullMoonColor
            case lunarEclipseView:
                return UIColor.astroLunarEclipseColor
            case solarEclipseView:
                return UIColor.astroSolarEclipseColor
            default:
                return .black
            }
        }
    
    
    @IBAction func mercuryRetrogradeViewTapped(_ sender: UIButton) {
        showTooltip(from: sender, text: "İletişimde yavaşla. Hızlı cevap vermek yerine anlamayı seç. Eski konular geri gelirse çözmek için fırsattır. Yaz, düşün, gözlemle. Netlik dışarıda değil, içeride oluşur.")
        
    }
    @IBAction func venusRetrogradeViewTapped(_ sender: UIButton) {
        showTooltip(from: sender, text: "Kalbine dön. İlişkilerde neyi hak ettiğini fark et. Sevgi verirken kendini unutup unutmadığını gözlemle. Eski duygular çıkıyorsa bastırma, dönüştür.")
    }
    @IBAction func marsRetrogradeViewTapped(_ sender: UIButton) {
        showTooltip(from: sender, text: "Harekete geçmeden önce niyetini sorgula. Öfke ve sabırsızlık aslında bastırılmış enerjidir. Gücünü dışarıya değil, iç disipline yönlendir.")
    }
    @IBAction func saturnRetrogradeViewTapped(_ sender: UIButton) {
        showTooltip(from: sender, text: "Hayat sana aynayı tutar. Kaçtığın sorumluluklar görünür olur. Disiplin kur, küçük ama sürdürülebilir adımlar at. Sabır burada en büyük dönüşüm aracıdır.")
    }
    @IBAction func newMoonViewTapped(_ sender: UIButton) {
        showTooltip(from: sender, text: "Yeni bir niyet ek. Küçük bir başlangıç yap. Her şey hemen olmak zorunda değil. Tohum ektiğini hatırla, sürece güven.")
    }
    @IBAction func fullMoonViewTapped(_ sender: UIButton) {
        showTooltip(from: sender, text: "Tamamlanma ve bırakma zamanı. Artık sana hizmet etmeyenleri sevgiyle bırak. Duygular yoğunlaşır; bastırmak yerine fark et ve serbest bırak.")
    }
    @IBAction func lunarEclipseViewTapped(_ sender: UIButton) {
        showTooltip(from: sender, text: "Duygusal farkındalık artar. Ani fark edişler olabilir. Kontrol etmeye çalışma, sadece gözlemle. İçsel dönüşüm derinleşir.")
    }
    
    @IBAction func solarEclipseViewTapped(_ sender: UIButton) {
        showTooltip(from: sender, text: "Hayat yön değiştirir. Yeni bir kapı açılır. Direnmek yerine akışa güven. Kim olduğunu yeniden tanımlama fırsatıdır.")
    }
    
    private func applyCardStyle(
        to view: UIView,
        cornerRadius: CGFloat = 24,
        shadowOpacity: Float = 0.08,
        shadowRadius: CGFloat = 16,
        shadowOffset: CGSize = CGSize(width: 0, height: 6)
    ) {
        view.layer.cornerRadius = cornerRadius
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = shadowOpacity
        view.layer.shadowRadius = shadowRadius
        view.layer.shadowOffset = shadowOffset
        
        DispatchQueue.main.async {
            let path = UIBezierPath(roundedRect: view.bounds, cornerRadius: cornerRadius)
            view.layer.shadowPath = path.cgPath
        }
    }
}

extension ProgramListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        print(">>> numberOfRows çalıştı")
        return programs.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ProgramTableViewCell",
            for: indexPath
        ) as! ProgramTableViewCell
        
        let program = programs[indexPath.section]
        
        cell.configure(with: program)
        
        let isActiveProgram = (activeEnrollment?.programId == program.id)
        cell.applyStartButtonState(isActiveProgram: isActiveProgram)

        cell.onTapStartButton = { [weak self] in
            guard let self = self else { return }
            if isActiveProgram {
                self.showSimpleAlert(
                    title: "Bu program zaten aktif",
                    message: "Şu anda devam ettiğin program bu."
                )
                return
            }

            let popup = ConfirmationPopupView()

            popup.titleText = "Hazır mısın?"
            popup.messageText = "Bu yolculuk seni değiştirebilir.\nBaşlamak ister misin? ✨"
            popup.cancelTitle = "Vazgeç"
            popup.confirmTitle = "Başla"

            popup.onCancel = {
                print("❌ Vazgeçildi")
            }

            popup.onConfirm = { [weak self] in
                guard let self = self else { return }

                let repo = EnrollmentRepository()

                guard let userId = Auth.auth().currentUser?.uid else {
                    self.showSimpleAlert(
                        title: "Hata",
                        message: "Kullanıcı oturumu bulunamadı."
                    )
                    return
                }

                repo.startProgram(userId: userId, programId: program.id) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let enrollmentId):
                            print("✅ Program başladı:", enrollmentId)

                            UserDefaults.standard.set(true, forKey: "shouldOpenProgressTodayTab")

                            self.fetchActiveEnrollmentDetails()
                            self.tabBarController?.selectedIndex = 1

                        case .failure(let error):

                            if let customError = error as? EnrollmentStartError,
                               customError == .alreadyHasActiveProgram {

                                print("⚠️ Zaten aktif program var")

                                self.showSimpleAlert(
                                    title: "Zaten aktif programın var",
                                    message: "Yeni bir programa başlamak için mevcut programını tamamlamalısın."
                                )

                            } else {
                                print("❌ Hata:", error.localizedDescription)

                                self.showSimpleAlert(
                                    title: "Hata",
                                    message: error.localizedDescription
                                )
                            }
                        }
                    }
                }
            }

            popup.present(in: self.view)
        }
        
        return cell
    }
    
    
    func showSimpleAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("✅ didSelect çalıştı: \(indexPath.row)")
        print("nav var mı:", navigationController != nil)
        
        let selectedProgram = programs[indexPath.section]
        print("Seçilen program:", selectedProgram.name)
        
        let storyboard = UIStoryboard(name: "ProgramDetail", bundle: nil)
        
        if let vc = storyboard.instantiateViewController(
            withIdentifier: "ProgramDetailViewController"
        ) as? ProgramDetailViewController {
            
            vc.program = selectedProgram
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
extension UIColor {
    
    static let astroMercuryColor = UIColor(red: 170/255, green: 195/255, blue: 185/255, alpha: 0.8)
    
    static let astroVenusColor = UIColor(red: 236/255, green: 191/255, blue: 234/255, alpha: 0.8)
    
    static let astroMarsColor = UIColor(red: 240/255, green: 115/255, blue: 115/255, alpha: 0.8)
    
    static let astroSaturnColor = UIColor(red: 158/255, green: 112/255, blue: 112/255, alpha: 0.8)
    
    static let astroNewMoonColor = UIColor(red: 188/255, green: 131/255, blue: 252/255,alpha: 0.8)
    
    static let astroFullMoonColor = UIColor(red: 222/255, green: 195/255, blue: 100/255, alpha: 0.8)
    
    static let astroLunarEclipseColor = UIColor(red: 98/255, green: 85/255, blue: 163/255, alpha: 0.8)
    
    static let astroSolarEclipseColor = UIColor(red: 227/255, green: 121/255, blue: 86/255, alpha: 0.8)
}
