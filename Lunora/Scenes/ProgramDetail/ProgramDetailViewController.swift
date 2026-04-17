

import UIKit

enum ProgramDetailSection {
    case text(title: String?, body: String)
    case bullets(title: String, items: [String])
    case details(duration: String, difficulty: String, flexibility: String)
    case badge(title: String, subtitle: String, imageName: String)
}

final class ProgramDetailViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBAction func didTapDetailProgramStartButton(_ sender: UIButton) {
        // ✅ Eğer açılan detail zaten aktif programa aitse
            if activeEnrollment?.programId == program.id {
                showSimpleAlert(
                    title: "Bu program zaten aktif",
                    message: "Şu anda devam ettiğin program bu."
                )
                return
            }

            // ✅ Eğer başka bir aktif program varsa
            if activeEnrollment != nil {
                showSimpleAlert(
                    title: "Zaten aktif programın var",
                    message: "Yeni bir programa başlamak için mevcut programını tamamlamalısın."
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

                let userId = "testUser"

                self.enrollmentRepository.startProgram(userId: userId, programId: self.program.id) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let enrollmentId):
                            print("✅ Detail program başladı:", enrollmentId)
                            self.fetchActiveEnrollmentDetails()

                        case .failure(let error):
                            if let customError = error as? EnrollmentStartError,
                               customError == .alreadyHasActiveProgram {
                                self.showSimpleAlert(
                                    title: "Zaten aktif programın var",
                                    message: "Yeni bir programa başlamak için mevcut programını tamamlamalısın."
                                )
                            } else {
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
    
    func showSimpleAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
    // MARK: - Data
    var program: Program!   // ProgramList’ten push/segue ile set edilecek
    private var sections: [ProgramDetailSection] = []
    private let enrollmentRepository = EnrollmentRepository()
    private var activeEnrollment: ActiveEnrollment?
    
    

        override func viewDidLoad() {
            super.viewDidLoad()

            titleLabel.text = program?.name
            self.hidesBottomBarWhenPushed = true

            setupTableView()
            buildSections()
            fetchActiveEnrollmentDetails()
        }
    
    private func fetchActiveEnrollmentDetails() {
        let userId = "testUser"

        enrollmentRepository.fetchActiveEnrollment(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                switch result {
                case .success(let enrollment):
                    self.activeEnrollment = enrollment

                    if let enrollment = enrollment {
                        print("🟢 Detail aktif enrollment bulundu")
                        print("🟢 Detail enrollmentId:", enrollment.enrollmentId)
                        print("🟢 Detail programId:", enrollment.programId)

                        // 🔥 YENİ EKLENEN KISIM
                        self.enrollmentRepository.getOrCreateTodayLog(
                            userId: userId,
                            enrollment: enrollment
                        ) { result in
                            DispatchQueue.main.async {
                                switch result {
                                case .success(let dailyLog):
                                    print("✅ Bugünün daily log'u hazır")
                                    print("✅ logId:", dailyLog.logId)
                                    print("✅ dateKey:", dailyLog.dateKey)
                                    print("✅ dayNumber:", dailyLog.dayNumber)
                                    print("✅ completedTaskIds:", dailyLog.completedTaskIds)

                                case .failure(let error):
                                    print("🔴 DailyLog alınamadı/oluşturulamadı:", error.localizedDescription)
                                }
                            }
                        }

                    } else {
                        print("🟡 Detail aktif enrollment yok")
                    }

                case .failure(let error):
                    print("🔴 Detail aktif enrollment okunamadı:", error.localizedDescription)
                }
            }
        }
    }

        private func setupTableView() {
            tableView.delegate = self
            tableView.dataSource = self
            
            tableView.register(TextCardCell.self, forCellReuseIdentifier: "TextCardCell")
            tableView.register(BulletCardCell.self, forCellReuseIdentifier: "BulletCardCell")
            tableView.register(DetailsCardCell.self, forCellReuseIdentifier: "DetailsCardCell")
            tableView.register(BadgeRewardCell.self, forCellReuseIdentifier: "BadgeRewardCell")
            
            tableView.separatorStyle = .none
            tableView.backgroundColor = .clear
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 150
        }

        private func buildSections() {
            sections.removeAll()
            
            sections.append(.details(
                duration: program.durationText,
                difficulty: "\(program.difficultyLevel) / \(program.difficultyScale)",
                flexibility: program.elements
//                flexibility:"AKASHA ENERGY"
            ))
            
            // EKLEDİM: Rozet kutucuğu
            sections.append(.badge(
                title: "Tamamladığında Kazanacağın Rozet",
                subtitle: program.badgeDescription,
                imageName: program.badgeImageName ?? program.imageName
            ))

            let summary = program.oneSentenceSummary.trimmingCharacters(in: .whitespacesAndNewlines)
            if !summary.isEmpty {
                sections.append(.text(title: nil, body: summary))
            }

            let problems = program.coreProblems.filter {
                !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
            if !problems.isEmpty {
                sections.append(.bullets(
                    title: "💡 Eğer bu problemlere sahipsen doğru programı seçtin",
                    items: problems
                ))
            }

            for item in program.fullText {
                
                let text = item.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !text.isEmpty else { continue }

                // metni satırlara ayır
                let parts = text.components(separatedBy: "\n")

                let title = parts.first
                let body = parts.dropFirst().joined(separator: "\n")

                sections.append(.text(
                    title: title,
                    body: body
                ))
            }
            tableView.reloadData()
        }
    }
 
extension ProgramDetailViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let item = sections[indexPath.row]

        switch item {
        case .text(let title, let body):
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextCardCell", for: indexPath) as! TextCardCell
            cell.configure(title: title, body: body)
            return cell

        case .bullets(let title, let items):
            let cell = tableView.dequeueReusableCell(withIdentifier: "BulletCardCell", for: indexPath) as! BulletCardCell
            cell.configure(title: title, bullets: items)
            return cell

        case .details(let duration, let difficulty, let flexibility):
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailsCardCell", for: indexPath) as! DetailsCardCell
            cell.configure(duration: duration, difficulty: difficulty, flexibility: flexibility)
            return cell
        case .badge(title: let title, subtitle: let subtitle, imageName: let imageName):
            let cell = tableView.dequeueReusableCell(withIdentifier: "BadgeRewardCell", for: indexPath) as! BadgeRewardCell
            cell.configure(title: title, subtitle: subtitle, imageName: imageName)
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension ProgramDetailViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
