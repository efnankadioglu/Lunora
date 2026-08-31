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
    
    // MARK: - Notifications

    private let notificationButton: UIButton = {
        let button = UIButton(type: .system)

        let configuration = UIImage.SymbolConfiguration(
            pointSize: 21,
            weight: .semibold
        )

        button.setImage(
            UIImage(
                systemName: "bell",
                withConfiguration: configuration
            ),
            for: .normal
        )

        button.tintColor = UIColor(
            red: 240 / 255,
            green: 72 / 255,
            blue: 161 / 255,
            alpha: 1
        )

        button.backgroundColor = UIColor.white.withAlphaComponent(0.65)
        button.layer.cornerRadius = 22

        button.widthAnchor.constraint(equalToConstant: 44).isActive = true
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true

        return button
    }()

    // MARK: - Astrology Card
    
    private let skyCardSkeletonView: SkyCardSkeletonView = {
        let view = SkyCardSkeletonView()
        view.isHidden = true
        return view
    }()

    private var skyLoadingWorkItem: DispatchWorkItem?
    private var skyLoadingState: LunoraLoadingState = .loading

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

    private let skyTitleLabel: UILabel = {

        let label = UILabel()

        label.translatesAutoresizingMaskIntoConstraints = false

        label.text = "Günün Gökyüzü"

        label.numberOfLines = 1

        label.font = .systemFont(ofSize: 20, weight: .semibold)

        label.textColor = UIColor(

            red: 75 / 255,

            green: 46 / 255,

            blue: 103 / 255,

            alpha: 0.92

        )

        return label

    }()

    private let moonSignLabel: UILabel = {

        let label = UILabel()

        label.translatesAutoresizingMaskIntoConstraints = false

        label.text = "🌕 Ay"

        label.font = .systemFont(ofSize: 28, weight: .bold)

        label.textColor = UIColor(

            red: 49 / 255,

            green: 24 / 255,

            blue: 74 / 255,

            alpha: 1

        )

        label.numberOfLines = 1

        return label

    }()

    private let suitabilityLabel: UILabel = {

        let label = UILabel()

        label.translatesAutoresizingMaskIntoConstraints = false

        label.text = "Bugünün enerjisi seninle"

        label.font = .systemFont(ofSize: 16, weight: .medium)

        label.textColor = UIColor(

            red: 98 / 255,

            green: 76 / 255,

            blue: 120 / 255,

            alpha: 0.88

        )

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
    
    private let programsDisclaimerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.text = """
        Programlar, genel astrolojik temalardan ilham alınarak kişisel gelişim ve öz bakım amacıyla hazırlanır. Astroloji bilimsel değildir; içerikler kesin sonuç veya profesyonel danışmanlık yerine geçmez. Önerilerin etkisi kişiden kişiye değişebilir.
        """
        
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor.label.withAlphaComponent(0.42)
        label.textAlignment = .center
        label.numberOfLines = 0
        
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
    
    // MARK: - Programs Loading

    private let programsSkeletonStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        stack.isHidden = true
        return stack
    }()

    private let firstProgramSkeleton = ProgramCardSkeletonView()
    private let secondProgramSkeleton = ProgramCardSkeletonView()

    private var programsSkeletonConstraints: [NSLayoutConstraint] = []
    
    private var programsLoadingWorkItem: DispatchWorkItem?
    private var programsLoadingState: LunoraLoadingState = .loading
    

    // MARK: - Data

    private let enrollmentRepository = EnrollmentRepository()
    private let programService = ProgramService.shared

    private var activeEnrollment: ActiveEnrollment?
    private var programs: [Program] = []

    private weak var activeCoachMark: LunoraCoachMarkView?

    #if DEBUG
    private var didShowNotificationPromptPreview = false
    #endif


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
        
        notificationButton.addTarget(
            self,
            action: #selector(notificationButtonTapped),
            for: .touchUpInside
        )
        
        scheduleSkyLoading()

        Task { @MainActor [weak self] in
            guard let self else { return }

            await AstroLocalizationService.shared.loadIfNeeded()

            _ = await DailySkyV2Service.shared.fetchTodayData()

            self.fetchTodayAstrologyV2()

            await self.loadTodayRecommendationDebug()
        }
        scheduleProgramsLoading()
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        print("🧭 GUIDED: ProgramList viewDidAppear")

        showGuidedOnboardingIfNeeded()
    }
    
    private func showGuidedOnboardingIfNeeded() {

        guard activeCoachMark == nil else {
            print(
                "🧭 GUIDED: Coach mark zaten açık"
            )
            return
        }

        guard
            let uid = Auth.auth().currentUser?.uid
        else {
            print(
                "🧭 GUIDED: UID bulunamadı"
            )
            return
        }

        let manager =
            GuidedOnboardingManager.shared

        print(
            "🧭 GUIDED active:",
            manager.isActive(
                for: uid
            )
        )

        print(
            "🧭 GUIDED step:",
            manager.currentStep(
                for: uid
            )?.rawValue ?? "nil"
        )

        guard manager.isActive(
            for: uid
        ) else {
            return
        }

        guard
            let step =
                manager.currentStep(
                    for: uid
                )
        else {
            return
        }

        switch step {

        case .dailySkyCard:

            showDailySkyCardCoachMark(
                uid: uid
            )

        case .programCard:

            showProgramCardCoachMark(
                uid: uid
            )

        default:

            break
        }
    }
    
    // MARK: - Guided Onboarding

    private func showDailySkyCardCoachMark(
        uid: String
    ) {
        guard
            DailySkyV2Service.shared.getTodayData() != nil
        else {
            print(
                "🧭 GUIDED: Gökyüzü datası henüz gelmedi"
            )
            return
        }

        view.layoutIfNeeded()

        guard
            let hostView =
                tabBarController?.view
                    ?? self.view
        else {
            return
        }

        activeCoachMark =
            GuidedOnboardingCoordinator
                .shared
                .present(
                    uid: uid,
                    step:
                        .dailySkyCard,
                    over:
                        hostView,
                    targetView:
                        astrologyCard,
                    onPrimary: {
                        [weak self] in

                        guard let self else {
                            return
                        }

                        self.activeCoachMark = nil

                        print(
                            "🧭 GUIDED: dailySkyCard → dailySkyOverview"
                        )

                        self.didTapAstrologyCard()
                    },
                    onSkip: {
                        [weak self] in

                        self?.activeCoachMark = nil
                    }
                )

        print(
            "🧭 GUIDED: Günün Gökyüzü coach mark gösterildi"
        )
    }
    
    private func showProgramCardCoachMark(
        uid: String
    ) {
        guard !programs.isEmpty else {

            print(
                "🧭 GUIDED: Programlar henüz yüklenmedi"
            )

            return
        }

        programsTableView.reloadData()
        programsTableView.layoutIfNeeded()
        updateProgramsTableHeight()

        view.layoutIfNeeded()

        let firstProgramIndexPath =
            IndexPath(
                row: 0,
                section: 0
            )

        guard
            let firstProgramCell =
                programsTableView.cellForRow(
                    at: firstProgramIndexPath
                )
        else {

            print(
                "🧭 GUIDED: İlk program kartı bulunamadı"
            )

            return
        }

        scrollToProgramCard {
            [weak self] in

            guard let self else {
                return
            }

            guard self.activeCoachMark == nil else {
                return
            }

            guard
                let hostView =
                    self.tabBarController?.view
                        ?? self.view
            else {
                return
            }

            self.activeCoachMark =
                GuidedOnboardingCoordinator
                    .shared
                    .present(
                        uid: uid,
                        step:
                            .programCard,
                        over:
                            hostView,
                        targetView:
                            firstProgramCell,
                        onPrimary: {
                            [weak self] in

                            guard let self else {
                                return
                            }

                            self.activeCoachMark = nil

                            guard
                                self.programs.indices.contains(
                                    firstProgramIndexPath.section
                                )
                            else {
                                return
                            }

                            let selectedProgram =
                                self.programs[
                                    firstProgramIndexPath.section
                                ]

                            print(
                                "🧭 GUIDED: Program Card → Program Detail"
                            )

                            self.openProgramDetail(
                                selectedProgram
                            )
                        },
                        onSkip: {
                            [weak self] in

                            self?.activeCoachMark = nil
                        }
                    )
        }
    }
    
    private func scrollToProgramCard(
        completion: @escaping () -> Void
    ) {
        view.layoutIfNeeded()
        scrollView.layoutIfNeeded()

        let titleRect =
            programsTitleLabel.convert(
                programsTitleLabel.bounds,
                to: scrollView
            )

        // Başlığı ekranın üst tarafında bırakıyoruz.
        // Program kartı böylece popup'ın altında
        // rahat bir alanda görünür.
        let desiredTitleY: CGFloat = 250

        let desiredOffsetY =
            titleRect.minY
            - desiredTitleY

        let minimumOffsetY =
            -scrollView.adjustedContentInset.top

        let maximumOffsetY =
            max(
                minimumOffsetY,
                scrollView.contentSize.height
                    - scrollView.bounds.height
                    + scrollView.adjustedContentInset.bottom
            )

        let finalOffsetY =
            min(
                max(
                    desiredOffsetY,
                    minimumOffsetY
                ),
                maximumOffsetY
            )

        UIView.animate(
            withDuration: 0.35,
            delay: 0,
            options: [
                .curveEaseInOut,
                .allowUserInteraction
            ],
            animations: {

                self.scrollView.setContentOffset(
                    CGPoint(
                        x: 0,
                        y: finalOffsetY
                    ),
                    animated: false
                )
            },
            completion: { _ in

                self.view.layoutIfNeeded()
                self.programsTableView.layoutIfNeeded()

                completion()
            }
        )
    }
    
    private func openProgramDetail(
        _ program: Program
    ) {
        let detailViewController =
            ProgramDetailViewController(
                program: program
            )

        detailViewController.hidesBottomBarWhenPushed =
            true

        if let navigationController {

            navigationController.pushViewController(
                detailViewController,
                animated: true
            )

        } else {

            detailViewController.modalPresentationStyle =
                .fullScreen

            present(
                detailViewController,
                animated: true
            )
        }
    }

    @MainActor
    private func loadTodayRecommendationDebug() async {
        await AstroRulesService.shared.loadIfNeeded()

        guard
            let today = DailySkyV2Service.shared.getTodayData(),
            let rules = AstroRulesService.shared.loadRules()
        else {
            return
        }
        


        let activities =
            await AstroActivityService.shared.loadActivities()

        guard !activities.isEmpty else {
            return
        }

        let ranked =
            AstroRecommendationEngine.shared.rank(
                astro: today.astro,
                activities: activities,
                rulesFile: rules
            )

        let eligible = ranked.filter { $0.eligible }

        print("🧠 Eligible activity sayısı:", eligible.count)
        print("🧠 TOP 10:")

        for item in eligible.prefix(10) {
            print("⭐️ \(item.astroFitScore) | \(item.activity.title)")
        }

        let ineligible = ranked.filter { !$0.eligible }
        print("🚫 INELIGIBLE:")

        for item in ineligible {
            print("🚫 \(item.astroFitScore) | \(item.activity.title)")
            print("   reasons:", item.suppressionReasons)
            print("   strong negatives:", item.strongNegativeRuleIds)
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

                self.hideProgramsLoading()
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

        scrollView.contentInset.bottom = 120

        scrollView.verticalScrollIndicatorInsets.bottom = 120

        mercuryRetrogradeView.isHidden = true

        venusRetrogradeView.isHidden = true

        marsRetrogradeView.isHidden = true

        saturnRetrogradeView.isHidden = true

        newMoonView.isHidden = true

        fullMoonView.isHidden = true

        lunarEclipseView.isHidden = true

        solarEclipseView.isHidden = true

        astrologyImageView.alpha = 0.58
        
        let notificationBarButtonItem = UIBarButtonItem(
            customView: notificationButton
        )

        navigationItem.rightBarButtonItem = notificationBarButtonItem

    }
    
   

    private func setupHierarchy() {
        
        view.addSubview(scrollView)
        

        scrollView.addSubview(contentView)
        contentView.addSubview(mainContentView)

        mainContentView.addSubview(astrologyCard)

        mainContentView.addSubview(programsTitleLabel)

        mainContentView.addSubview(programsCardView)
        
        mainContentView.addSubview(programsDisclaimerLabel)

        programsCardView.addSubview(programsTableView)
        
        programsCardView.addSubview(programsSkeletonStackView)

        programsSkeletonStackView.addArrangedSubview(firstProgramSkeleton)
        programsSkeletonStackView.addArrangedSubview(secondProgramSkeleton)

        astrologyCard.addSubview(skyTitleLabel)

        astrologyCard.addSubview(astrologyImageView)

        astrologyCard.addSubview(moonSignLabel)

        astrologyCard.addSubview(suitabilityLabel)

        astrologyCard.addSubview(suitabilityProgressView)

        astrologyCard.addSubview(eventScrollView)
        
        astrologyCard.addSubview(skyCardSkeletonView)

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
            
            // MARK: Notification Button

            
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

//            astrologyCard.heightAnchor.constraint(

//                greaterThanOrEqualToConstant: 240

//            ),

            skyTitleLabel.topAnchor.constraint(

                equalTo: astrologyCard.topAnchor,

                constant: 20

            ),

            skyTitleLabel.leadingAnchor.constraint(

                equalTo: astrologyCard.leadingAnchor,

                constant: 20

            ),

            skyTitleLabel.trailingAnchor.constraint(

                lessThanOrEqualTo: astrologyCard.trailingAnchor,

                constant: -20

            ),

            astrologyImageView.leadingAnchor.constraint(

                equalTo: astrologyCard.leadingAnchor,

                constant: 20

            ),

            astrologyImageView.topAnchor.constraint(

                equalTo: skyTitleLabel.bottomAnchor,

                constant: 16

            ),

            astrologyImageView.widthAnchor.constraint(

                equalToConstant: 120

            ),

            astrologyImageView.heightAnchor.constraint(

                equalToConstant: 120

            ),

            moonSignLabel.leadingAnchor.constraint(

                equalTo: astrologyImageView.trailingAnchor,

                constant: 18

            ),

            moonSignLabel.trailingAnchor.constraint(

                equalTo: astrologyCard.trailingAnchor,

                constant: -20

            ),

            moonSignLabel.topAnchor.constraint(

                equalTo: astrologyImageView.topAnchor,

                constant: 8

            ),

            suitabilityLabel.leadingAnchor.constraint(

                equalTo: moonSignLabel.leadingAnchor

            ),

            suitabilityLabel.trailingAnchor.constraint(

                equalTo: moonSignLabel.trailingAnchor

            ),

            suitabilityLabel.topAnchor.constraint(

                equalTo: moonSignLabel.bottomAnchor,

                constant: 10

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

                equalTo: moonSignLabel.leadingAnchor

            ),

            eventScrollView.trailingAnchor.constraint(

                equalTo: astrologyCard.trailingAnchor,

                constant: -20

            ),

            eventScrollView.topAnchor.constraint(

                equalTo: suitabilityLabel.bottomAnchor,

                constant: 14

            ),

            eventScrollView.bottomAnchor.constraint(

                equalTo: astrologyCard.bottomAnchor,

                constant: -26

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

            // MARK: Program Disclaimer

            programsDisclaimerLabel.topAnchor.constraint(
                equalTo: programsCardView.bottomAnchor,
                constant: 20
            ),

            programsDisclaimerLabel.leadingAnchor.constraint(
                equalTo: mainContentView.leadingAnchor,
                constant: 20
            ),

            programsDisclaimerLabel.trailingAnchor.constraint(
                equalTo: mainContentView.trailingAnchor,
                constant: -20
            ),

            programsDisclaimerLabel.bottomAnchor.constraint(
                equalTo: mainContentView.bottomAnchor,
                constant: -12
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
        
        NSLayoutConstraint.activate([

            skyCardSkeletonView.leadingAnchor.constraint(
                equalTo: moonSignLabel.leadingAnchor
            ),

            skyCardSkeletonView.trailingAnchor.constraint(
                equalTo: astrologyCard.trailingAnchor,
                constant: -20
            ),

            skyCardSkeletonView.topAnchor.constraint(
                equalTo: moonSignLabel.topAnchor
            ),

            skyCardSkeletonView.bottomAnchor.constraint(
                equalTo: eventScrollView.bottomAnchor
            )
        ])
        
        programsSkeletonConstraints = [
            programsSkeletonStackView.topAnchor.constraint(
                equalTo: programsCardView.topAnchor
            ),

            programsSkeletonStackView.leadingAnchor.constraint(
                equalTo: programsCardView.leadingAnchor
            ),

            programsSkeletonStackView.trailingAnchor.constraint(
                equalTo: programsCardView.trailingAnchor
            ),

            programsSkeletonStackView.bottomAnchor.constraint(
                equalTo: programsCardView.bottomAnchor
            )
        ]

    }

    private func makeEventButton(

        title: String

    ) -> UIButton {

        let button = UIButton(type: .system)

        button.translatesAutoresizingMaskIntoConstraints = false

        button.setTitle(title, for: .normal)

        button.setTitleColor(

            UIColor(

                red: 108 / 255,

                green: 77 / 255,

                blue: 146 / 255,

                alpha: 1

            ),

            for: .normal

        )

        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)

        button.backgroundColor = UIColor.white.withAlphaComponent(0.18)

        button.layer.cornerRadius = 18

        button.layer.borderWidth = 1

        button.layer.borderColor = UIColor.white.withAlphaComponent(0.32).cgColor

        button.clipsToBounds = true

        button.contentEdgeInsets = UIEdgeInsets(

            top: 8,

            left: 14,

            bottom: 8,

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
    
    @objc private func notificationButtonTapped() {
        let vc = NotificationsViewController()
        vc.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(
            vc,
            animated: true
        )
    }

    @objc private func didTapAstrologyCard() {

        guard let data =

            DailySkyV2Service.shared.getTodayData()

        else {

            showSimpleAlert(

                title: "Gökyüzü bilgisi hazır değil",

                message: "Bugünün yeni astroloji verisi bulunamadı."

            )

            return

        }

        let vc = DailySkyV2ViewController(

            data: data,

            selectedDate: Date(),

            dailyDataProvider: { date in

                let formatter = DateFormatter()
                formatter.calendar =
                    Calendar(identifier: .gregorian)
                formatter.locale =
                    Locale(identifier: "en_US_POSIX")
                formatter.timeZone =
                    TimeZone(identifier: "Europe/Istanbul")
                formatter.dateFormat =
                    "yyyy-MM-dd"

                let dateString =
                    formatter.string(from: date)

                return await DailySkyV2Service
                    .shared
                    .fetchData(for: dateString)
            }

        )

        vc.hidesBottomBarWhenPushed = true

        if let navigationController =

            navigationController {

            navigationController.pushViewController(

                vc,

                animated: true

            )

        } else {

            vc.modalPresentationStyle =

                .fullScreen

            present(

                vc,

                animated: true

            )

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
    
    // MARK: - Programs Loading

    private func scheduleProgramsLoading() {
        programsLoadingState = .loading

        programsLoadingWorkItem?.cancel()

        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }

            // Veri bu sırada geldiyse skeleton göstermeye gerek yok.
            guard self.programs.isEmpty else { return }

            self.showProgramsLoading()
        }

        programsLoadingWorkItem = workItem

        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.25,
            execute: workItem
        )
    }

    private func showProgramsLoading() {
        programsTableView.isHidden = true
        programsSkeletonStackView.isHidden = false

        // Normal tablonun 1 pt'lik yükseklik constraint'ini
        // loading sırasında devreden çıkar.
        programsTableHeightConstraint?.isActive = false

        if programsSkeletonConstraints.first?.isActive != true {
            NSLayoutConstraint.activate(programsSkeletonConstraints)
        }

        view.layoutIfNeeded()

        firstProgramSkeleton.startAnimating()
        secondProgramSkeleton.startAnimating()
    }

    private func hideProgramsLoading() {
        programsLoadingWorkItem?.cancel()
        programsLoadingWorkItem = nil

        firstProgramSkeleton.stopAnimating()
        secondProgramSkeleton.stopAnimating()

        programsSkeletonStackView.isHidden = true

        if programsSkeletonConstraints.first?.isActive == true {
            NSLayoutConstraint.deactivate(programsSkeletonConstraints)
        }

        programsTableView.isHidden = false
        programsTableHeightConstraint?.isActive = true

        programsLoadingState = programs.isEmpty ? .empty : .loaded

        programsTableView.reloadData()
        programsTableView.layoutIfNeeded()
        updateProgramsTableHeight()
        
        DispatchQueue.main.async {
            [weak self] in

            self?.showGuidedOnboardingIfNeeded()
        }
        
    }
    
    // MARK: - Sky Loading

    private func scheduleSkyLoading() {
        skyLoadingState = .loading

        skyLoadingWorkItem?.cancel()

        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }

            // Veri daha önce geldiyse skeleton göstermeye gerek yok.
            guard DailySkyV2Service.shared.getTodayData() == nil else {
                return
            }

            self.showSkyLoading()
        }

        skyLoadingWorkItem = workItem

        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.25,
            execute: workItem
        )
    }

    private func showSkyLoading() {
        moonSignLabel.isHidden = true
        suitabilityLabel.isHidden = true
        suitabilityProgressView.isHidden = true
        eventScrollView.isHidden = true

        skyCardSkeletonView.isHidden = false

        view.layoutIfNeeded()

        skyCardSkeletonView.startAnimating()
    }

    private func hideSkyLoading() {
        skyLoadingWorkItem?.cancel()
        skyLoadingWorkItem = nil

        skyCardSkeletonView.stopAnimating()
        skyCardSkeletonView.isHidden = true

        moonSignLabel.isHidden = false
        suitabilityLabel.isHidden = false
        eventScrollView.isHidden = false

        // Yeni sistemde progress bar zaten kullanılmıyor.
        suitabilityProgressView.isHidden = true

        skyLoadingState = .loaded
    }

    private func fetchTodayAstrologyV2() {
        guard let data = DailySkyV2Service.shared.getTodayData() else {
            print("🔴 ProgramList: yeni günlük gökyüzü datası bulunamadı")
            hideSkyLoading()
            return
        }

        updateAstrologyUIV2(data: data)
        hideSkyLoading()

        DispatchQueue.main.async {
            [weak self] in

            self?.showGuidedOnboardingIfNeeded()
        }
    }

    private func currentV2SignalValue(

        type: String,

        signals: [AstroSignal]

    ) -> String? {

        let matchingSignals = signals.filter {

            $0.type == type

        }

        guard !matchingSignals.isEmpty else {

            return nil

        }

        let now = Date()

        let formatter = ISO8601DateFormatter()

        for signal in matchingSignals {

            guard

                let startAt = signal.startAt,

                let endAt = signal.endAt,

                let start = formatter.date(from: startAt),

                let end = formatter.date(from: endAt)

            else {

                continue

            }

            if now >= start && now < end {

                return signal.value

            }

        }

        return matchingSignals.first?.value

    }

    private func updateAstrologyUIV2(data: DailySkyV2Data) {

        let signals = data.astro.astroSignals

        let localization = AstroLocalizationService.shared

        let moonSign = currentV2SignalValue(

            type: "moon_sign",

            signals: signals

        )

        let moonPhase = currentV2SignalValue(

            type: "moon_phase",

            signals: signals

        )

        // MARK: Ay burcu

        if let moonSign {

            moonSignLabel.text =

                "🌕 \(localization.sign(moonSign))"

        } else {

            moonSignLabel.text = "🌕 Ay"

        }

        // MARK: Ay fazı

        if let moonPhase {

            suitabilityLabel.text =

                localization.moonPhase(moonPhase)

        } else {

            suitabilityLabel.text = nil

        }

        // Yeni sistemde günlük yüzde / suitability score yok.

        suitabilityProgressView.isHidden = true

        // Canonical astro signal'lara göre event butonlarını güncelle.

        updateEventButtonsV2(

            signals: signals

        )

        print(

            "🟢 ProgramList V2 moon:",

            moonSign ?? "nil"

        )

        print(

            "🟢 ProgramList V2 phase:",

            moonPhase ?? "nil"

        )

    }

    private func updateEventButtonsV2(

        signals: [AstroSignal]

    ) {

        let localization =

            AstroLocalizationService.shared

        // Önce hepsini gizle.

        mercuryRetrogradeView.isHidden = true

        venusRetrogradeView.isHidden = true

        marsRetrogradeView.isHidden = true

        saturnRetrogradeView.isHidden = true

        newMoonView.isHidden = true

        fullMoonView.isHidden = true

        lunarEclipseView.isHidden = true

        solarEclipseView.isHidden = true



        // MARK: - Retro durumları

        for signal in signals {

            guard signal.type == "planet_status",

                  signal.status == "retrograde",

                  let planet = signal.planet,

                  let status = signal.status

            else {

                continue

            }

            let title =

                localization.planetStatusText(

                    planet: planet,

                    status: status

                )

            switch planet {

            case "mercury":

                mercuryRetrogradeView.setTitle(

                    "☿ \(title)",

                    for: .normal

                )

                mercuryRetrogradeView.isHidden = false

            case "venus":

                venusRetrogradeView.setTitle(

                    "♀ \(title)",

                    for: .normal

                )

                venusRetrogradeView.isHidden = false

            case "mars":

                marsRetrogradeView.setTitle(

                    "♂ \(title)",

                    for: .normal

                )

                marsRetrogradeView.isHidden = false

            case "saturn":

                saturnRetrogradeView.setTitle(

                    "♄ \(title)",

                    for: .normal

                )

                saturnRetrogradeView.isHidden = false

            default:

                break

            }

        }



        // MARK: - Aktif Ay fazı

        let currentPhase =

            currentV2SignalValue(

                type: "moon_phase",

                signals: signals

            )

        if currentPhase == "new_moon" {

            newMoonView.setTitle(

                "☾ \(localization.moonPhase("new_moon"))",

                for: .normal

            )

            newMoonView.isHidden = false

        }

        if currentPhase == "full_moon" {

            fullMoonView.setTitle(

                "● \(localization.moonPhase("full_moon"))",

                for: .normal

            )

            fullMoonView.isHidden = false

        }



        // MARK: - Tutulmalar

        for signal in signals {

            guard signal.type == "eclipse",

                  let event = signal.event

            else {

                continue

            }

            switch event {

            case "lunar_eclipse":

                lunarEclipseView.setTitle(

                    "☾ \(localization.eclipseEvent(event))",

                    for: .normal

                )

                lunarEclipseView.isHidden = false

            case "solar_eclipse":

                solarEclipseView.setTitle(

                    "☀ \(localization.eclipseEvent(event))",

                    for: .normal

                )

                solarEclipseView.isHidden = false

            default:

                break

            }

        }

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
