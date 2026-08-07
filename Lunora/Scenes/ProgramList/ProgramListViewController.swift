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

final class ProgramListViewController: UIViewController {

    // MARK: - Main Layout

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let mainContentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Astrology Card

    private let astrologyCard: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        view.backgroundColor = UIColor(
            red: 235 / 255,
            green: 199 / 255,
            blue: 250 / 255,
            alpha: 1
        )

        view.layer.cornerRadius = 28
        view.layer.masksToBounds = true

        return view
    }()

    private let astrologyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false

        imageView.image = UIImage(named: "horoscope")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear

        return imageView
    }()

    private let moonSignLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false

        label.text = "🌕 Ay"
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.textColor = .black
        label.numberOfLines = 1

        return label
    }()

    private let suitabilityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false

        label.text = "Bugünün enerjisi seninle"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor.label.withAlphaComponent(0.58)
        label.numberOfLines = 2

        return label
    }()

    private let suitabilityProgressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false

        progressView.progressTintColor = UIColor(
            red: 247 / 255,
            green: 53 / 255,
            blue: 151 / 255,
            alpha: 1
        )

        progressView.trackTintColor = UIColor(
            red: 218 / 255,
            green: 190 / 255,
            blue: 222 / 255,
            alpha: 1
        )

        progressView.layer.cornerRadius = 3
        progressView.clipsToBounds = true

        return progressView
    }()

    // MARK: - Astrology Events

    private lazy var mercuryRetrogradeView =
        makeEventButton(title: "☿ Merkür Retrosu")

    private lazy var venusRetrogradeView =
        makeEventButton(title: "♀ Venüs Retrosu")

    private lazy var marsRetrogradeView =
        makeEventButton(title: "♂ Mars Retrosu")

    private lazy var saturnRetrogradeView =
        makeEventButton(title: "♄ Satürn Retrosu")

    private lazy var newMoonView =
        makeEventButton(title: "☾ Yeni Ay")

    private lazy var fullMoonView =
        makeEventButton(title: "● Dolunay")

    private lazy var lunarEclipseView =
        makeEventButton(title: "☾ Ay Tutulması")

    private lazy var solarEclipseView =
        makeEventButton(title: "☀ Güneş Tutulması")

    private let eventScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = false

        return scrollView
    }()

    private let eventStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false

        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 8

        return stackView
    }()

    // MARK: - Programs Area

    private let programsTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false

        label.text = "Sana iyi gelecek\nprogramı seç ✨"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = UIColor.label.withAlphaComponent(0.78)
        label.numberOfLines = 2

        return label
    }()

    private let programsCardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()

    private let programsTableView: UITableView = {
        let tableView = UITableView(
            frame: .zero,
            style: .plain
        )

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false

        // Dışarıda UIScrollView bulunduğu için table kendi kaymayacak.
        tableView.isScrollEnabled = false

        return tableView
    }()

    private var programsTableHeightConstraint: NSLayoutConstraint?

    // MARK: - Data

    private let enrollmentRepository = EnrollmentRepository()
    private let programService = ProgramService.shared

    private var activeEnrollment: ActiveEnrollment?
    private var todaySkyData: DailyAstrology?
    private var programs: [Program] = []

    let uploader = AstrologyFirestoreUploader()

    // MARK: - Init

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError(
            "ProgramListViewController storyboard ile oluşturulmamalıdır."
        )
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupHierarchy()
        setupConstraints()

        setupTableView()
        setupAstrologyCardTap()
        setupEventButtonActions()

        fetchTodayAstrology()
        fetchProgramsFromSource()
        fetchActiveEnrollmentDetails()

        EarnedBadgeService.shared.fetchEarnedBadges { result in
            switch result {

            case .success(let badges):
                print(">>> Kazanılan rozetler:", badges)

            case .failure(let error):
                print(
                    ">>> Rozetler çekilemedi:",
                    error.localizedDescription
                )
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateProgramsTableHeight()
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

            self.programsTableView.setNeedsLayout()
            self.programsTableView.layoutIfNeeded()

            self.updateProgramsTableHeight()

            self.programsTableView.setNeedsLayout()
            self.programsTableView.layoutIfNeeded()
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
                    self.programsTableView.layoutIfNeeded()
                    self.updateProgramsTableHeight()

                case .failure(let error):
                    print("🔴 aktif enrollment detayları okunamadı:", error.localizedDescription)
                    self.activeEnrollment = nil
                    self.programsTableView.reloadData()
                    self.programsTableView.layoutIfNeeded()
                    self.updateProgramsTableHeight()
                    
                }
            }
        }
    }
    
    
        
        // MARK: - Hibrit veri çekme
    
         private func fetchProgramsFromSource() {
           programService.fetchPrograms { [weak self] firestorePrograms in
            guard let self else { return }

            DispatchQueue.main.async {
                self.programs = firestorePrograms

                print(
                    "🔥 Firestore'dan gelen program sayısı:",
                    firestorePrograms.count
                )

                if firestorePrograms.isEmpty {
                    print(
                        "⚠️ Firestore'da hiç program yok. JSON fallback kapalı."
                    )
                }

                self.programsTableView.reloadData()
                self.programsTableView.layoutIfNeeded()
                self.updateProgramsTableHeight()
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
        
    // MARK: - UI Setup
    
    

    private func setupView() {
        view.backgroundColor = UIColor(
            red: 255 / 255,
            green: 235 / 255,
            blue: 246 / 255,
            alpha: 1
        )

        navigationItem.largeTitleDisplayMode = .never
        
        if traitCollection.userInterfaceIdiom == .phone {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            scrollView.contentInsetAdjustmentBehavior = .automatic
        }

        mercuryRetrogradeView.isHidden = true
        venusRetrogradeView.isHidden = true
        marsRetrogradeView.isHidden = true
        saturnRetrogradeView.isHidden = true
        newMoonView.isHidden = true
        fullMoonView.isHidden = true
        lunarEclipseView.isHidden = true
        solarEclipseView.isHidden = true
    }

    private func setupHierarchy() {
        view.addSubview(scrollView)

        scrollView.addSubview(contentView)
        contentView.addSubview(mainContentView)

        mainContentView.addSubview(astrologyCard)
        mainContentView.addSubview(programsTitleLabel)
        mainContentView.addSubview(programsCardView)

        programsCardView.addSubview(programsTableView)

        astrologyCard.addSubview(astrologyImageView)
        astrologyCard.addSubview(moonSignLabel)
        astrologyCard.addSubview(suitabilityLabel)
        astrologyCard.addSubview(suitabilityProgressView)
        astrologyCard.addSubview(eventScrollView)

        eventScrollView.addSubview(eventStackView)

        eventStackView.addArrangedSubview(mercuryRetrogradeView)
        eventStackView.addArrangedSubview(venusRetrogradeView)
        eventStackView.addArrangedSubview(marsRetrogradeView)
        eventStackView.addArrangedSubview(saturnRetrogradeView)
        eventStackView.addArrangedSubview(newMoonView)
        eventStackView.addArrangedSubview(fullMoonView)
        eventStackView.addArrangedSubview(lunarEclipseView)
        eventStackView.addArrangedSubview(solarEclipseView)
    }

    private func setupConstraints() {
        let responsiveWidthConstraint =
            mainContentView.widthAnchor.constraint(
                equalTo: contentView.widthAnchor,
                constant: -32
            )

        responsiveWidthConstraint.priority = .defaultHigh

        programsTableHeightConstraint =
            programsTableView.heightAnchor.constraint(
                equalToConstant: 1
            )

        guard let programsTableHeightConstraint else {
            return
        }

        NSLayoutConstraint.activate([
            // MARK: ScrollView

            scrollView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            scrollView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            scrollView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            scrollView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),

            // MARK: ContentView

            contentView.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor
            ),
            contentView.leadingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.leadingAnchor
            ),
            contentView.trailingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.trailingAnchor
            ),
            contentView.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor
            ),
            contentView.widthAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.widthAnchor
            ),

            // MARK: Responsive Main Content

            mainContentView.topAnchor.constraint(
                equalTo: contentView.topAnchor
            ),
            mainContentView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -30
            ),
            mainContentView.centerXAnchor.constraint(
                equalTo: contentView.centerXAnchor
            ),
            mainContentView.leadingAnchor.constraint(
                greaterThanOrEqualTo: contentView.leadingAnchor,
                constant: 16
            ),
            mainContentView.trailingAnchor.constraint(
                lessThanOrEqualTo: contentView.trailingAnchor,
                constant: -16
            ),
            mainContentView.widthAnchor.constraint(
                lessThanOrEqualToConstant: 720
            ),
            responsiveWidthConstraint,

            // MARK: Astrology Card

            astrologyCard.topAnchor.constraint(
                equalTo: mainContentView.topAnchor,
                constant: traitCollection.userInterfaceIdiom == .pad ? 20 : 8
            ),
            astrologyCard.leadingAnchor.constraint(
                equalTo: mainContentView.leadingAnchor
            ),
            astrologyCard.trailingAnchor.constraint(
                equalTo: mainContentView.trailingAnchor
            ),
            astrologyCard.heightAnchor.constraint(
                greaterThanOrEqualToConstant: 200
            ),

            astrologyImageView.leadingAnchor.constraint(
                equalTo: astrologyCard.leadingAnchor,
                constant: 18
            ),
            astrologyImageView.topAnchor.constraint(
                equalTo: astrologyCard.topAnchor,
                constant: 24
            ),
            astrologyImageView.widthAnchor.constraint(
                equalToConstant: 110
            ),
            astrologyImageView.heightAnchor.constraint(
                equalToConstant: 110
            ),

            moonSignLabel.leadingAnchor.constraint(
                equalTo: astrologyImageView.trailingAnchor,
                constant: 18
            ),
            moonSignLabel.trailingAnchor.constraint(
                equalTo: astrologyCard.trailingAnchor,
                constant: -18
            ),
            moonSignLabel.topAnchor.constraint(
                equalTo: astrologyCard.topAnchor,
                constant: 34
            ),

            suitabilityLabel.leadingAnchor.constraint(
                equalTo: moonSignLabel.leadingAnchor
            ),
            suitabilityLabel.trailingAnchor.constraint(
                equalTo: astrologyCard.trailingAnchor,
                constant: -18
            ),
            suitabilityLabel.topAnchor.constraint(
                equalTo: moonSignLabel.bottomAnchor,
                constant: 16
            ),

            suitabilityProgressView.leadingAnchor.constraint(
                equalTo: moonSignLabel.leadingAnchor
            ),
            suitabilityProgressView.trailingAnchor.constraint(
                equalTo: astrologyCard.trailingAnchor,
                constant: -18
            ),
            suitabilityProgressView.topAnchor.constraint(
                equalTo: suitabilityLabel.bottomAnchor,
                constant: 16
            ),
            suitabilityProgressView.heightAnchor.constraint(
                equalToConstant: 5
            ),

            // MARK: Event Scroll

            eventScrollView.leadingAnchor.constraint(
                equalTo: astrologyCard.leadingAnchor,
                constant: 18
            ),
            eventScrollView.trailingAnchor.constraint(
                equalTo: astrologyCard.trailingAnchor,
                constant: -18
            ),
            eventScrollView.topAnchor.constraint(
                greaterThanOrEqualTo: astrologyImageView.bottomAnchor,
                constant: 14
            ),
            eventScrollView.bottomAnchor.constraint(
                equalTo: astrologyCard.bottomAnchor,
                constant: -20
            ),
            eventScrollView.heightAnchor.constraint(
                equalToConstant: 36
            ),

            eventStackView.topAnchor.constraint(
                equalTo: eventScrollView.contentLayoutGuide.topAnchor
            ),
            eventStackView.leadingAnchor.constraint(
                equalTo: eventScrollView.contentLayoutGuide.leadingAnchor
            ),
            eventStackView.trailingAnchor.constraint(
                equalTo: eventScrollView.contentLayoutGuide.trailingAnchor
            ),
            eventStackView.bottomAnchor.constraint(
                equalTo: eventScrollView.contentLayoutGuide.bottomAnchor
            ),
            eventStackView.heightAnchor.constraint(
                equalTo: eventScrollView.frameLayoutGuide.heightAnchor
            ),

            // MARK: Programs Title

            programsTitleLabel.topAnchor.constraint(
                equalTo: astrologyCard.bottomAnchor,
                constant: 28
            ),
            programsTitleLabel.leadingAnchor.constraint(
                equalTo: mainContentView.leadingAnchor,
                constant: 8
            ),
            programsTitleLabel.trailingAnchor.constraint(
                equalTo: mainContentView.trailingAnchor,
                constant: -8
            ),

            // MARK: Program Table Container

            programsCardView.topAnchor.constraint(
                equalTo: programsTitleLabel.bottomAnchor,
                constant: 22
            ),
            programsCardView.leadingAnchor.constraint(
                equalTo: mainContentView.leadingAnchor
            ),
            programsCardView.trailingAnchor.constraint(
                equalTo: mainContentView.trailingAnchor
            ),
            programsCardView.bottomAnchor.constraint(
                equalTo: mainContentView.bottomAnchor
            ),

            programsTableView.topAnchor.constraint(
                equalTo: programsCardView.topAnchor
            ),
            programsTableView.leadingAnchor.constraint(
                equalTo: programsCardView.leadingAnchor
            ),
            programsTableView.trailingAnchor.constraint(
                equalTo: programsCardView.trailingAnchor
            ),
            programsTableView.bottomAnchor.constraint(
                equalTo: programsCardView.bottomAnchor
            ),

            programsTableHeightConstraint
        ])
    }
    
    private func makeEventButton(
        title: String
    ) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false

        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)

        button.titleLabel?.font = .systemFont(
            ofSize: 15,
            weight: .regular
        )

        button.backgroundColor = UIColor(
            red: 218 / 255,
            green: 181 / 255,
            blue: 211 / 255,
            alpha: 0.9
        )

        button.layer.cornerRadius = 16
        button.clipsToBounds = true

        button.contentEdgeInsets = UIEdgeInsets(
            top: 7,
            left: 14,
            bottom: 7,
            right: 14
        )

        return button
    }
    
    private func setupEventButtonActions() {
        mercuryRetrogradeView.addTarget(
            self,
            action: #selector(mercuryRetrogradeViewTapped(_:)),
            for: .touchUpInside
        )

        venusRetrogradeView.addTarget(
            self,
            action: #selector(venusRetrogradeViewTapped(_:)),
            for: .touchUpInside
        )

        marsRetrogradeView.addTarget(
            self,
            action: #selector(marsRetrogradeViewTapped(_:)),
            for: .touchUpInside
        )

        saturnRetrogradeView.addTarget(
            self,
            action: #selector(saturnRetrogradeViewTapped(_:)),
            for: .touchUpInside
        )

        newMoonView.addTarget(
            self,
            action: #selector(newMoonViewTapped(_:)),
            for: .touchUpInside
        )

        fullMoonView.addTarget(
            self,
            action: #selector(fullMoonViewTapped(_:)),
            for: .touchUpInside
        )

        lunarEclipseView.addTarget(
            self,
            action: #selector(lunarEclipseViewTapped(_:)),
            for: .touchUpInside
        )

        solarEclipseView.addTarget(
            self,
            action: #selector(solarEclipseViewTapped(_:)),
            for: .touchUpInside
        )
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

        openDailySkyDetail(with: todaySkyData)
    }
    
    private func openDailySkyDetail(with todaySkyData: DailyAstrology) {
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

        programsTableView.separatorStyle = .none
        programsTableView.backgroundColor = .clear
        programsTableView.showsVerticalScrollIndicator = false
        programsTableView.isScrollEnabled = false

        programsTableView.rowHeight = UITableView.automaticDimension
        programsTableView.estimatedRowHeight = 215

        programsTableView.sectionHeaderHeight = 0
        programsTableView.sectionFooterHeight = 12

        programsTableView.contentInset = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: 24,
            right: 0
        )

        programsTableView.register(
            ProgramTableViewCell.self,
            forCellReuseIdentifier:
                ProgramTableViewCell.reuseIdentifier
        )
    }
    
    private func updateProgramsTableHeight() {
        programsTableView.layoutIfNeeded()

        let calculatedHeight =
            programsTableView.contentSize.height

        let newHeight = max(calculatedHeight, 1)

        guard programsTableHeightConstraint?.constant != newHeight else {
            return
        }

        programsTableHeightConstraint?.constant = newHeight
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
        var normalizedData = data

        if normalizedData["date"] == nil {
            normalizedData["date"] = getTodayDateString()
        }

        guard let dailyAstrology = DailyAstrology(firestoreData: normalizedData) else {
            print("🔴 updateAstrologyUI: Firestore verisi DailyAstrology modeline çevrilemedi.")
            return
        }

        self.todaySkyData = dailyAstrology

        print("🌙 ProgramList moonSign:", dailyAstrology.moonSign)
        print("🌙 ProgramList moonSignDisplay:", dailyAstrology.moonSignDisplay)
        print("🌙 ProgramList sections energy:", dailyAstrology.sections.bugununEnerjisi)

        moonSignLabel.text = "🌕 \(dailyAstrology.moonSignDisplay)"
        suitabilityProgressView.progress = Float(dailyAstrology.suitabilityScore) / 10.0

        let percentage = generateStablePercentage(
            score: dailyAstrology.suitabilityScore,
            date: dailyAstrology.date
        )

        suitabilityLabel.text = "Bugünün enerjisi %\(percentage) seninle"

        updateEventButtons(events: dailyAstrology.celestialEvents)
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
    private func showAstroEventInfo(
        title: String,
        message: String,
        color: UIColor,
        symbol: String
    ) {
        let viewController = AstroEventInfoViewController(
            title: title,
            message: message,
            color: color,
            symbol: symbol
        )

        present(
            viewController,
            animated: true
        )
    }
    @objc
    private func mercuryRetrogradeViewTapped(_ sender: UIButton) {
        showAstroEventInfo(
            title: "Merkür Retrosu",
            message: """
                    Merkür retrosunu, iletişim, planlar ve günlük detayların biraz daha fazla dikkat isteyebildiği bir dönem gibi düşünebilirsin.

                    Yanlış anlaşılmalar, unutulan küçük detaylar veya son anda değişen planlar daha fazla dikkatini çekebilir. Geçmişte yarım kalan bir konuşma ya da konu da yeniden gündeme gelebilir. Bu, her şeyin ters gideceği anlamına gelmez.

                    ✨ Bu Dönemde deneyebilirsin:
                    Önemli bir mesajı, randevuyu veya planı kesinleştirmeden önce bir kez daha kontrol et.
                    """,
            color: .astroMercuryColor,
            symbol: "☿"
        )
    }

    @objc
    private func venusRetrogradeViewTapped(_ sender: UIButton) {
        showAstroEventInfo(
            title: "Venüs Retrosu",
            message: """
                    Venüs retrosunu, ilişkiler, değer verdiğin şeyler ve kendinle olan bağını yeniden gözden geçirdiğin bir dönem gibi düşünebilirsin.

                    İlişkilerinde ne istediğini daha fazla sorgulayabilir, geçmişte yaşanan bazı konuları yeniden düşünebilir veya harcamaların konusunda daha seçici davranmak isteyebilirsin. Bu dönem hemen karar vermekten çok, sana gerçekten neyin iyi geldiğini fark etmek için güzel bir fırsat olabilir.

                    ✨ Bu Dönemde Deneyebilirsin:
                    Kendine “Şu anda bana gerçekten iyi gelen şey ne?” diye sor ve cevabını acele etmeden düşün.
                    """,
            color: .astroVenusColor,
            symbol: "♀"
        )
    }

    @objc
    private func marsRetrogradeViewTapped(_ sender: UIButton) {
        showAstroEventInfo(
            title: "Mars Retrosu",
            message: """
                    Mars retrosunu, enerjini nasıl kullandığını ve ne için çaba gösterdiğini yeniden gözden geçirdiğin bir dönem gibi düşünebilirsin.

                    Normalde hızlı ilerlediğin konularda yavaşlama, isteksizlik veya sabırsızlık hissedebilirsin. Bazı planların beklediğin hızda ilerlememesi de mümkün. Bu dönemi kendini zorlamak yerine, gerçekten neye enerji vermek istediğini fark etmek için kullanabilirsin.

                    ✨ Bu Dönem Deneyebilirsin:
                    Bugün yapman gerekenler arasından gerçekten önemli olan tek bir şeyi seç ve enerjini önce ona ver.
                    """,
            color: .astroMarsColor,
            symbol: "♂"
        )
    }

    @objc
    private func saturnRetrogradeViewTapped(_ sender: UIButton) {
        showAstroEventInfo(
            title: "Satürn Retrosu",
            message: """
                    Satürn retrosunu, sorumluluklarını, sınırlarını ve hayatındaki düzeni yeniden gözden geçirdiğin bir dönem gibi düşünebilirsin.

                    Ertelediğin işler, uzun süredir aksayan konular veya daha fazla ciddiyet göstermen gereken alanlar yeniden dikkatini çekebilir. Her şeyi bir anda çözmek zorunda değilsin. Bu dönem, küçük ama sürdürülebilir bir düzen kurmak için iyi bir fırsat olabilir.

                    ✨ Bu Dönem Deneyebilirsin:
                    Uzun zamandır ertelediğin küçük bir işi seç ve sadece ilk adımını at.
                    """,
            color: .astroSaturnColor,
            symbol: "♄"
        )
    }

    @objc
    private func newMoonViewTapped(_ sender: UIButton) {
        showAstroEventInfo(
            title: "Yeni Ay",
            message: """
                    Yeni Ay’ı, önündeki dönem için yeni bir niyet belirlemek ve bir konuda temiz bir başlangıç yapmak için uygun bir zaman gibi düşünebilirsin.

                    Hayatında değiştirmek, başlatmak veya daha fazla önem vermek istediğin bir konu daha belirgin hale gelebilir. Büyük kararlar almak zorunda değilsin; bazen küçük bir niyet bile yönünü netleştirmeye yardımcı olabilir.

                    ✨ Bugün deneyebilirsin:
                    Önümüzdeki günlerde hayatında görmek istediğin tek bir değişikliği yaz ve bunun için atabileceğin en küçük ilk adımı belirle.
                    """,
            color: .astroNewMoonColor,
            symbol: "☾"
        )
    }

    @objc
    private func fullMoonViewTapped(_ sender: UIButton) {
        showAstroEventInfo(
            title: "Dolunay",
            message: """
                    Dolunay’ı, bir süredir devam eden konuların daha görünür hale geldiği ve neyin tamamlanmaya yaklaştığını fark edebildiğin bir dönem gibi düşünebilirsin.

                    Duyguların biraz daha yoğun olabilir veya uzun zamandır aklında olan bir konuda ne istediğini daha net fark edebilirsin. Bu dönem, sana iyi gelmeyen bir alışkanlığı, düşünceyi ya da durumu bırakmak için de uygun bir farkındalık zamanı olabilir.

                    ✨ Bugün deneyebilirsin:
                    Kendine “Hayatımda artık devam ettirmek istemediğim ne var?” diye sor ve aklına gelen ilk şeyi yaz.
                    """,
            color: .astroFullMoonColor,
            symbol: "●"
        )
    }

    @objc
    private func lunarEclipseViewTapped(_ sender: UIButton) {
        showAstroEventInfo(
            title: "Ay Tutulması",
            message: """
                    Ay Tutulmasını, duygularının ve uzun süredir arka planda kalan bazı konuların daha görünür hale geldiği güçlü bir farkındalık zamanı gibi düşünebilirsin.

                    Bazı duyguların yoğunlaşabilir, bir konuda artık ne hissettiğini daha net fark edebilir veya sana iyi gelmeyen bir şeyi bırakma ihtiyacı duyabilirsin. Her şeyi hemen çözmek zorunda değilsin; önce neyin değişmek istediğini fark etmek yeterli olabilir.

                    ✨ Bugün deneyebilirsin:
                    Kendine “Şu anda içimde en çok ne dikkatimi istiyor?” diye sor ve cevabını birkaç cümleyle yaz.
                    """,
            color: .astroLunarEclipseColor,
            symbol: "☾"
        )
    }

    @objc
    private func solarEclipseViewTapped(_ sender: UIButton) {
        showAstroEventInfo(
            title: "Güneş Tutulması",
            message: """
                    Güneş Tutulmasını, hayatında yeni bir yönün veya değişim ihtiyacının daha belirgin hale geldiği bir dönem gibi düşünebilirsin.

                    Bazı konularda “artık farklı bir şey yapmalıyım” hissi oluşabilir veya önünde yeni bir seçenek fark edebilirsin. Her şeyi hemen değiştirmek zorunda değilsin. Bu dönem, önümüzdeki süreçte neye daha fazla yer açmak istediğini düşünmek için güzel bir fırsat olabilir.

                    ✨ Bugün deneyebilirsin:
                    Kendine “Hayatımda bundan sonra neyi farklı yapmak istiyorum?” diye sor ve aklına gelen ilk cevabı yaz.
                    """,
            color: .astroSolarEclipseColor,
            symbol: "☀"
        )
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

extension ProgramListViewController:
    UITableViewDataSource,
    UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return programs.count
    }

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return 1
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ProgramTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? ProgramTableViewCell else {
            assertionFailure("ProgramTableViewCell oluşturulamadı.")
            return UITableViewCell()
        }

        let program = programs[indexPath.section]

        cell.configure(with: program)

        let isActiveProgram =
            activeEnrollment?.programId == program.id

        cell.applyStartButtonState(
            isActiveProgram: isActiveProgram
        )

        cell.onTapStartButton = { [weak self] in
            guard let self else { return }

            if isActiveProgram {
                self.showSimpleAlert(
                    title: "Bu program zaten aktif",
                    message: "Şu anda devam ettiğin program bu."
                )
                return
            }

            let popup = ConfirmationPopupView()

            popup.titleText = "Hazır mısın?"
            popup.messageText =
                "Bu yolculuk seni değiştirebilir.\nBaşlamak ister misin? ✨"
            popup.cancelTitle = "Vazgeç"
            popup.confirmTitle = "Başla"

            popup.onCancel = {
                print("❌ Vazgeçildi")
            }

            popup.onConfirm = { [weak self] in
                guard let self else { return }

                guard let userId =
                    Auth.auth().currentUser?.uid else {

                    self.showSimpleAlert(
                        title: "Hata",
                        message: "Kullanıcı oturumu bulunamadı."
                    )
                    return
                }

                self.enrollmentRepository.startProgram(
                    userId: userId,
                    programId: program.id
                ) { [weak self] result in

                    DispatchQueue.main.async {
                        guard let self else { return }

                        switch result {

                        case .success(let enrollmentId):
                            print(
                                "✅ Program başladı:",
                                enrollmentId
                            )

                            UserDefaults.standard.set(
                                true,
                                forKey: "shouldOpenProgressTodayTab"
                            )

                            self.fetchActiveEnrollmentDetails()
                            self.tabBarController?.selectedIndex = 1

                        case .failure(let error):

                            if let customError =
                                error as? EnrollmentStartError,
                               customError ==
                                .alreadyHasActiveProgram {

                                self.showSimpleAlert(
                                    title: "Zaten aktif programın var",
                                    message: """
                                    Yeni bir programa başlamak için \
                                    mevcut programını tamamlamalısın.
                                    """
                                )

                            } else {
                                print(
                                    "❌ Hata:",
                                    error.localizedDescription
                                )

                                self.showSimpleAlert(
                                    title: "Hata",
                                    message:
                                        error.localizedDescription
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

    func showSimpleAlert(
        title: String,
        message: String
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: "Tamam",
                style: .default
            )
        )

        present(alert, animated: true)
    }

    func tableView(
        _ tableView: UITableView,
        heightForFooterInSection section: Int
    ) -> CGFloat {
        return 12
    }

    func tableView(
        _ tableView: UITableView,
        viewForFooterInSection section: Int
    ) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = .clear
        return footerView
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(
            at: indexPath,
            animated: true
        )

        guard programs.indices.contains(indexPath.section) else {
            return
        }

        let selectedProgram = programs[indexPath.section]

        let detailViewController = ProgramDetailViewController(
            program: selectedProgram
        )

        detailViewController.hidesBottomBarWhenPushed = true

        if let navigationController {
            navigationController.pushViewController(
                detailViewController,
                animated: true
            )
        } else {
            detailViewController.modalPresentationStyle = .fullScreen

            present(
                detailViewController,
                animated: true
            )
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
