//
//  DailySkyV2ViewController.swift
//  Lunora
//

import UIKit
import FirebaseAuth

final class DailySkyV2ViewController:

    UIViewController,

    UIGestureRecognizerDelegate {

    private var data: DailySkyV2Data

    // MARK: - Day Navigation

    private var selectedDate: Date

    private let dailyDataProvider: ((Date) async -> DailySkyV2Data?)?

    private var dailyDataCache: [String: DailySkyV2Data] = [:]

    private let previousDayButton = UIButton(type: .system)

    private let nextDayButton = UIButton(type: .system)

    private let selectedDateLabel = UILabel()

    private let maxFutureDayCount = 7

    private static var istanbulCalendar: Calendar {

        var calendar = Calendar(identifier: .gregorian)

        calendar.timeZone = TimeZone(identifier: "Europe/Istanbul")!

        return calendar

    }

    private let scrollView = UIScrollView()

    private let contentView = UIView()

    private let stackView = UIStackView()
        
        private weak var activeCoachMark: LunoraCoachMarkView?

        // MARK: - Guided Onboarding Targets

        private weak var guidedHeroCard: UIView?
        private weak var guidedEnergyCard: UIView?

        private weak var guidedActionsHeaderView: UIView?
        private weak var guidedActionsCard: UIView?
        private weak var guidedAvoidCard: UIView?
        private weak var guidedBeautyHeaderView: UIView?
        private weak var guidedRelationshipsCard: UIView?
        private weak var guidedBeautyCard: UIView?
        private weak var guidedUpcomingCard: UIView?
    
    private let dailySkySkeletonView = DailySkyContentSkeletonView()

    private var contentLoadingState: LunoraLoadingState = .loading

    private var recommendedActivities: [RankedAstroActivity] = []

    private var beautyDetailItems: [BeautyDetailItem] = []

    private var upcomingAstroEvents: [UpcomingAstroEvent] = []

    private struct TodaySkyEventItem {

        let title: String

        let message: String

        let color: UIColor

        let symbol: String

    }

    private var todaySkyEventItems: [TodaySkyEventItem] = []

    init(

        data: DailySkyV2Data,

        selectedDate: Date = Date(),

        dailyDataProvider: ((Date) async -> DailySkyV2Data?)? = nil

    ) {

        self.data = data

        self.selectedDate =

            Self.istanbulCalendar.startOfDay(for: selectedDate)

        self.dailyDataProvider = dailyDataProvider

        super.init(

            nibName: nil,

            bundle: nil

        )

        dailyDataCache[

            dateKey(self.selectedDate)

        ] = data

    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")

    }

    override func viewDidLoad() {

        super.viewDidLoad()

        view.backgroundColor = UIColor(hex: "#FDEAF5")

        setupDateNavigationControls()
        setupLayout()
        showContentLoading()

        Task { @MainActor [weak self] in
            await self?.setupContent()
        }

    }



    // MARK: - Layout

    private func setupLayout() {

        scrollView.translatesAutoresizingMaskIntoConstraints = false

        contentView.translatesAutoresizingMaskIntoConstraints = false

        stackView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.showsVerticalScrollIndicator = false

        stackView.axis = .vertical

        stackView.spacing = 16

        stackView.alignment = .fill

        view.addSubview(scrollView)

        scrollView.addSubview(contentView)

        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([

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

            stackView.topAnchor.constraint(

                equalTo: contentView.topAnchor,

                constant: 18

            ),

            stackView.leadingAnchor.constraint(

                equalTo: contentView.leadingAnchor,

                constant: 20

            ),

            stackView.trailingAnchor.constraint(

                equalTo: contentView.trailingAnchor,

                constant: -20

            ),

            stackView.bottomAnchor.constraint(

                equalTo: contentView.bottomAnchor,

                constant: -40

            )

        ])

    }
        
        // MARK: - Loading

        private func clearStackView() {
            dailySkySkeletonView.stopAnimating()

            stackView.arrangedSubviews.forEach { view in
                stackView.removeArrangedSubview(view)
                view.removeFromSuperview()
            }
        }

        @MainActor
        private func showContentLoading() {
            contentLoadingState = .loading

            clearStackView()

            // Tarihi network beklemeden anında göster.
            selectedDateLabel.text = displayDateText(selectedDate)

            // Veri kontrol edilirken gün değiştirme butonlarını geçici kapat.
            setNavigationButtonState(
                previousDayButton,
                enabled: false
            )

            setNavigationButtonState(
                nextDayButton,
                enabled: false
            )

            // Sabit UI hemen gelsin.
            addDateNavigation()
            addHeader()

            // Data alanında skeleton göster.
            stackView.addArrangedSubview(
                dailySkySkeletonView
            )

            dailySkySkeletonView.startAnimating()
        }



    // MARK: - Content

        @MainActor
        private func setupContent() async {

            await AstroLocalizationService.shared.loadIfNeeded()

            // Önce ileri/geri gün durumlarını hazırla.
            await updateDateNavigationUI()

            // Artık gerçek UI hazırlanabilir.
            clearStackView()

            addDateNavigation()
            addHeader()

            // 1. Bugünün Gökyüzü
            addHeroCard()

            // 2. Bugünün Enerjisi
            addEnergyCard()

            // 3. Bugün bunları yapabilirsin
            await addRecommendedActivities()

            // 4. Bugün biraz dikkat
            addGeneralAvoidCard()

            // 5. İlişkilerde Bugün
            addRelationshipsCard()

            // 6. Güzellik & Bakım
            addBeautyCard()

            // 7. Yaklaşan Gökyüzü
            await addUpcomingAstroEventsCard()

            addAstrologyDisclaimer()

            contentLoadingState = .loaded
            
            DispatchQueue.main.async {
                [weak self] in

                self?.showGuidedOnboardingIfNeeded()
            }
            
        }
    
        // MARK: - Guided Onboarding

        private func showGuidedOnboardingIfNeeded() {

            guard activeCoachMark == nil else {
                return
            }

            guard let uid = Auth.auth().currentUser?.uid else {
                return
            }

            let manager = GuidedOnboardingManager.shared

            guard manager.isActive(for: uid) else {
                return
            }

            guard let step = manager.currentStep(for: uid) else {
                return
            }

            switch step {

            case .dailySkyOverview:
                showDailySkyOverviewCoachMark(
                    uid: uid
                )

            case .dailySkyActions:
                showDailySkyActionsCoachMark(
                    uid: uid
                )

            case .dailySkyAvoid:
                showDailySkyAvoidCoachMark(
                    uid: uid
                )

            case .dailySkyRelationships:
                showDailySkyRelationshipsCoachMark(
                    uid: uid
                )

            case .dailySkyBeauty:
                showDailySkyBeautyCoachMark(
                    uid: uid
                )

            case .dailySkyUpcoming:
                showDailySkyUpcomingCoachMark(
                    uid: uid
                )

            default:
                break
            }
        }
        
        private func showDailySkyOverviewCoachMark(
            uid: String
        ) {
            guard let guidedHeroCard else {
                print(
                    "🧭 GUIDED: Hero kartı hazır değil"
                )
                return
            }

            scrollToGuidedTarget(
                guidedHeroCard
            ) {
                [weak self] in

                guard let self else {
                    return
                }

                guard self.activeCoachMark == nil else {
                    return
                }

                self.activeCoachMark =
                    GuidedOnboardingCoordinator
                        .shared
                        .present(
                            uid: uid,
                            step:
                                .dailySkyOverview,
                            over:
                                self.view,
                            targetView:
                                guidedHeroCard,
                            onPrimary: {
                                [weak self] in

                                guard let self else {
                                    return
                                }

                                self.activeCoachMark = nil

                                DispatchQueue.main.async {
                                    self.showGuidedOnboardingIfNeeded()
                                }
                            },
                            onSkip: {
                                [weak self] in

                                self?.activeCoachMark = nil
                            }
                        )
            }
        }
        
        private func showDailySkyActionsCoachMark(
            uid: String
        ) {
            guard
                let guidedActionsHeaderView,
                let guidedActionsCard
            else {
                print(
                    "🧭 GUIDED: Actions hedefleri hazır değil"
                )
                return
            }

            // Scroll anchor = sadece başlık
            scrollToGuidedTarget(
                guidedActionsHeaderView
            ) {
                [weak self] in

                guard let self else {
                    return
                }

                guard self.activeCoachMark == nil else {
                    return
                }

                // Spotlight = bütün Actions kartı
                self.activeCoachMark =
                    GuidedOnboardingCoordinator
                        .shared
                        .present(
                            uid: uid,
                            step:
                                .dailySkyActions,
                            over:
                                self.view,
                            targetView:
                                guidedActionsCard,
                            onPrimary: {
                                [weak self] in

                                guard let self else {
                                    return
                                }

                                self.activeCoachMark = nil

                                DispatchQueue.main.async {
                                    self.showGuidedOnboardingIfNeeded()
                                }
                            },
                            onSkip: {
                                [weak self] in

                                self?.activeCoachMark = nil
                            }
                        )
            }
        }
        
        private func showDailySkyAvoidCoachMark(
            uid: String
        ) {
            guard let guidedAvoidCard else {

                GuidedOnboardingManager
                    .shared
                    .advance(
                        for: uid
                    )

                DispatchQueue.main.async {
                    [weak self] in

                    self?.showGuidedOnboardingIfNeeded()
                }

                return
            }

            scrollToGuidedTarget(
                guidedAvoidCard
            ) {
                [weak self] in

                guard let self else {
                    return
                }

                guard self.activeCoachMark == nil else {
                    return
                }

                self.activeCoachMark =
                    GuidedOnboardingCoordinator
                        .shared
                        .present(
                            uid: uid,
                            step:
                                .dailySkyAvoid,
                            over:
                                self.view,
                            targetView:
                                guidedAvoidCard,
                            onPrimary: {
                                [weak self] in

                                guard let self else {
                                    return
                                }

                                self.activeCoachMark = nil

                                DispatchQueue.main.async {
                                    self.showGuidedOnboardingIfNeeded()
                                }
                            },
                            onSkip: {
                                [weak self] in

                                self?.activeCoachMark = nil
                            }
                        )
            }
        }
        private func showDailySkyRelationshipsCoachMark(
            uid: String
        ) {
            guard let guidedRelationshipsCard else {

                GuidedOnboardingManager
                    .shared
                    .advance(
                        for: uid
                    )

                DispatchQueue.main.async {
                    [weak self] in

                    self?.showGuidedOnboardingIfNeeded()
                }

                return
            }

            scrollToGuidedTarget(
                guidedRelationshipsCard
            ) {
                [weak self] in

                guard let self else {
                    return
                }

                guard self.activeCoachMark == nil else {
                    return
                }

                self.activeCoachMark =
                    GuidedOnboardingCoordinator
                        .shared
                        .present(
                            uid: uid,
                            step:
                                .dailySkyRelationships,
                            over:
                                self.view,
                            targetView:
                                guidedRelationshipsCard,
                            onPrimary: {
                                [weak self] in

                                guard let self else {
                                    return
                                }

                                self.activeCoachMark = nil

                                DispatchQueue.main.async {
                                    self.showGuidedOnboardingIfNeeded()
                                }
                            },
                            onSkip: {
                                [weak self] in

                                self?.activeCoachMark = nil
                            }
                        )
            }
        }

        private func showDailySkyBeautyCoachMark(
            uid: String
        ) {
            guard
                let guidedBeautyHeaderView,
                let guidedBeautyCard
            else {

                GuidedOnboardingManager
                    .shared
                    .advance(
                        for: uid
                    )

                DispatchQueue.main.async {
                    [weak self] in

                    self?.showGuidedOnboardingIfNeeded()
                }

                return
            }

            scrollToGuidedTarget(
                guidedBeautyHeaderView
            ) {
                [weak self] in

                guard let self else {
                    return
                }

                guard self.activeCoachMark == nil else {
                    return
                }

                self.activeCoachMark =
                    GuidedOnboardingCoordinator
                        .shared
                        .present(
                            uid: uid,
                            step:
                                .dailySkyBeauty,
                            over:
                                self.view,
                            targetView:
                                guidedBeautyCard,
                            onPrimary: {
                                [weak self] in

                                guard let self else {
                                    return
                                }

                                self.activeCoachMark = nil

                                DispatchQueue.main.async {
                                    self.showGuidedOnboardingIfNeeded()
                                }
                            },
                            onSkip: {
                                [weak self] in

                                self?.activeCoachMark = nil
                            }
                        )
            }
        }
        
        private func showDailySkyUpcomingCoachMark(
            uid: String
        ) {
            guard let guidedUpcomingCard else {

                print(
                    "🧭 GUIDED: Yaklaşan olay yok, Upcoming adımı atlanıyor"
                )

                GuidedOnboardingManager.shared.advance(
                    for: uid
                )

                print(
                    "🧭 GUIDED: Upcoming yok → Program Card"
                )

                DispatchQueue.main.async {
                    [weak self] in

                    guard let self else {
                        return
                    }

                    if let navigationController =
                        self.navigationController {

                        navigationController.popViewController(
                            animated: true
                        )

                    } else {

                        self.dismiss(
                            animated: true
                        )
                    }
                }

                return
            }

            scrollToGuidedTarget(
                guidedUpcomingCard
            ) {
                [weak self] in

                guard let self else {
                    return
                }

                guard self.activeCoachMark == nil else {
                    return
                }

                self.activeCoachMark =
                    GuidedOnboardingCoordinator
                        .shared
                        .present(
                            uid: uid,
                            step:
                                .dailySkyUpcoming,
                            over:
                                self.view,
                            targetView:
                                guidedUpcomingCard,
                            onPrimary: {
                                [weak self] in

                                guard let self else {
                                    return
                                }

                                self.activeCoachMark = nil

                                DispatchQueue.main.async {

                                    if let navigationController =
                                        self.navigationController {

                                        navigationController
                                            .popViewController(
                                                animated: true
                                            )

                                    } else {

                                        self.dismiss(
                                            animated: true
                                        )
                                    }
                                }
                            },
                            onSkip: {
                                [weak self] in

                                self?.activeCoachMark = nil
                            }
                        )
            }
        }
        
        
        private func scrollToGuidedTarget(
            _ targetView: UIView,
            completion: @escaping () -> Void
        ) {

            view.layoutIfNeeded()
            scrollView.layoutIfNeeded()

            let targetRect =
                targetView.convert(
                    targetView.bounds,
                    to: scrollView
                )

            // ScrollView'in gerçekten kullanılabilir yüksekliği
            let visibleHeight =
                scrollView.bounds.height
                - scrollView.adjustedContentInset.top
                - scrollView.adjustedContentInset.bottom

            // Hedef kartın merkezi
            let targetCenterY = targetRect.midY

            // Hedefi ekranın kullanılabilir alanının
            // ortasına getirecek offset.
            let desiredOffsetY =
                targetCenterY
                - (visibleHeight / 2)
                - scrollView.adjustedContentInset.top

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
                    self.scrollView.layoutIfNeeded()

                    completion()
                }
            )
        }
        
        
        



    private func addAstrologyDisclaimer() {

        let container = UIView()

        container.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()

        label.translatesAutoresizingMaskIntoConstraints = false

        label.text =

            "Bu sayfadaki yorum ve öneriler, güncel gökyüzü hareketlerinin genel astrolojik yorumlarına dayanır. Astroloji bilimsel bir yöntem değildir; içerikler kesinlik veya gelecek vaadi taşımaz ve kişisel, tıbbi ya da psikolojik danışmanlık yerine geçmez."

        label.font = .systemFont(

            ofSize: 11,

            weight: .regular

        )

        label.textColor =

            UIColor(hex: "#9B8F99")

        label.textAlignment = .center

        label.numberOfLines = 0

        container.addSubview(label)

        NSLayoutConstraint.activate([

            label.topAnchor.constraint(

                equalTo: container.topAnchor,

                constant: 10

            ),

            label.leadingAnchor.constraint(

                equalTo: container.leadingAnchor,

                constant: 16

            ),

            label.trailingAnchor.constraint(

                equalTo: container.trailingAnchor,

                constant: -16

            ),

            label.bottomAnchor.constraint(

                equalTo: container.bottomAnchor,

                constant: -8

            )

        ])

        stackView.addArrangedSubview(container)

    }



    // MARK: - Header

    private func addHeader() {

        let titleLabel = UILabel()

        titleLabel.text = "Bugünün Gökyüzü"

        titleLabel.font = .systemFont(

            ofSize: 30,

            weight: .bold

        )

        titleLabel.textColor = UIColor(hex: "#2D2430")

        titleLabel.textAlignment = .center

        titleLabel.numberOfLines = 0



        let subtitleLabel = UILabel()

        subtitleLabel.text =

        "Gökyüzünün bugünkü ritmini fark et,\ngününü daha bilinçli yönlendir."

        subtitleLabel.font = .systemFont(

            ofSize: 16,

            weight: .medium

        )

        subtitleLabel.textColor = UIColor(hex: "#7D6B83")

        subtitleLabel.textAlignment = .center

        subtitleLabel.numberOfLines = 0



        let headerStack = UIStackView(

            arrangedSubviews: [

                titleLabel,

                subtitleLabel

            ]

        )

        headerStack.axis = .vertical

        headerStack.spacing = 10

        stackView.addArrangedSubview(headerStack)

        stackView.setCustomSpacing(

            18,

            after: headerStack

        )

    }

    // MARK: - Day Navigation

    private func setupDateNavigationControls() {

        let symbolConfiguration =

            UIImage.SymbolConfiguration(

                pointSize: 20,

                weight: .bold

            )

        previousDayButton.setImage(

            UIImage(

                systemName: "chevron.left",

                withConfiguration: symbolConfiguration

            ),

            for: .normal

        )

        nextDayButton.setImage(

            UIImage(

                systemName: "chevron.right",

                withConfiguration: symbolConfiguration

            ),

            for: .normal

        )

        [previousDayButton, nextDayButton].forEach { button in

            button.translatesAutoresizingMaskIntoConstraints = false

            button.tintColor = UIColor(hex: "#F73597")

            button.backgroundColor = UIColor(hex: "#FBE3EF")

            button.layer.cornerRadius = 18

            NSLayoutConstraint.activate([

                button.widthAnchor.constraint(

                    equalToConstant: 36

                ),

                button.heightAnchor.constraint(

                    equalToConstant: 36

                )

            ])

        }

        previousDayButton.addTarget(

            self,

            action: #selector(previousDayTapped),

            for: .touchUpInside

        )

        nextDayButton.addTarget(

            self,

            action: #selector(nextDayTapped),

            for: .touchUpInside

        )

        selectedDateLabel.font =

            .systemFont(

                ofSize: 16,

                weight: .semibold

            )

        selectedDateLabel.textColor =

            UIColor(hex: "#5F5065")

        selectedDateLabel.textAlignment = .center

    }
        private func addDateNavigation() {

            let navigationStack =

            UIStackView(

                arrangedSubviews: [

                    previousDayButton,

                    selectedDateLabel,

                    nextDayButton

                ]

            )

        navigationStack.axis = .horizontal

        navigationStack.alignment = .center

        navigationStack.distribution = .equalCentering

        let container = UIView()

        container.translatesAutoresizingMaskIntoConstraints = false

        navigationStack.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(

            navigationStack

        )

        NSLayoutConstraint.activate([

            container.heightAnchor.constraint(

                equalToConstant: 44

            ),

            navigationStack.topAnchor.constraint(

                equalTo: container.topAnchor

            ),

            navigationStack.leadingAnchor.constraint(

                equalTo: container.leadingAnchor,

                constant: 20

            ),

            navigationStack.trailingAnchor.constraint(

                equalTo: container.trailingAnchor,

                constant: -20

            ),

            navigationStack.bottomAnchor.constraint(

                equalTo: container.bottomAnchor

            )

        ])

        stackView.addArrangedSubview(

            container

        )

        stackView.setCustomSpacing(

            14,

            after: container

        )

    }



        @objc
        private func previousDayTapped() {
            Task { @MainActor [weak self] in
                await self?.navigateDay(by: -1)
            }
        }



        @objc
        private func nextDayTapped() {
            Task { @MainActor [weak self] in
                await self?.navigateDay(by: 1)
            }
        }



        @MainActor
        private func navigateDay(
            by dayOffset: Int
        ) async {

            let calendar =
                Self.istanbulCalendar

            guard
                let targetDate =
                    calendar.date(
                        byAdding: .day,
                        value: dayOffset,
                        to: selectedDate
                    )
            else {
                return
            }

            let normalizedTarget =
                calendar.startOfDay(
                    for: targetDate
                )

            guard
                await canNavigate(
                    to: normalizedTarget
                ),
                let newData =
                    await dataForDate(
                        normalizedTarget
                    )
            else {
                return
            }

            selectedDate =
                normalizedTarget

            data =
                newData

            reloadSelectedDay()
        }



        private func reloadSelectedDay() {

            recommendedActivities.removeAll()
            beautyDetailItems.removeAll()
            upcomingAstroEvents.removeAll()
            todaySkyEventItems.removeAll()

            // Boş ekran yerine yeni günün skeletonını göster.
            showContentLoading()

            Task { @MainActor [weak self] in
                guard let self else { return }

                await self.setupContent()

                self.scrollView.setContentOffset(
                    .zero,
                    animated: false
                )
            }
        }



        @MainActor
        private func updateDateNavigationUI() async {

        selectedDateLabel.text =

            displayDateText(

                selectedDate

            )

        let calendar =

            Self.istanbulCalendar

        let previousDate =

            calendar.date(

                byAdding: .day,

                value: -1,

                to: selectedDate

            )

        let nextDate =

            calendar.date(

                byAdding: .day,

                value: 1,

                to: selectedDate

            )

            let previousEnabled: Bool

            if let previousDate {
                previousEnabled =
                    await canNavigate(
                        to: previousDate
                    )
            } else {
                previousEnabled = false
            }

            let nextEnabled: Bool

            if let nextDate {
                nextEnabled =
                    await canNavigate(
                        to: nextDate
                    )
            } else {
                nextEnabled = false
            }

        setNavigationButtonState(

            previousDayButton,

            enabled: previousEnabled

        )

        setNavigationButtonState(

            nextDayButton,

            enabled: nextEnabled

        )

    }



    private func setNavigationButtonState(

        _ button: UIButton,

        enabled: Bool

    ) {

        button.isEnabled = enabled

        button.alpha =

            enabled

            ? 1.0

            : 0.38

        button.backgroundColor =

            enabled

            ? UIColor(hex: "#F1D9EE")

            : UIColor(hex: "#F6EAF3")

    }



        @MainActor
        private func canNavigate(
            to date: Date
        ) async -> Bool {

        let calendar =

            Self.istanbulCalendar

        let target =

            calendar.startOfDay(

                for: date

            )

        let today =

            calendar.startOfDay(

                for: Date()

            )

        guard

            let maximumFutureDate =

                calendar.date(

                    byAdding: .day,

                    value: maxFutureDayCount,

                    to: today

                )

        else {

            return false

        }

        // Gelecekte maksimum 7 gün

        guard target <= maximumFutureDate else {

            return false

        }

        // O güne ait data gerçekten var mı?

            return await dataForDate(
                target
            ) != nil

    }



        @MainActor
        private func dataForDate(
            _ date: Date
        ) async -> DailySkyV2Data? {

        let key =

            dateKey(

                date

            )

        if let cached =

            dailyDataCache[key] {

            return cached

        }

            guard let dailyDataProvider else {
                return nil
            }

            guard
                let loadedData =
                    await dailyDataProvider(
                        date
                    )
            else {
                return nil
            }

        dailyDataCache[key] =

            loadedData

        return loadedData

    }



    private func dateKey(

        _ date: Date

    ) -> String {

        let formatter =

            DateFormatter()

        formatter.calendar =

            Self.istanbulCalendar

        formatter.locale =

            Locale(

                identifier: "en_US_POSIX"

            )

        formatter.timeZone =

            TimeZone(

                identifier: "Europe/Istanbul"

            )

        formatter.dateFormat =

            "yyyy-MM-dd"

        return formatter.string(

            from: date

        )

    }



    private func displayDateText(

        _ date: Date

    ) -> String {

        let formatter =

            DateFormatter()

        formatter.calendar =

            Self.istanbulCalendar

        formatter.locale =

            Locale(

                identifier: "tr_TR"

            )

        formatter.timeZone =

            TimeZone(

                identifier: "Europe/Istanbul"

            )

        formatter.dateFormat =

            "d MMMM"

        return formatter.string(

            from: date

        )

    }



    // MARK: - Hero

    private func addHeroCard() {

        let localization =

            AstroLocalizationService.shared

        let moonSignDisplay =

            moonSignDisplayInfo()

        let moonPhase =

            currentAstroValue(

                type: "moon_phase"

            )

        todaySkyEventItems =

            makeTodaySkyEventItems()

        // MARK: - Card

        let card = UIView()

        card.backgroundColor =

            UIColor(hex: "#E9D4FF")

        card.layer.cornerRadius = 28

        card.layer.shadowColor =

            UIColor.black.cgColor

        card.layer.shadowOpacity = 0.04

        card.layer.shadowRadius = 14

        card.layer.shadowOffset =

            CGSize(width: 0, height: 6)

        // MARK: - Icon

        let iconContainer = UIView()

        iconContainer

            .translatesAutoresizingMaskIntoConstraints =

            false

        let iconImageView = UIImageView(

            image: UIImage(

                named: "astro_daily_energy_icon"

            )

        )

        iconImageView

            .translatesAutoresizingMaskIntoConstraints =

            false

        iconImageView.contentMode =

            .scaleAspectFit

        iconContainer.addSubview(

            iconImageView

        )

        NSLayoutConstraint.activate([

            iconContainer.widthAnchor.constraint(

                equalToConstant: 112

            ),

            iconContainer.heightAnchor.constraint(

                equalToConstant: 112

            ),

            iconImageView.topAnchor.constraint(

                equalTo: iconContainer.topAnchor

            ),

            iconImageView.leadingAnchor.constraint(

                equalTo: iconContainer.leadingAnchor

            ),

            iconImageView.trailingAnchor.constraint(

                equalTo: iconContainer.trailingAnchor

            ),

            iconImageView.bottomAnchor.constraint(

                equalTo: iconContainer.bottomAnchor

            )

        ])

        // MARK: - Moon Sign

        let titleLabel = UILabel()

        if let moonSignDisplay {

            titleLabel.text = moonSignDisplay.title

        } else {

            titleLabel.text = "Bugünün Ayı"

        }

        titleLabel.font =

            .systemFont(

                ofSize: 22,

                weight: .bold

            )

        titleLabel.textColor =

            UIColor(hex: "#2D2430")

        titleLabel.numberOfLines = 0

        // MARK: - Moon Phase

        let phaseLabel = UILabel()

        if let moonPhase {

            phaseLabel.text =

                localization.moonPhase(

                    moonPhase

                )

        } else {

            phaseLabel.text = nil

        }

        phaseLabel.font =

            .systemFont(

                ofSize: 17,

                weight: .semibold

            )

        phaseLabel.textColor =

            UIColor(hex: "#995EC5")

        phaseLabel.numberOfLines = 0

        // MARK: - Horizontal Astro Events

        let eventScrollView = UIScrollView()

        eventScrollView

            .translatesAutoresizingMaskIntoConstraints =

            false

        eventScrollView

            .showsHorizontalScrollIndicator =

            false

        eventScrollView

            .alwaysBounceHorizontal =

            true

        eventScrollView

            .alwaysBounceVertical =

            false

        eventScrollView

            .isDirectionalLockEnabled =

            true

        let eventStack = UIStackView()

        eventStack

            .translatesAutoresizingMaskIntoConstraints =

            false

        eventStack.axis = .horizontal

        eventStack.alignment = .center

        eventStack.spacing = 8

        eventScrollView.addSubview(

            eventStack

        )

        for (index, event)

        in todaySkyEventItems.enumerated() {

            let button =

                makeTodaySkyEventButton(

                    event,

                    index: index

                )

            eventStack.addArrangedSubview(

                button

            )

        }

        NSLayoutConstraint.activate([

            eventScrollView.heightAnchor.constraint(

                equalToConstant: 38

            ),

            eventStack.topAnchor.constraint(

                equalTo:

                    eventScrollView

                    .contentLayoutGuide

                    .topAnchor

            ),

            eventStack.leadingAnchor.constraint(

                equalTo:

                    eventScrollView

                    .contentLayoutGuide

                    .leadingAnchor

            ),

            eventStack.trailingAnchor.constraint(

                equalTo:

                    eventScrollView

                    .contentLayoutGuide

                    .trailingAnchor

            ),

            eventStack.bottomAnchor.constraint(

                equalTo:

                    eventScrollView

                    .contentLayoutGuide

                    .bottomAnchor

            ),

            eventStack.heightAnchor.constraint(

                equalTo:

                    eventScrollView

                    .frameLayoutGuide

                    .heightAnchor

            )

        ])

        // MARK: - Right Side

        let textStack = UIStackView(

            arrangedSubviews: [

                titleLabel,

                phaseLabel,

                eventScrollView

            ]

        )

        textStack.axis = .vertical

        textStack.alignment = .fill

        textStack.spacing = 6

        textStack.setCustomSpacing(

            13,

            after: phaseLabel

        )

        // Sağ taraf kalan alanı kullansın

        textStack.setContentHuggingPriority(

            .defaultLow,

            for: .horizontal

        )

        textStack.setContentCompressionResistancePriority(

            .defaultLow,

            for: .horizontal

        )

        // MARK: - Hero Layout

        let heroStack = UIStackView(

            arrangedSubviews: [

                iconContainer,

                textStack

            ]

        )

        heroStack

            .translatesAutoresizingMaskIntoConstraints =

            false

        heroStack.axis = .horizontal

        heroStack.alignment = .center

        heroStack.spacing = 14

        heroStack.distribution = .fill

        card.addSubview(

            heroStack

        )

        NSLayoutConstraint.activate([

            heroStack.topAnchor.constraint(

                equalTo: card.topAnchor,

                constant: 22

            ),

            heroStack.leadingAnchor.constraint(

                equalTo: card.leadingAnchor,

                constant: 20

            ),

            heroStack.trailingAnchor.constraint(

                equalTo: card.trailingAnchor,

                constant: -20

            ),

            heroStack.bottomAnchor.constraint(

                equalTo: card.bottomAnchor,

                constant: -22

            )

        ])

        stackView.addArrangedSubview(

            card

        )
        
        guidedHeroCard = card

    }

    @objc

    private func todaySkyEventTapped(

        _ sender: UIButton

    ) {

        guard

            todaySkyEventItems.indices.contains(

                sender.tag

            )

        else {

            return

        }

        let event =

            todaySkyEventItems[

                sender.tag

            ]

        let detailVC =

            AstroEventInfoViewController(

                title: event.title,

                message: event.message,

                color: event.color,

                symbol: event.symbol

            )

        present(

            detailVC,

            animated: true

        )

    }

    private func makeTodaySkyEventItems()

    -> [TodaySkyEventItem] {

        let localization =

            AstroLocalizationService.shared

        let signals =

            data.astro.astroSignals

        var result:

            [TodaySkyEventItem] = []

        // MARK: - Moon Sign

        if let moonSignDisplay =

            moonSignDisplayInfo() {

            result.append(

                TodaySkyEventItem(

                    title: moonSignDisplay.title,

                    message: moonSignDisplay.detailMessage,

                    color: UIColor(hex: "#A777D0"),

                    symbol: "☾"

                )

            )

        }

        // MARK: - Retrogrades

        var addedRetroPlanets =

            Set<String>()

        for signal in signals {

            guard

                signal.type ==

                    "planet_status",

                signal.status ==

                    "retrograde",

                let planet =

                    signal.planet,

                !addedRetroPlanets

                    .contains(planet)

            else {

                continue

            }

            switch planet {

            case "mercury":

                result.append(

                    TodaySkyEventItem(

                        title:

                            "Merkür Retrosu",

                        message:

                            mercuryRetrogradeInfo,

                        color:

                            .astroMercuryColor,

                        symbol:

                            "☿"

                    )

                )

            case "venus":

                result.append(

                    TodaySkyEventItem(

                        title:

                            "Venüs Retrosu",

                        message:

                            venusRetrogradeInfo,

                        color:

                            .astroVenusColor,

                        symbol:

                            "♀"

                    )

                )

            case "mars":

                result.append(

                    TodaySkyEventItem(

                        title:

                            "Mars Retrosu",

                        message:

                            marsRetrogradeInfo,

                        color:

                            .astroMarsColor,

                        symbol:

                            "♂"

                    )

                )

            case "saturn":

                result.append(

                    TodaySkyEventItem(

                        title:

                            "Satürn Retrosu",

                        message:

                            saturnRetrogradeInfo,

                        color:

                            .astroSaturnColor,

                        symbol:

                            "♄"

                    )

                )

            default:

                continue

            }

            addedRetroPlanets.insert(

                planet

            )

        }

        // MARK: - New Moon / Full Moon

        if let phase =

            currentAstroValue(

                type: "moon_phase"

            ) {

            if phase == "new_moon" {

                result.append(

                    TodaySkyEventItem(

                        title: "Yeni Ay",

                        message:

                            newMoonInfo,

                        color:

                            .astroNewMoonColor,

                        symbol:

                            "☾"

                    )

                )

            }

            if phase == "full_moon" {

                result.append(

                    TodaySkyEventItem(

                        title: "Dolunay",

                        message:

                            fullMoonInfo,

                        color:

                            .astroFullMoonColor,

                        symbol:

                            "●"

                    )

                )

            }

        }

        // MARK: - Eclipses

        for signal in signals {

            guard

                signal.type == "eclipse",

                let eclipse =

                    signal.event

            else {

                continue

            }

            switch eclipse {

            case "lunar_eclipse":

                result.append(

                    TodaySkyEventItem(

                        title:

                            "Ay Tutulması",

                        message:

                            lunarEclipseInfo,

                        color:

                            .astroLunarEclipseColor,

                        symbol:

                            "☾"

                    )

                )

            case "solar_eclipse":

                result.append(

                    TodaySkyEventItem(

                        title:

                            "Güneş Tutulması",

                        message:

                            solarEclipseInfo,

                        color:

                            .astroSolarEclipseColor,

                        symbol:

                            "☀"

                    )

                )

            default:

                break

            }

        }

        return result

    }

    private func makeTodaySkyEventButton(

        _ event: TodaySkyEventItem,

        index: Int

    ) -> UIButton {

        let button =

            UIButton(type: .system)

        button

            .translatesAutoresizingMaskIntoConstraints =

            false

        button.tag = index

        button.setTitle(

            "\(event.symbol)  \(event.title)",

            for: .normal

        )

        button.setTitleColor(

            UIColor(hex: "#674C83"),

            for: .normal

        )

        button.titleLabel?.font =

            .systemFont(

                ofSize: 14,

                weight: .semibold

            )

        button.backgroundColor =

            UIColor.white

            .withAlphaComponent(0.30)

        button.layer.cornerRadius = 17

        button.contentEdgeInsets =

            UIEdgeInsets(

                top: 7,

                left: 14,

                bottom: 7,

                right: 14

            )

        button.addTarget(

            self,

            action:

                #selector(

                    todaySkyEventTapped(_:)

                ),

            for: .touchUpInside

        )

        return button

    }

    // MARK: - Upcoming Astro Events

        @MainActor
        private func addUpcomingAstroEventsCard() async {

            let events =
                await UpcomingAstroEventService
                    .shared
                    .upcomingEvents(
                        referenceDate: selectedDate,
                        limit: 3
                    )

        guard !events.isEmpty else {

            return

        }

        upcomingAstroEvents =

            events

        let card = UIView()

        // Gece gökyüzü zemini

        // ANA KART

        card.backgroundColor =

            UIColor(hex: "#4A416F")

        card.layer.cornerRadius = 24

        // Çok hafif lila çerçeve

        card.layer.borderWidth = 1

        card.layer.borderColor =

            UIColor.white

                .withAlphaComponent(0.08)

                .cgColor

        // Hafif gece kartı gölgesi

        card.layer.shadowColor =

            UIColor(hex: "#17132F").cgColor

        card.layer.shadowOpacity = 0.16

        card.layer.shadowRadius = 16

        card.layer.shadowOffset =

            CGSize(width: 0, height: 7)

        // MARK: Header

        let iconContainer = UIView()

        iconContainer.translatesAutoresizingMaskIntoConstraints = false

        let iconImageView = UIImageView(

            image: UIImage(

                named: "astro_upcoming_events_icon"

            )

        )

        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        iconImageView.contentMode = .scaleAspectFit

        iconContainer.addSubview(

            iconImageView

        )

        NSLayoutConstraint.activate([

            iconContainer.widthAnchor.constraint(

                equalToConstant: 64

            ),

            iconContainer.heightAnchor.constraint(

                equalToConstant: 64

            ),

            iconImageView.topAnchor.constraint(

                equalTo: iconContainer.topAnchor

            ),

            iconImageView.leadingAnchor.constraint(

                equalTo: iconContainer.leadingAnchor

            ),

            iconImageView.trailingAnchor.constraint(

                equalTo: iconContainer.trailingAnchor

            ),

            iconImageView.bottomAnchor.constraint(

                equalTo: iconContainer.bottomAnchor

            )

        ])

        let titleLabel =

            UILabel()

        titleLabel.text =

            "Yaklaşan Gökyüzü"

        titleLabel.font =

            .systemFont(

                ofSize: 21,

                weight: .bold

            )

        titleLabel.textColor =

            UIColor(hex: "#FFF9FF")

        titleLabel.numberOfLines =

            0

        let subtitleLabel =

            UILabel()

        subtitleLabel.text =

            "Önümüzdeki günlerde öne çıkan önemli gökyüzü hareketleri"

        subtitleLabel.font =

            .systemFont(

                ofSize: 14,

                weight: .medium

            )

        titleLabel.textColor =

            UIColor(hex: "#FFF9FF")

        subtitleLabel.textColor =

            UIColor(hex: "#E1DBEC")

        subtitleLabel.numberOfLines =

            0

        let textStack =

            UIStackView(

                arrangedSubviews: [

                    titleLabel,

                    subtitleLabel

                ]

            )

        textStack.axis =

            .vertical

        textStack.spacing =

            3

        let headerStack =

            UIStackView(

                arrangedSubviews: [

                    iconContainer,

                    textStack

                ]

            )

        headerStack.axis =

            .horizontal

        headerStack.alignment =

            .center

        headerStack.spacing =

            14

        // MARK: Event Rows

        let eventStack =

            UIStackView()

        eventStack.axis =

            .vertical

        eventStack.spacing =

            10

        for (index, event)

        in events.enumerated() {

            let row =

                makeUpcomingAstroEventRow(

                    event,

                    index: index

                )

            eventStack

                .addArrangedSubview(

                    row

                )

        }

        let mainStack =

            UIStackView(

                arrangedSubviews: [

                    headerStack,

                    eventStack

                ]

            )

        mainStack

            .translatesAutoresizingMaskIntoConstraints =

            false

        mainStack.axis =

            .vertical

        mainStack.spacing =

            16

        card.addSubview(

            mainStack

        )

        NSLayoutConstraint.activate([

            mainStack.topAnchor.constraint(

                equalTo:

                    card.topAnchor,

                constant: 20

            ),

            mainStack.leadingAnchor.constraint(

                equalTo:

                    card.leadingAnchor,

                constant: 20

            ),

            mainStack.trailingAnchor.constraint(

                equalTo:

                    card.trailingAnchor,

                constant: -20

            ),

            mainStack.bottomAnchor.constraint(

                equalTo:

                    card.bottomAnchor,

                constant: -20

            )

        ])

        stackView.addArrangedSubview(

            card

        )
            guidedUpcomingCard = card

    }

    // MARK: - Upcoming Astro Row

    private func makeUpcomingAstroEventRow(

        _ event: UpcomingAstroEvent,

        index: Int

    ) -> UIView {

        let accent =

            upcomingAstroAccent(

                for: event.key

            )

        let row = UIView()

        row.backgroundColor =

            UIColor(hex: "#5B5184")

        row.layer.cornerRadius = 18

        // Ana karttan hafifçe ayrışsın

        row.layer.borderWidth = 1

        row.layer.borderColor =

            UIColor.white

                .withAlphaComponent(0.065)

                .cgColor

        // Icon

        let iconContainer =

            UIView()

        iconContainer

            .translatesAutoresizingMaskIntoConstraints =

            false

        iconContainer.backgroundColor =

            UIColor(hex: "#6C6198")

        iconContainer.layer.cornerRadius =

            22

        let iconLabel =

            UILabel()

        iconLabel

            .translatesAutoresizingMaskIntoConstraints =

            false

        iconLabel.text =

            upcomingAstroGlyph(

                for: event.key

            )

        iconLabel.font =

            .systemFont(

                ofSize: 22,

                weight: .medium

            )

        iconLabel.textColor =

            UIColor(hex: "#E6D5FF")

        iconLabel.textAlignment =

            .center

        iconContainer.addSubview(

            iconLabel

        )

        NSLayoutConstraint.activate([

            iconContainer.widthAnchor.constraint(

                equalToConstant: 44

            ),

            iconContainer.heightAnchor.constraint(

                equalToConstant: 44

            ),

            iconLabel.centerXAnchor.constraint(

                equalTo:

                    iconContainer.centerXAnchor

            ),

            iconLabel.centerYAnchor.constraint(

                equalTo:

                    iconContainer.centerYAnchor

            )

        ])

        // Title

        let titleLabel =

            UILabel()

        titleLabel.text =

            event

            .content

            .display

            .title

        titleLabel.font =

            .systemFont(

                ofSize: 16,

                weight: .semibold

            )

        titleLabel.textColor =

            UIColor(hex: "#FFF9FF")

        titleLabel.numberOfLines =

            1

        // Countdown + date

        let dateLabel =

            UILabel()

        dateLabel.text =

            upcomingAstroDateText(

                event

            )

        dateLabel.font =

            .systemFont(

                ofSize: 13,

                weight: .semibold

            )

        dateLabel.textColor =

            UIColor(hex: "#E0C4FF")

        // Themes

        let themes =

            event

            .content

            .display

            .themes

            .prefix(3)

            .joined(

                separator: " • "

            )

        let themesLabel =

            UILabel()

        themesLabel.text =

            themes

        themesLabel.font =

            .systemFont(

                ofSize: 13,

                weight: .medium

            )

        themesLabel.textColor =

            UIColor(hex: "#DDD6E8")

        themesLabel.numberOfLines =

            1

        let textStack =

            UIStackView(

                arrangedSubviews: [

                    titleLabel,

                    dateLabel,

                    themesLabel

                ]

            )

        textStack.axis =

            .vertical

        textStack.spacing =

            3

        // Chevron

        let chevron =

            UIImageView(

                image:

                    UIImage(

                        systemName:

                            "chevron.right"

                    )

            )

        chevron

            .translatesAutoresizingMaskIntoConstraints =

            false

        chevron.tintColor =

            UIColor(hex: "#E4DDEE")

        chevron.contentMode =

            .scaleAspectFit

        let rowStack =

            UIStackView(

                arrangedSubviews: [

                    iconContainer,

                    textStack,

                    chevron

                ]

            )

        rowStack

            .translatesAutoresizingMaskIntoConstraints =

            false

        rowStack.axis =

            .horizontal

        rowStack.alignment =

            .center

        rowStack.spacing =

            12

        row.addSubview(

            rowStack

        )

        NSLayoutConstraint.activate([

            chevron.widthAnchor.constraint(

                equalToConstant: 9

            ),

            chevron.heightAnchor.constraint(

                equalToConstant: 16

            ),

            rowStack.topAnchor.constraint(

                equalTo:

                    row.topAnchor,

                constant: 13

            ),

            rowStack.leadingAnchor.constraint(

                equalTo:

                    row.leadingAnchor,

                constant: 13

            ),

            rowStack.trailingAnchor.constraint(

                equalTo:

                    row.trailingAnchor,

                constant: -14

            ),

            rowStack.bottomAnchor.constraint(

                equalTo:

                    row.bottomAnchor,

                constant: -13

            )

        ])

        // Full-row button

        let button =

            UIButton(

                type: .system

            )

        button

            .translatesAutoresizingMaskIntoConstraints =

            false

        button.backgroundColor =

            .clear

        button.tag =

            index

        button.addTarget(

            self,

            action:

                #selector(

                    upcomingAstroEventTapped(_:)

                ),

            for: .touchUpInside

        )

        row.addSubview(

            button

        )

        NSLayoutConstraint.activate([

            button.topAnchor.constraint(

                equalTo:

                    row.topAnchor

            ),

            button.leadingAnchor.constraint(

                equalTo:

                    row.leadingAnchor

            ),

            button.trailingAnchor.constraint(

                equalTo:

                    row.trailingAnchor

            ),

            button.bottomAnchor.constraint(

                equalTo:

                    row.bottomAnchor

            )

        ])

        return row

    }

    // MARK: - Upcoming Astro Tap

    @objc

    private func upcomingAstroEventTapped(

        _ sender: UIButton

    ) {

        guard

            upcomingAstroEvents

            .indices

            .contains(

                sender.tag

            )

        else {

            return

        }

        let event =

            upcomingAstroEvents[

                sender.tag

            ]

        let detailVC =

            UpcomingAstroEventDetailSheetViewController(

                event: event

            )

        detailVC.modalPresentationStyle =

            .pageSheet

        if let sheet =

            detailVC

            .sheetPresentationController {

            sheet.detents = [

                .medium(),

                .large()

            ]

            sheet

                .selectedDetentIdentifier =

                .medium

            sheet

                .prefersGrabberVisible =

                true

            sheet

                .prefersScrollingExpandsWhenScrolledToEdge =

                true

            sheet

                .preferredCornerRadius =

                28

        }

        present(

            detailVC,

            animated: true

        )

    }

    // MARK: - Upcoming Astro Helpers

    private func upcomingAstroDateText(

        _ event: UpcomingAstroEvent

    ) -> String {

        let formatter =

            DateFormatter()

        formatter.locale =

            Locale(

                identifier: "tr_TR"

            )

        formatter.timeZone =

            TimeZone(

                identifier:

                    "Europe/Istanbul"

            )

        formatter.dateFormat =

            "d MMMM"

        let dateText =

            formatter.string(

                from: event.date

            )

        switch event.daysRemaining {

        case 0:

            return

                "Bugün • \(dateText)"

        case 1:

            return

                "Yarın • \(dateText)"

        default:

            return

                "\(event.daysRemaining) gün sonra • \(dateText)"

        }

    }

    private func upcomingAstroGlyph(

        for key: String

    ) -> String {

        switch key {

        case "mercury_retrograde":

            return "☿"

        case "venus_retrograde":

            return "♀"

        case "mars_retrograde":

            return "♂"

        case "new_moon":

            return "●"

        case "full_moon":

            return "○"

        case "solar_eclipse":

            return "◐"

        case "lunar_eclipse":

            return "◑"

        default:

            return "✧"

        }

    }

    private func upcomingAstroAccent(

        for key: String

    ) -> UIColor {

        switch key {

        case "venus_retrograde":

            return

                UIColor(

                    hex: "#E971AE"

                )

        case "mars_retrograde":

            return

                UIColor(

                    hex: "#D77B82"

                )

        case "mercury_retrograde":

            return

                UIColor(

                    hex: "#9873D4"

                )

        case "new_moon":

            return

                UIColor(

                    hex: "#876BBF"

                )

        case "full_moon":

            return

                UIColor(

                    hex: "#B383C7"

                )

        case "solar_eclipse",

             "lunar_eclipse":

            return

                UIColor(

                    hex: "#7359A6"

                )

        default:

            return

                UIColor(

                    hex: "#9A78CC"

                )

        }

    }





    // MARK: - Energy

    private func addEnergyCard() {

        guard

            let interpretation = data.interpretation

        else {

            return

        }

        let general =

            interpretation.generalDailyInterpretation



        let card = UIView()

        card.backgroundColor =

            UIColor.white.withAlphaComponent(0.88)

        card.layer.cornerRadius = 24



        // MARK: Icon

        let iconContainer = UIView()

        iconContainer.translatesAutoresizingMaskIntoConstraints = false

        let iconImageView = UIImageView(

            image: UIImage(named: "astro_sky_today_icon")

        )

        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        iconImageView.contentMode = .scaleAspectFit

        iconContainer.addSubview(iconImageView)

        NSLayoutConstraint.activate([

            iconContainer.widthAnchor.constraint(

                equalToConstant: 64

            ),

            iconContainer.heightAnchor.constraint(

                equalToConstant: 64

            ),

            iconImageView.topAnchor.constraint(

                equalTo: iconContainer.topAnchor

            ),

            iconImageView.leadingAnchor.constraint(

                equalTo: iconContainer.leadingAnchor

            ),

            iconImageView.trailingAnchor.constraint(

                equalTo: iconContainer.trailingAnchor

            ),

            iconImageView.bottomAnchor.constraint(

                equalTo: iconContainer.bottomAnchor

            )

        ])



        // MARK: Title

        let titleLabel = UILabel()

        titleLabel.text = general.title

        titleLabel.font =

            .systemFont(

                ofSize: 21,

                weight: .bold

            )

        titleLabel.textColor =

            UIColor(hex: "#2D2430")

        titleLabel.numberOfLines = 0



        // MARK: Chevron

        let chevron = UIImageView(

            image: UIImage(

                systemName: "chevron.right"

            )

        )

        chevron.translatesAutoresizingMaskIntoConstraints =

            false

        chevron.tintColor =

            UIColor(hex: "#AA94B2")

        chevron.contentMode = .scaleAspectFit



        // MARK: Header

        let headerStack =

            UIStackView(

                arrangedSubviews: [

                    iconContainer,

                    titleLabel

                ]

            )

        headerStack.axis = .horizontal

        headerStack.spacing = 14

        headerStack.alignment = .center



        let headerContainer = UIView()

        headerContainer.translatesAutoresizingMaskIntoConstraints =

            false

        headerStack.translatesAutoresizingMaskIntoConstraints =

            false

        headerContainer.addSubview(headerStack)

        headerContainer.addSubview(chevron)



        NSLayoutConstraint.activate([

            headerStack.topAnchor.constraint(

                equalTo: headerContainer.topAnchor

            ),

            headerStack.leadingAnchor.constraint(

                equalTo: headerContainer.leadingAnchor

            ),

            headerStack.bottomAnchor.constraint(

                equalTo: headerContainer.bottomAnchor

            ),

            headerStack.trailingAnchor.constraint(

                lessThanOrEqualTo: chevron.leadingAnchor,

                constant: -12

            ),



            chevron.trailingAnchor.constraint(

                equalTo: headerContainer.trailingAnchor

            ),

            chevron.centerYAnchor.constraint(

                equalTo: headerContainer.centerYAnchor

            ),

            chevron.widthAnchor.constraint(

                equalToConstant: 9

            ),

            chevron.heightAnchor.constraint(

                equalToConstant: 16

            )

        ])



        // MARK: Summary

        // TAMAMI görünecek.

        let summaryLabel =

            makeBodyLabel(

                text: general.summaryText,

                weight: .semibold

            )

        summaryLabel.numberOfLines = 0



        let mainStack =

            UIStackView(

                arrangedSubviews: [

                    headerContainer,

                    summaryLabel

                ]

            )

        mainStack.translatesAutoresizingMaskIntoConstraints =

            false

        mainStack.axis = .vertical

        mainStack.spacing = 15



        card.addSubview(mainStack)



        // MARK: Tap

        NSLayoutConstraint.activate([

            mainStack.topAnchor.constraint(

                equalTo: card.topAnchor,

                constant: 20

            ),

            mainStack.leadingAnchor.constraint(

                equalTo: card.leadingAnchor,

                constant: 20

            ),

            mainStack.trailingAnchor.constraint(

                equalTo: card.trailingAnchor,

                constant: -20

            ),

            mainStack.bottomAnchor.constraint(

                equalTo: card.bottomAnchor,

                constant: -20

            ),

        ])

        let tapGesture =

            UITapGestureRecognizer(

                target: self,

                action: #selector(

                    energyCardTapped

                )

            )

        card.addGestureRecognizer(

            tapGesture

        )

        stackView.addArrangedSubview(card)
        guidedEnergyCard = card

    }

    @objc

    private func energyCardTapped() {

        guard

            let interpretation = data.interpretation

        else {

            return

        }

        let general =

            interpretation.generalDailyInterpretation



        let detailVC =

            EnergyDetailSheetViewController(

                title: general.title,

                body: general.text

            )



        detailVC.modalPresentationStyle =

            .pageSheet



        if let sheet =

            detailVC.sheetPresentationController {

            sheet.detents = [

                .medium(),

                .large()

            ]

            sheet.selectedDetentIdentifier =

                .medium

            sheet.prefersGrabberVisible =

                true

            sheet.prefersScrollingExpandsWhenScrolledToEdge =

                true

            sheet.preferredCornerRadius =

                28

        }



        present(

            detailVC,

            animated: true

        )

    }

    @objc

    private func relationshipCardTapped() {

        guard

            let interpretation =

                data.interpretation

        else {

            return

        }



        let detailVC =

            RelationshipDetailSheetViewController(

                relationships:

                    interpretation.relationships

            )



        detailVC.modalPresentationStyle =

            .pageSheet



        if let sheet =

            detailVC.sheetPresentationController {

            sheet.detents = [

                .medium(),

                .large()

            ]

            sheet.selectedDetentIdentifier =

                .medium

            sheet.prefersGrabberVisible =

                true

            sheet.prefersScrollingExpandsWhenScrolledToEdge =

                true

            sheet.preferredCornerRadius =

                28

        }



        present(

            detailVC,

            animated: true

        )

    }

    @objc

    private func beautyCardTapped() {

        guard

            !beautyDetailItems.isEmpty

        else {

            return

        }



        let detailVC =

            BeautyDetailSheetViewController(

                items:

                    beautyDetailItems

            )



        detailVC.modalPresentationStyle =

            .pageSheet



        if let sheet =

            detailVC.sheetPresentationController {

            sheet.detents = [

                .medium(),

                .large()

            ]

            sheet.selectedDetentIdentifier =

                .medium

            sheet.prefersGrabberVisible =

                true

            sheet.prefersScrollingExpandsWhenScrolledToEdge =

                true

            sheet.preferredCornerRadius =

                28

        }



        present(

            detailVC,

            animated: true

        )

    }





    func gestureRecognizer(

        _ gestureRecognizer: UIGestureRecognizer,

        shouldReceive touch: UITouch

    ) -> Bool {

        var touchedView: UIView? =

            touch.view

        while let currentView =

            touchedView {

            if let touchedScrollView =

                currentView as? UIScrollView {

                // Sayfanın ana dikey scroll'u değilse,

                // relationship theme yatay scroll'udur.

                if touchedScrollView !== scrollView {

                    return false

                }

            }

            touchedView =

                currentView.superview

        }

        return true

    }



    @objc

    private func recommendedActivityTapped(

        _ sender: UIButton

    ) {

        guard

            recommendedActivities.indices.contains(

                sender.tag

            )

        else {

            return

        }

        let recommendation =

            recommendedActivities[sender.tag]

        let detailVC =

            ActivityDetailSheetViewController(

                activity:

                    recommendation.activity

            )

        detailVC.modalPresentationStyle =

            .pageSheet



        if let sheet =

            detailVC.sheetPresentationController {

            sheet.detents = [

                .medium(),

                .large()

            ]

            sheet.selectedDetentIdentifier =

                .medium

            sheet.prefersGrabberVisible = true

            sheet.prefersScrollingExpandsWhenScrolledToEdge =

                true

            sheet.preferredCornerRadius = 28

        }



        present(

            detailVC,

            animated: true

        )

    }

    // MARK: - Recommended Activities

    @MainActor
    private func addRecommendedActivities() async {

        await AstroRulesService.shared.loadIfNeeded()

        guard

            let rules =

                AstroRulesService.shared.loadRules()

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

                astro: data.astro,

                activities: activities,

                rulesFile: rules

            )

        recommendedActivities =

            Array(

                ranked

                    .filter { $0.eligible }

                    .prefix(5)

            )

        guard !recommendedActivities.isEmpty else {

            return

        }

        let card = UIView()

        card.backgroundColor =

            UIColor.white.withAlphaComponent(0.88)

        card.layer.cornerRadius = 24



        // MARK: Header

        let iconContainer = UIView()

        iconContainer.translatesAutoresizingMaskIntoConstraints = false

        let iconImageView = UIImageView(

            image: UIImage(named: "astro_daily_actions_icon")

        )

        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        iconImageView.contentMode = .scaleAspectFit

        iconContainer.addSubview(iconImageView)

        NSLayoutConstraint.activate([

            iconContainer.widthAnchor.constraint(

                equalToConstant: 64

            ),

            iconContainer.heightAnchor.constraint(

                equalToConstant: 64

            ),

            iconImageView.topAnchor.constraint(

                equalTo: iconContainer.topAnchor

            ),

            iconImageView.leadingAnchor.constraint(

                equalTo: iconContainer.leadingAnchor

            ),

            iconImageView.trailingAnchor.constraint(

                equalTo: iconContainer.trailingAnchor

            ),

            iconImageView.bottomAnchor.constraint(

                equalTo: iconContainer.bottomAnchor

            )

        ])

        let titleLabel = UILabel()

        titleLabel.text =

            "Bugün bunları yapabilirsin"

        titleLabel.font =

            .systemFont(

                ofSize: 21,

                weight: .bold

            )

        titleLabel.textColor =

            UIColor(hex: "#2D2430")

        titleLabel.numberOfLines = 0



        let titleStack =

            UIStackView(

                arrangedSubviews: [

                    iconContainer,

                    titleLabel

                ]

            )



        // MARK: Activity Rows

        let activitiesStack = UIStackView()

        activitiesStack.axis = .vertical

        activitiesStack.spacing = 10



        for (index, recommendation)

            in recommendedActivities.enumerated() {

            let row = UIView()

            row.backgroundColor =

                UIColor(hex: "#FFF0F7")

            row.layer.cornerRadius = 18



            let activityTitle = UILabel()

            activityTitle.text =

                recommendation.activity.title

            activityTitle.font =

                .systemFont(

                    ofSize: 16,

                    weight: .semibold

                )

            activityTitle.textColor =

                UIColor(hex: "#3B303F")

            activityTitle.numberOfLines = 2



            let descriptionLabel =

                makeBodyLabel(

                    text:

                        recommendation

                            .activity

                            .shortDescription,

                    weight: .regular

                )

            // Ana ekranda kısa görünüm

            descriptionLabel.numberOfLines = 2

            descriptionLabel.lineBreakMode =

                .byTruncatingTail



            let textStack =

                UIStackView(

                    arrangedSubviews: [

                        activityTitle,

                        descriptionLabel

                    ]

                )

            textStack.translatesAutoresizingMaskIntoConstraints =

                false

            textStack.axis = .vertical

            textStack.spacing = 5



            let chevronImageView = UIImageView(

                image: UIImage(

                    systemName: "chevron.right"

                )

            )

            chevronImageView.translatesAutoresizingMaskIntoConstraints =

                false

            chevronImageView.tintColor =

                UIColor(hex: "#D3A6BE")

            chevronImageView.contentMode =

                .scaleAspectFit



            row.addSubview(textStack)

            row.addSubview(chevronImageView)



            // Tıklanabilir alan

            let button = UIButton(type: .system)

            button.translatesAutoresizingMaskIntoConstraints =

                false

            button.backgroundColor = .clear

            button.tag = index

            button.addTarget(

                self,

                action: #selector(

                    recommendedActivityTapped(_:)

                ),

                for: .touchUpInside

            )

            row.addSubview(button)



            NSLayoutConstraint.activate([

                textStack.topAnchor.constraint(

                    equalTo: row.topAnchor,

                    constant: 14

                ),

                textStack.leadingAnchor.constraint(

                    equalTo: row.leadingAnchor,

                    constant: 16

                ),

                textStack.trailingAnchor.constraint(

                    equalTo: chevronImageView.leadingAnchor,

                    constant: -12

                ),

                textStack.bottomAnchor.constraint(

                    equalTo: row.bottomAnchor,

                    constant: -14

                ),



                chevronImageView.trailingAnchor.constraint(

                    equalTo: row.trailingAnchor,

                    constant: -16

                ),

                chevronImageView.centerYAnchor.constraint(

                    equalTo: row.centerYAnchor

                ),

                chevronImageView.widthAnchor.constraint(

                    equalToConstant: 9

                ),

                chevronImageView.heightAnchor.constraint(

                    equalToConstant: 16

                ),

                button.topAnchor.constraint(

                    equalTo: row.topAnchor

                ),

                button.leadingAnchor.constraint(

                    equalTo: row.leadingAnchor

                ),

                button.trailingAnchor.constraint(

                    equalTo: row.trailingAnchor

                ),

                button.bottomAnchor.constraint(

                    equalTo: row.bottomAnchor

                )



            ])



            activitiesStack.addArrangedSubview(row)

        }



        let mainStack =

            UIStackView(

                arrangedSubviews: [

                    titleStack,

                    activitiesStack

                ]

            )

        mainStack.translatesAutoresizingMaskIntoConstraints =

            false

        mainStack.axis = .vertical

        mainStack.spacing = 16



        card.addSubview(mainStack)



        NSLayoutConstraint.activate([

            mainStack.topAnchor.constraint(

                equalTo: card.topAnchor,

                constant: 20

            ),

            mainStack.leadingAnchor.constraint(

                equalTo: card.leadingAnchor,

                constant: 20

            ),

            mainStack.trailingAnchor.constraint(

                equalTo: card.trailingAnchor,

                constant: -20

            ),

            mainStack.bottomAnchor.constraint(

                equalTo: card.bottomAnchor,

                constant: -20

            )

        ])
        
        stackView.addArrangedSubview(card)

        guidedActionsHeaderView = titleStack
        guidedActionsCard = card

    }



    // MARK: - General Avoid

    private func addGeneralAvoidCard() {

        guard let interpretation =

                data.interpretation,

              !interpretation.avoidToday.isEmpty

        else {

            return

        }

        guidedAvoidCard =
            addBulletCard(
                iconImageName: "astro_daily_caution_icon",
                title: "Bugün biraz dikkat",
                items: interpretation.avoidToday,
                backgroundColor: UIColor(hex: "#F5EDFF")
            )

    }



    // MARK: - Relationships

    private func addRelationshipsCard() {

        guard

            let interpretation = data.interpretation

        else {

            return

        }

        let relationships =

            interpretation.relationships



        // MARK: - Card

        let card = UIView()

        card.backgroundColor =

            UIColor(hex: "#FFF4FA")

        card.layer.cornerRadius = 24



        // MARK: - Header

        let iconContainer = UIView()

        iconContainer.translatesAutoresizingMaskIntoConstraints = false

        let iconImageView = UIImageView(

            image: UIImage(named: "astro_relationships_icon")

        )

        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        iconImageView.contentMode = .scaleAspectFit

        iconContainer.addSubview(iconImageView)

        NSLayoutConstraint.activate([

            iconContainer.widthAnchor.constraint(

                equalToConstant: 64

            ),

            iconContainer.heightAnchor.constraint(

                equalToConstant: 64

            ),

            iconImageView.topAnchor.constraint(

                equalTo: iconContainer.topAnchor

            ),

            iconImageView.leadingAnchor.constraint(

                equalTo: iconContainer.leadingAnchor

            ),

            iconImageView.trailingAnchor.constraint(

                equalTo: iconContainer.trailingAnchor

            ),

            iconImageView.bottomAnchor.constraint(

                equalTo: iconContainer.bottomAnchor

            )

        ])



        let titleLabel = UILabel()

        titleLabel.text =

            relationships.general.title

        titleLabel.font =

            .systemFont(

                ofSize: 21,

                weight: .bold

            )

        titleLabel.textColor =

            UIColor(hex: "#2D2430")

        titleLabel.numberOfLines = 0



        let headerStack = UIStackView(

            arrangedSubviews: [

                iconContainer,

                titleLabel

            ]

        )

        headerStack.axis = .horizontal

        headerStack.spacing = 14

        headerStack.alignment = .center

        // MARK: - Chevron

        let chevron = UIImageView(

            image: UIImage(

                systemName: "chevron.right"

            )

        )

        chevron.translatesAutoresizingMaskIntoConstraints =

            false

        chevron.tintColor =

            UIColor(hex: "#AA94B2")

        chevron.contentMode =

            .scaleAspectFit



        let headerContainer = UIView()

        headerContainer.translatesAutoresizingMaskIntoConstraints =

            false

        headerStack.translatesAutoresizingMaskIntoConstraints =

            false



        headerContainer.addSubview(

            headerStack

        )

        headerContainer.addSubview(

            chevron

        )



        NSLayoutConstraint.activate([

            headerStack.topAnchor.constraint(

                equalTo:

                    headerContainer.topAnchor

            ),

            headerStack.leadingAnchor.constraint(

                equalTo:

                    headerContainer.leadingAnchor

            ),

            headerStack.bottomAnchor.constraint(

                equalTo:

                    headerContainer.bottomAnchor

            ),

            headerStack.trailingAnchor.constraint(

                lessThanOrEqualTo:

                    chevron.leadingAnchor,

                constant: -12

            ),



            chevron.trailingAnchor.constraint(

                equalTo:

                    headerContainer.trailingAnchor

            ),

            chevron.centerYAnchor.constraint(

                equalTo:

                    headerContainer.centerYAnchor

            ),

            chevron.widthAnchor.constraint(

                equalToConstant: 9

            ),

            chevron.heightAnchor.constraint(

                equalToConstant: 16

            )

        ])



        // MARK: - Themes

        let themes =

            makeRelationshipThemeGrid(

                relationships

                    .theme

                    .displayKeywords

            )



        // MARK: - Summary

        let summaryLabel =

            makeBodyLabel(

                text:

                    relationships

                        .general

                        .summaryText,

                weight: .semibold

            )

        summaryLabel.numberOfLines = 0



        // MARK: - Good For Today

        let goodBox = UIView()

        goodBox.backgroundColor =

            UIColor(hex: "#FBE2F1")

        goodBox.layer.cornerRadius = 18



        let goodTitle = UILabel()

        goodTitle.text =

            relationships

                .goodForToday

                .title

        goodTitle.font =

            .systemFont(

                ofSize: 16,

                weight: .bold

            )

        goodTitle.textColor =

            UIColor(hex: "#A7437B")

        goodTitle.numberOfLines = 0



        let goodText =

            makeBodyLabel(

                text:

                    relationships

                        .goodForToday

                        .text,

                weight: .regular

            )



        let goodStack = UIStackView(

            arrangedSubviews: [

                goodTitle,

                goodText

            ]

        )

        goodStack.translatesAutoresizingMaskIntoConstraints =

            false

        goodStack.axis = .vertical

        goodStack.spacing = 7

        goodBox.addSubview(

            goodStack

        )



        NSLayoutConstraint.activate([

            goodStack.topAnchor.constraint(

                equalTo:

                    goodBox.topAnchor,

                constant: 14

            ),

            goodStack.leadingAnchor.constraint(

                equalTo:

                    goodBox.leadingAnchor,

                constant: 16

            ),

            goodStack.trailingAnchor.constraint(

                equalTo:

                    goodBox.trailingAnchor,

                constant: -16

            ),

            goodStack.bottomAnchor.constraint(

                equalTo:

                    goodBox.bottomAnchor,

                constant: -14

            )

        ])



        // MARK: - Main Stack

        let mainStack = UIStackView(

            arrangedSubviews: [

                headerContainer,

                themes,

                summaryLabel,

                goodBox

            ]

        )

        mainStack.translatesAutoresizingMaskIntoConstraints =

            false

        mainStack.axis = .vertical

        mainStack.spacing = 14



        card.addSubview(

            mainStack

        )



        NSLayoutConstraint.activate([

            mainStack.topAnchor.constraint(

                equalTo:

                    card.topAnchor,

                constant: 20

            ),

            mainStack.leadingAnchor.constraint(

                equalTo:

                    card.leadingAnchor,

                constant: 20

            ),

            mainStack.trailingAnchor.constraint(

                equalTo:

                    card.trailingAnchor,

                constant: -20

            ),

            mainStack.bottomAnchor.constraint(

                equalTo:

                    card.bottomAnchor,

                constant: -20

            )

        ])



        // MARK: - Tap

        let tapGesture =

            UITapGestureRecognizer(

                target: self,

                action: #selector(

                    relationshipCardTapped

                )

            )

        tapGesture.delegate = self

        tapGesture.cancelsTouchesInView = false

        card.addGestureRecognizer(

            tapGesture

        )



        stackView.addArrangedSubview(

            card

        )
        
        guidedRelationshipsCard = card

    }

    // MARK: - Beauty

    private func addBeautyCard() {

        // Bu tarihe ait beauty data hiç yoksa

        // bölümü göstermiyoruz.

        guard let beauty = data.beauty else {

            return

        }

        let recommendations =

            beauty.beautyRecommendations



        // MARK: - Empty Day

        if recommendations.isEmpty {

            let card = UIView()

            card.backgroundColor =

                UIColor.white.withAlphaComponent(0.88)

            card.layer.cornerRadius = 24



            let icon = makeBeautyMirrorIcon()



            let titleLabel = UILabel()

            titleLabel.text = "Güzellik & Bakım"

            titleLabel.font =

                .systemFont(

                    ofSize: 21,

                    weight: .bold

                )

            titleLabel.textColor =

                UIColor(hex: "#2D2430")



            let titleStack =

                UIStackView(

                    arrangedSubviews: [

                        icon,

                        titleLabel

                    ]

                )

            titleStack.axis = .horizontal

            titleStack.alignment = .center

            titleStack.spacing = 14



            let bodyLabel =

                makeBodyLabel(

                    text:

                        "Bugün için öne çıkan özel bir bakım zamanı bulunmuyor.",

                    weight: .regular

                )

            bodyLabel.numberOfLines = 0



            let mainStack =

                UIStackView(

                    arrangedSubviews: [

                        titleStack,

                        bodyLabel

                    ]

                )

            mainStack.translatesAutoresizingMaskIntoConstraints = false

            mainStack.axis = .vertical

            mainStack.spacing = 14



            card.addSubview(

                mainStack

            )



            NSLayoutConstraint.activate([

                mainStack.topAnchor.constraint(

                    equalTo: card.topAnchor,

                    constant: 20

                ),

                mainStack.leadingAnchor.constraint(

                    equalTo: card.leadingAnchor,

                    constant: 20

                ),

                mainStack.trailingAnchor.constraint(

                    equalTo: card.trailingAnchor,

                    constant: -20

                ),

                mainStack.bottomAnchor.constraint(

                    equalTo: card.bottomAnchor,

                    constant: -20

                )

            ])

            stackView.addArrangedSubview(
                card
            )

            guidedBeautyHeaderView = titleStack
            guidedBeautyCard = card

            return

        }

        // MARK: - Prepare Items

        let items =

            recommendations

                .map {

                    BeautyDetailItem.make(

                        from: $0,

                        displayText: $0.displayText

                    )

                }

                .sorted {

                    BeautyUI.priority(

                        for: $0.status

                    )

                    <

                    BeautyUI.priority(

                        for: $1.status

                    )

                }



        beautyDetailItems =

            items



        let positiveCount =

            items.filter {

                $0.status != "not_recommended"

            }.count



        let cautionCount =

            items.filter {

                $0.status == "not_recommended"

            }.count



        // MARK: - Main Card

        let card = UIView()

        card.backgroundColor =

            UIColor.white.withAlphaComponent(0.88)

        card.layer.cornerRadius = 24



        // MARK: Header

        let icon = makeBeautyMirrorIcon()



        let titleLabel = UILabel()

        titleLabel.text =

            "Güzellik & Bakım"

        titleLabel.font =

            .systemFont(

                ofSize: 21,

                weight: .bold

            )

        titleLabel.textColor =

            UIColor(hex: "#2D2430")



        let subtitleLabel = UILabel()

        subtitleLabel.text =

            "Bugün için öne çıkan bakım önerileri"

        subtitleLabel.font =

            .systemFont(

                ofSize: 14,

                weight: .medium

            )

        subtitleLabel.textColor =

            UIColor(hex: "#8A7B8D")

        subtitleLabel.numberOfLines = 0



        let titleTextStack =

            UIStackView(

                arrangedSubviews: [

                    titleLabel,

                    subtitleLabel

                ]

            )

        titleTextStack.axis = .vertical

        titleTextStack.spacing = 3



        let leftHeader =

            UIStackView(

                arrangedSubviews: [

                    icon,

                    titleTextStack

                ]

            )

        leftHeader.axis = .horizontal

        leftHeader.alignment = .center

        leftHeader.spacing = 14



        let chevron =

            UIImageView(

                image:

                    UIImage(

                        systemName:

                            "chevron.right"

                    )

            )

        chevron.translatesAutoresizingMaskIntoConstraints = false

        chevron.tintColor =

            UIColor(hex: "#AA94B2")

        chevron.contentMode =

            .scaleAspectFit



        let headerContainer = UIView()

        headerContainer.translatesAutoresizingMaskIntoConstraints = false

        leftHeader.translatesAutoresizingMaskIntoConstraints = false



        headerContainer.addSubview(

            leftHeader

        )

        headerContainer.addSubview(

            chevron

        )



        NSLayoutConstraint.activate([

            leftHeader.topAnchor.constraint(

                equalTo:

                    headerContainer.topAnchor

            ),

            leftHeader.leadingAnchor.constraint(

                equalTo:

                    headerContainer.leadingAnchor

            ),

            leftHeader.bottomAnchor.constraint(

                equalTo:

                    headerContainer.bottomAnchor

            ),

            leftHeader.trailingAnchor.constraint(

                lessThanOrEqualTo:

                    chevron.leadingAnchor,

                constant: -12

            ),

            chevron.trailingAnchor.constraint(

                equalTo:

                    headerContainer.trailingAnchor

            ),

            chevron.centerYAnchor.constraint(

                equalTo:

                    headerContainer.centerYAnchor

            ),

            chevron.widthAnchor.constraint(

                equalToConstant: 9

            ),

            chevron.heightAnchor.constraint(

                equalToConstant: 16

            )

        ])



        // MARK: Summary

        let summaryView = UIView()

        summaryView.backgroundColor =

            UIColor(hex: "#FFF4FA")

        summaryView.layer.cornerRadius =

            13



        let summaryLabel = UILabel()

        if cautionCount > 0 {

            summaryLabel.text =

                "\(positiveCount) öneri • \(cautionCount) dikkat"

        } else {

            summaryLabel.text =

                "\(positiveCount) öneri"

        }



        summaryLabel.translatesAutoresizingMaskIntoConstraints = false

        summaryLabel.font =

            .systemFont(

                ofSize: 13,

                weight: .semibold

            )

        summaryLabel.textColor =

            UIColor(hex: "#9E4F78")



        summaryView.addSubview(

            summaryLabel

        )



        NSLayoutConstraint.activate([

            summaryLabel.topAnchor.constraint(

                equalTo: summaryView.topAnchor,

                constant: 8

            ),

            summaryLabel.leadingAnchor.constraint(

                equalTo: summaryView.leadingAnchor,

                constant: 11

            ),

            summaryLabel.trailingAnchor.constraint(

                equalTo: summaryView.trailingAnchor,

                constant: -11

            ),

            summaryLabel.bottomAnchor.constraint(

                equalTo: summaryView.bottomAnchor,

                constant: -8

            )

        ])



        // MARK: Preview

        let previewStack =

            UIStackView()

        previewStack.axis = .vertical

        previewStack.spacing = 8



        // Maksimum 3 tane göster.

        let previewItems =

            beautyPreviewItems(

                from: items

            )



        for item in previewItems {

            previewStack.addArrangedSubview(

                makeBeautyPreviewRow(

                    item

                )

            )

        }



        // MARK: Main Stack

        let mainStack =

            UIStackView(

                arrangedSubviews: [

                    headerContainer,

                    summaryView,

                    previewStack

                ]

            )

        mainStack.translatesAutoresizingMaskIntoConstraints = false

        mainStack.axis = .vertical

        mainStack.spacing = 14



        card.addSubview(

            mainStack

        )



        NSLayoutConstraint.activate([

            mainStack.topAnchor.constraint(

                equalTo: card.topAnchor,

                constant: 20

            ),

            mainStack.leadingAnchor.constraint(

                equalTo: card.leadingAnchor,

                constant: 20

            ),

            mainStack.trailingAnchor.constraint(

                equalTo: card.trailingAnchor,

                constant: -20

            ),

            mainStack.bottomAnchor.constraint(

                equalTo: card.bottomAnchor,

                constant: -20

            )

        ])



        // MARK: Tap

        let tapGesture =

            UITapGestureRecognizer(

                target: self,

                action:

                    #selector(

                        beautyCardTapped

                    )

            )



        card.addGestureRecognizer(

            tapGesture

        )
        stackView.addArrangedSubview(
            card
        )

        guidedBeautyHeaderView = headerContainer
        guidedBeautyCard = card

    }



    // MARK: - Beauty Preview Selection

    private func beautyPreviewItems(

        from items: [BeautyDetailItem]

    ) -> [BeautyDetailItem] {

        guard items.count > 3 else {

            return items

        }



        var result: [BeautyDetailItem] = []



        // Özellikle uygun varsa kesin göster.

        if let item =

            items.first(

                where: {

                    $0.status ==

                        "especially_recommended"

                }

            ) {

            result.append(

                item

            )

        }



        // Normal öneri göster.

        if result.count < 3,

           let item =

            items.first(

                where: {

                    $0.status ==

                        "recommended"

                }

            ) {

            result.append(

                item

            )

        }



        // Dikkat varsa kesin göster.

        if result.count < 3,

           let item =

            items.first(

                where: {

                    $0.status ==

                        "not_recommended"

                }

            ) {

            result.append(

                item

            )

        }



        // Hâlâ 3 olmadıysa sıradaki kayıtlarla doldur.

        for item in items {

            guard result.count < 3 else {

                break

            }



            let exists =

                result.contains {

                    $0.category == item.category &&

                    $0.status == item.status &&

                    $0.displayText == item.displayText

                }



            if !exists {

                result.append(

                    item

                )

            }

        }



        return result

    }



    // MARK: - Beauty Preview Row

    private func makeBeautyPreviewRow(

        _ item: BeautyDetailItem

    ) -> UIView {

        let accent =

            BeautyUI.accent(

                for: item.status

            )



        let row = UIView()

        row.backgroundColor =

            BeautyUI.background(

                for: item.status

            )

        row.layer.cornerRadius =

            16



        if item.status ==

            "especially_recommended" {

            row.layer.borderWidth =

                1

            row.layer.borderColor =

                accent

                    .withAlphaComponent(0.20)

                    .cgColor

        }



        // MARK: Icon

        let iconContainer =

            UIView()

        iconContainer.translatesAutoresizingMaskIntoConstraints = false

        iconContainer.backgroundColor =

            accent.withAlphaComponent(0.12)

        iconContainer.layer.cornerRadius =

            20



        let iconView =

            UIImageView(

                image:

                    UIImage(

                        systemName:

                            BeautyUI.symbolName(

                                for:

                                    item.category

                            )

                    )

            )

        iconView.translatesAutoresizingMaskIntoConstraints = false

        iconView.tintColor =

            accent

        iconView.contentMode =

            .scaleAspectFit



        iconContainer.addSubview(

            iconView

        )



        NSLayoutConstraint.activate([

            iconContainer.widthAnchor.constraint(

                equalToConstant: 40

            ),

            iconContainer.heightAnchor.constraint(

                equalToConstant: 40

            ),

            iconView.centerXAnchor.constraint(

                equalTo:

                    iconContainer.centerXAnchor

            ),

            iconView.centerYAnchor.constraint(

                equalTo:

                    iconContainer.centerYAnchor

            ),

            iconView.widthAnchor.constraint(

                equalToConstant: 19

            ),

            iconView.heightAnchor.constraint(

                equalToConstant: 19

            )

        ])



        // MARK: Text

        let titleLabel =

            UILabel()

        titleLabel.text =

            BeautyUI.title(

                for: item.category

            )

        titleLabel.font =

            .systemFont(

                ofSize: 16,

                weight: .semibold

            )

        titleLabel.textColor =

            UIColor(hex: "#2D2430")



        let timeLabel =

            UILabel()

        timeLabel.text =

            BeautyUI.timeText(

                startAt: item.startAt,

                endAt: item.endAt

            )

        timeLabel.font =

            .systemFont(

                ofSize: 13,

                weight: .semibold

            )

        timeLabel.textColor =

            accent



        let textStack =

            UIStackView(

                arrangedSubviews: [

                    titleLabel,

                    timeLabel

                ]

            )

        textStack.axis = .vertical

        textStack.spacing = 3



        // MARK: Status

        let statusSymbol: String

        switch item.status {

        case "especially_recommended":

            statusSymbol =

                "sparkles"

        case "not_recommended":

            statusSymbol =

                "exclamationmark.circle.fill"

        default:

            statusSymbol =

                "checkmark.circle.fill"

        }



        let statusIcon =

            UIImageView(

                image:

                    UIImage(

                        systemName:

                            statusSymbol

                    )

            )

        statusIcon.translatesAutoresizingMaskIntoConstraints = false

        statusIcon.tintColor = accent

        statusIcon.contentMode = .scaleAspectFit



        let rowStack =

            UIStackView(

                arrangedSubviews: [

                    iconContainer,

                    textStack,

                    statusIcon

                ]

            )

        rowStack.translatesAutoresizingMaskIntoConstraints = false

        rowStack.axis = .horizontal

        rowStack.alignment = .center

        rowStack.spacing = 11



        row.addSubview(

            rowStack

        )



        NSLayoutConstraint.activate([

            statusIcon.widthAnchor.constraint(

                equalToConstant: 18

            ),

            statusIcon.heightAnchor.constraint(

                equalToConstant: 18

            ),

            rowStack.topAnchor.constraint(

                equalTo: row.topAnchor,

                constant: 12

            ),

            rowStack.leadingAnchor.constraint(

                equalTo: row.leadingAnchor,

                constant: 13

            ),

            rowStack.trailingAnchor.constraint(

                equalTo: row.trailingAnchor,

                constant: -13

            ),

            rowStack.bottomAnchor.constraint(

                equalTo: row.bottomAnchor,

                constant: -12

            )

        ])



        return row

    }

    // MARK: - Generic Card

    private func addIconCard(

        icon: String,

        iconColor: UIColor,

        title: String,

        summary: String?,

        body: String?,

        backgroundColor: UIColor

    ) {

        let card = UIView()

        card.backgroundColor = backgroundColor

        card.layer.cornerRadius = 24



        let iconCircle =

        makeIconCircle(

            icon: icon,

            color: iconColor

        )



        let titleLabel = UILabel()

        titleLabel.text = title

        titleLabel.font = .systemFont(

            ofSize: 21,

            weight: .bold

        )

        titleLabel.textColor =

        UIColor(hex: "#2D2430")

        titleLabel.numberOfLines = 0



        let titleStack = UIStackView(

            arrangedSubviews: [

                iconCircle,

                titleLabel

            ]

        )

        titleStack.axis = .horizontal

        titleStack.spacing = 14

        titleStack.alignment = .center



        let textStack = UIStackView()

        textStack.axis = .vertical

        textStack.spacing = 12

        textStack.addArrangedSubview(

            titleStack

        )



        if let summary,

           !summary.isEmpty {

            textStack.addArrangedSubview(

                makeBodyLabel(

                    text: summary,

                    weight: .semibold

                )

            )

        }



        if let body,

           !body.isEmpty {

            textStack.addArrangedSubview(

                makeBodyLabel(

                    text: body,

                    weight: .regular

                )

            )

        }



        textStack.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(textStack)



        NSLayoutConstraint.activate([

            textStack.topAnchor.constraint(

                equalTo: card.topAnchor,

                constant: 20

            ),

            textStack.leadingAnchor.constraint(

                equalTo: card.leadingAnchor,

                constant: 20

            ),

            textStack.trailingAnchor.constraint(

                equalTo: card.trailingAnchor,

                constant: -20

            ),

            textStack.bottomAnchor.constraint(

                equalTo: card.bottomAnchor,

                constant: -20

            )

        ])

        stackView.addArrangedSubview(card)


    }



    // MARK: - Bullet Card

        private func addBulletCard(
            iconImageName: String,
            title: String,
            items: [String],
            backgroundColor: UIColor
        ) -> UIView? {

            guard !items.isEmpty else {
                return nil
            }

        let card = UIView()

        card.backgroundColor = backgroundColor

        card.layer.cornerRadius = 24



        let iconContainer = UIView()

        iconContainer.translatesAutoresizingMaskIntoConstraints = false

        let iconImageView = UIImageView(

            image: UIImage(named: iconImageName)

        )

        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        iconImageView.contentMode = .scaleAspectFit

        iconContainer.addSubview(iconImageView)

        NSLayoutConstraint.activate([

            iconContainer.widthAnchor.constraint(

                equalToConstant: 64

            ),

            iconContainer.heightAnchor.constraint(

                equalToConstant: 64

            ),

            iconImageView.topAnchor.constraint(

                equalTo: iconContainer.topAnchor

            ),

            iconImageView.leadingAnchor.constraint(

                equalTo: iconContainer.leadingAnchor

            ),

            iconImageView.trailingAnchor.constraint(

                equalTo: iconContainer.trailingAnchor

            ),

            iconImageView.bottomAnchor.constraint(

                equalTo: iconContainer.bottomAnchor

            )

        ])



        let titleLabel = UILabel()

        titleLabel.text = title

        titleLabel.font = .systemFont(

            ofSize: 20,

            weight: .bold

        )

        titleLabel.textColor =

        UIColor(hex: "#2D2430")

        titleLabel.numberOfLines = 0



        let titleStack = UIStackView(

            arrangedSubviews: [

                iconContainer,

                titleLabel

            ]

        )

        titleStack.axis = .horizontal

        titleStack.spacing = 14

        titleStack.alignment = .center



        let bulletStack =

        makeBulletStack(items)



        let innerStack = UIStackView(

            arrangedSubviews: [

                titleStack,

                bulletStack

            ]

        )

        innerStack.translatesAutoresizingMaskIntoConstraints = false

        innerStack.axis = .vertical

        innerStack.spacing = 14

        card.addSubview(innerStack)



        NSLayoutConstraint.activate([

            innerStack.topAnchor.constraint(

                equalTo: card.topAnchor,

                constant: 20

            ),

            innerStack.leadingAnchor.constraint(

                equalTo: card.leadingAnchor,

                constant: 20

            ),

            innerStack.trailingAnchor.constraint(

                equalTo: card.trailingAnchor,

                constant: -20

            ),

            innerStack.bottomAnchor.constraint(

                equalTo: card.bottomAnchor,

                constant: -20

            )

        ])

        stackView.addArrangedSubview(card)
        return card

    }



    // MARK: - UI Helpers

    private func makeRelationshipThemeGrid(

        _ items: [String]

    ) -> UIView {

        let scrollView = UIScrollView()

        scrollView.translatesAutoresizingMaskIntoConstraints =

            false

        scrollView.showsHorizontalScrollIndicator =

            false

        scrollView.showsVerticalScrollIndicator =

            false

        scrollView.alwaysBounceHorizontal =

            true



        let pillStack = UIStackView()

        pillStack.translatesAutoresizingMaskIntoConstraints =

            false

        pillStack.axis = .horizontal

        pillStack.spacing = 8

        pillStack.alignment = .fill

        pillStack.distribution = .fill



        for item in items {

            pillStack.addArrangedSubview(

                makeRelationshipThemePill(

                    item

                )

            )

        }



        scrollView.addSubview(

            pillStack

        )



        NSLayoutConstraint.activate([

            scrollView.heightAnchor.constraint(

                equalToConstant: 36

            ),



            pillStack.topAnchor.constraint(

                equalTo:

                    scrollView.contentLayoutGuide.topAnchor

            ),

            pillStack.bottomAnchor.constraint(

                equalTo:

                    scrollView.contentLayoutGuide.bottomAnchor

            ),

            pillStack.leadingAnchor.constraint(

                equalTo:

                    scrollView.contentLayoutGuide.leadingAnchor

            ),

            pillStack.trailingAnchor.constraint(

                equalTo:

                    scrollView.contentLayoutGuide.trailingAnchor

            ),

            pillStack.heightAnchor.constraint(

                equalTo:

                    scrollView.frameLayoutGuide.heightAnchor

            )

        ])



        return scrollView

    }



    private func makeRelationshipThemePill(

        _ text: String

    ) -> UIView {

        let container = UIView()

        container.backgroundColor =

            UIColor(hex: "#F3E5FB")

        container.layer.cornerRadius =

            14



        let label = UILabel()

        label.translatesAutoresizingMaskIntoConstraints =

            false

        label.text = text

        label.font = .systemFont(

            ofSize: 13,

            weight: .semibold

        )

        label.textColor =

            UIColor(hex: "#9A5DB9")

        label.textAlignment =

            .center

        label.numberOfLines = 1

        label.adjustsFontSizeToFitWidth =

            true

        label.minimumScaleFactor =

            0.82



        container.addSubview(

            label

        )



        NSLayoutConstraint.activate([

            label.topAnchor.constraint(

                equalTo:

                    container.topAnchor,

                constant: 8

            ),

            label.bottomAnchor.constraint(

                equalTo:

                    container.bottomAnchor,

                constant: -8

            ),

            label.leadingAnchor.constraint(

                equalTo:

                    container.leadingAnchor,

                constant: 10

            ),

            label.trailingAnchor.constraint(

                equalTo:

                    container.trailingAnchor,

                constant: -10

            )

        ])



        return container

    }

    private func makeIconCircle(

        icon: String,

        color: UIColor

    ) -> UIView {

        let circle = UIView()

        circle.translatesAutoresizingMaskIntoConstraints = false

        circle.backgroundColor = color

        circle.layer.cornerRadius = 25



        let label = UILabel()

        label.translatesAutoresizingMaskIntoConstraints = false

        label.text = icon

        label.textAlignment = .center

        label.textColor = .white

        label.font = .systemFont(

            ofSize: 26,

            weight: .regular

        )

        circle.addSubview(label)



        NSLayoutConstraint.activate([

            circle.widthAnchor.constraint(

                equalToConstant: 50

            ),

            circle.heightAnchor.constraint(

                equalToConstant: 50

            ),

            label.centerXAnchor.constraint(

                equalTo: circle.centerXAnchor

            ),

            label.centerYAnchor.constraint(

                equalTo: circle.centerYAnchor

            )

        ])

        return circle

    }

    private func makeBeautyMirrorIcon() -> UIView {

        let container = UIView()

        container.translatesAutoresizingMaskIntoConstraints = false

        let imageView = UIImageView(

            image: UIImage(named: "beauty_mirror_icon")?

                .withRenderingMode(.alwaysOriginal)

        )

        imageView.translatesAutoresizingMaskIntoConstraints = false

        imageView.contentMode = .scaleAspectFit

        imageView.clipsToBounds = false

        container.addSubview(imageView)

        NSLayoutConstraint.activate([

            container.widthAnchor.constraint(equalToConstant: 50),

            container.heightAnchor.constraint(equalToConstant: 50),

            imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),

            imageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            imageView.widthAnchor.constraint(equalToConstant: 48),

            imageView.heightAnchor.constraint(equalToConstant: 48)

        ])

        return container

    }



    private func makeBodyLabel(

        text: String,

        weight: UIFont.Weight

    ) -> UILabel {

        let label = UILabel()

        label.text = text

        label.numberOfLines = 0

        label.font = .systemFont(

            ofSize: 15.5,

            weight: weight

        )

        label.textColor =

        UIColor(hex: "#5F5265")

        return label

    }



    private func makeBulletStack(

        _ items: [String]

    ) -> UIStackView {

        let stack = UIStackView()

        stack.axis = .vertical

        stack.spacing = 9



        for item in items {

            let bullet = UILabel()

            bullet.text = "•"

            bullet.textColor =

            UIColor(hex: "#ED4AA7")

            bullet.font = .systemFont(

                ofSize: 18,

                weight: .bold

            )

            bullet.setContentHuggingPriority(

                .required,

                for: .horizontal

            )



            let text = makeBodyLabel(

                text: item,

                weight: .medium

            )



            let row = UIStackView(

                arrangedSubviews: [

                    bullet,

                    text

                ]

            )

            row.axis = .horizontal

            row.spacing = 9

            row.alignment = .top

            stack.addArrangedSubview(row)

        }

        return stack

    }



    private func makeAstroPill(

        text: String

    ) -> UIView {

        let container = UIView()

        container.backgroundColor =

        UIColor(hex: "#D9AED9")

            .withAlphaComponent(0.55)

        container.layer.cornerRadius = 15



        let label = UILabel()

        label.translatesAutoresizingMaskIntoConstraints = false

        label.text = text

        label.font = .systemFont(

            ofSize: 14,

            weight: .medium

        )

        label.textColor = .white

        label.numberOfLines = 0

        container.addSubview(label)



        NSLayoutConstraint.activate([

            label.topAnchor.constraint(

                equalTo: container.topAnchor,

                constant: 6

            ),

            label.bottomAnchor.constraint(

                equalTo: container.bottomAnchor,

                constant: -6

            ),

            label.leadingAnchor.constraint(

                equalTo: container.leadingAnchor,

                constant: 13

            ),

            label.trailingAnchor.constraint(

                equalTo: container.trailingAnchor,

                constant: -13

            )

        ])

        return container

    }



    // MARK: - Astro Text

    private func importantAstroTexts() -> [String] {

        let localization =

        AstroLocalizationService.shared

        var result: [String] = []



        for signal in data.astro.astroSignals {

            switch signal.type {

            case "planet_status":

                guard

                    let planet = signal.planet,

                    let status = signal.status

                else {

                    continue

                }

                result.append(

                    localization.planetStatusText(

                        planet: planet,

                        status: status

                    )

                )



            case "aspect":

                guard

                    let pair = signal.planetPair,

                    pair.count >= 2,

                    let aspect = signal.aspectType

                else {

                    continue

                }

                result.append(

                    localization.aspectText(

                        planet1: pair[0],

                        planet2: pair[1],

                        aspect: aspect

                    )

                )



            case "lunar_condition":

                guard let condition =

                        signal.condition

                else {

                    continue

                }

                result.append(

                    localization.lunarConditionText(

                        condition

                    )

                )



            case "eclipse":

                guard let event =

                        signal.event

                else {

                    continue

                }

                result.append(

                    localization.eclipseText(

                        event

                    )

                )



            case "moon_next_aspect":

                guard let value =

                        signal.value

                else {

                    continue

                }

                result.append(

                    localization.moonNextAspectText(

                        value

                    )

                )



            default:

                continue

            }

        }

        return result

    }



    private func referenceDateForSelectedDay() -> Date {

        let calendar =

            Self.istanbulCalendar

        let realNow =

            Date()

        let timeComponents =

            calendar.dateComponents(

                [

                    .hour,

                    .minute,

                    .second

                ],

                from: realNow

            )

        return calendar.date(

            bySettingHour:

                timeComponents.hour ?? 12,

            minute:

                timeComponents.minute ?? 0,

            second:

                timeComponents.second ?? 0,

            of:

                selectedDate

        ) ?? selectedDate

    }



    // MARK: - Astro Helper

    private struct MoonSignDisplayInfo {

        let title: String

        let detailMessage: String

    }

    private func moonSignDisplayInfo() -> MoonSignDisplayInfo? {

        let localization = AstroLocalizationService.shared

        let formatter = ISO8601DateFormatter()

        let moonSignSignals = data.astro.astroSignals

            .filter {

                $0.type == "moon_sign" &&

                $0.value != nil

            }

            .sorted { first, second in

                guard

                    let firstStartAt = first.startAt,

                    let secondStartAt = second.startAt,

                    let firstDate = formatter.date(from: firstStartAt),

                    let secondDate = formatter.date(from: secondStartAt)

                else {

                    return false

                }

                return firstDate < secondDate

            }

        guard let firstSignal = moonSignSignals.first,

              let firstSign = firstSignal.value else {

            return nil

        }

        let firstName = localization.sign(firstSign)

        // O gün Ay burcu değişmiyorsa

        guard moonSignSignals.count >= 2 else {

            return MoonSignDisplayInfo(

                title: "Ay Burcu \(firstName)",

                detailMessage: moonSignInfo(

                    for: firstSign,

                    displayName: firstName

                )

            )

        }

        let secondSignal = moonSignSignals[1]

        guard let secondSign = secondSignal.value else {

            return MoonSignDisplayInfo(

                title: "Ay Burcu \(firstName)",

                detailMessage: moonSignInfo(

                    for: firstSign,

                    displayName: firstName

                )

            )

        }

        let secondName = localization.sign(secondSign)

        // Geçiş saati

        var transitionTimeText: String?

        if let startAt = secondSignal.startAt,

           let transitionDate = formatter.date(from: startAt) {

            let timeFormatter = DateFormatter()

            timeFormatter.locale = Locale(identifier: "tr_TR")

            timeFormatter.timeZone = TimeZone(

                identifier: "Europe/Istanbul"

            )

            timeFormatter.dateFormat = "HH:mm"

            transitionTimeText =

                timeFormatter.string(from: transitionDate)

        }

        let transitionText: String

        if let transitionTimeText {

            transitionText =

                "Ay bugün \(transitionTimeText)’e kadar \(firstName) burcunda, \(transitionTimeText)’den sonra \(secondName) burcuna geçiyor."

        } else {

            transitionText =

                "Ay bugün \(firstName) burcundan \(secondName) burcuna geçiyor."

        }

        let firstInfo = moonSignInfo(

            for: firstSign,

            displayName: firstName

        )

        let secondInfo = moonSignInfo(

            for: secondSign,

            displayName: secondName

        )

        return MoonSignDisplayInfo(

            title: "Ay \(firstName) → \(secondName)",

            detailMessage:

                """

                \(transitionText)

                \(firstInfo)

                Geçişten sonra:

                \(secondInfo)

                """

        )

    }

    private func currentAstroValue(

        type: String

    ) -> String? {

        let signals =

        data.astro.astroSignals.filter {

            $0.type == type

        }

        guard !signals.isEmpty else {

            return nil

        }



        let now = referenceDateForSelectedDay()

        let formatter =

        ISO8601DateFormatter()



        for signal in signals {

            guard

                let startAt = signal.startAt,

                let endAt = signal.endAt,

                let start =

                    formatter.date(from: startAt),

                let end =

                    formatter.date(from: endAt)

            else {

                continue

            }

            if now >= start && now < end {

                return signal.value

            }

        }



        return signals.first?.value

    }

    private var mercuryRetrogradeInfo: String {

        """

        Merkür retrosunu; iletişim, planlar ve günlük detayların biraz daha fazla dikkat isteyebildiği bir dönem gibi düşünebilirsin.

        Yanlış anlaşılmalar veya son anda değişen planlar daha görünür olabilir. Bu, her şeyin ters gideceği anlamına gelmez.

        ✨ Deneyebilirsin:

        Önemli mesaj, randevu ve planlarını kesinleştirmeden önce bir kez daha kontrol et.

        """

    }

    private var venusRetrogradeInfo: String {

        """

        Venüs retrosunu; ilişkiler, değer verdiğin şeyler ve kendinle olan bağını yeniden değerlendirebildiğin bir dönem gibi düşünebilirsin.

        Sana gerçekten neyin iyi geldiğini biraz daha fazla düşünmek isteyebilirsin.

        ✨ Deneyebilirsin:

        Kendine “Şu anda bana gerçekten iyi gelen şey ne?” diye sor.

        """

    }

    private var marsRetrogradeInfo: String {

        """

        Mars retrosunu, enerjini nasıl kullandığını ve ne için çaba gösterdiğini yeniden değerlendirebildiğin bir dönem gibi düşünebilirsin.

        Her şeyi aynı hızda yapmak yerine enerjini gerçekten önemli olan yerlere yönlendirmek iyi gelebilir.

        ✨ Deneyebilirsin:

        Bugün gerçekten önemli olan tek bir şeyi seç ve önce ona odaklan.

        """

    }

    private var saturnRetrogradeInfo: String {

        """

        Satürn retrosunu; sorumluluklarını, sınırlarını ve hayatındaki düzeni yeniden gözden geçirebildiğin bir dönem gibi düşünebilirsin.

        Her şeyi bir anda düzeltmek zorunda değilsin. Küçük ama sürdürülebilir değişikliklere yönelmek iyi gelebilir.

        ✨ Deneyebilirsin:

        Uzun zamandır ertelediğin küçük bir konunun yalnızca ilk adımını at.

        """

    }

    private var newMoonInfo: String {

        """

        Yeni Ay, önündeki dönem için yeni bir niyet belirlemek ve hayatında neye daha fazla yer vermek istediğini düşünmek için güzel bir zaman olabilir.

        Büyük değişiklikler yapmak zorunda değilsin.

        ✨ Deneyebilirsin:

        Önümüzdeki günler için tek bir niyet seç ve onun için atabileceğin en küçük adımı belirle.

        """

    }

    private var fullMoonInfo: String {

        """

        Dolunay, son haftalarda gelişen konuları ve tamamlanmaya yaklaşan şeyleri biraz daha net fark edebileceğin bir dönem olabilir.

        Bir şeyi bırakmak veya değiştirmek zorunda değilsin; önce ne hissettiğini fark etmek yeterli.

        ✨ Deneyebilirsin:

        Son birkaç haftada neyin değiştiğini kendine sor.

        """

    }

    private var lunarEclipseInfo: String {

        """

        Ay Tutulmasını, duyguların ve bir süredir arka planda kalan bazı konuların daha görünür olabildiği bir farkındalık zamanı gibi düşünebilirsin.

        Her şeyi hemen çözmek zorunda değilsin.

        ✨ Deneyebilirsin:

        Kendine “Şu anda içimde en çok ne dikkatimi istiyor?” diye sor.

        """

    }

    private var solarEclipseInfo: String {

        """

        Güneş Tutulmasını, hayatında yeni yönleri ve değişen ihtiyaçlarını fark etmek için bir gözlem zamanı gibi düşünebilirsin.

        Hemen büyük bir karar almak zorunda değilsin.

        ✨ Deneyebilirsin:

        Önümüzdeki dönemde hayatında neye daha fazla yer vermek istediğini düşün.

        """

    }

    private func moonSignInfo(

        for sign: String,

        displayName: String

    ) -> String {

        let theme: String

        switch sign {

        case "aries":

            theme =

                "hareket etmek, cesaret göstermek ve bir konuda ilk adımı atmak"

        case "taurus":

            theme =

                "yavaşlamak, konforunu önemsemek ve sana güven veren şeylere dönmek"

        case "gemini":

            theme =

                "konuşmak, merak etmek, bilgi toplamak ve zihinsel olarak hareketli olmak"

        case "cancer":

            theme =

                "duygusal ihtiyaçlarını fark etmek, evine ve kendine biraz daha alan ayırmak"

        case "leo":

            theme =

                "kendini ifade etmek, yaratıcı olmak ve seni canlı hissettiren şeylere yönelmek"

        case "virgo":

            theme =

                "düzen kurmak, küçük detayları toparlamak ve günlük hayatını sadeleştirmek"

        case "libra":

            theme =

                "ilişkilerindeki dengeyi fark etmek, güzellik ve uyum ihtiyacına yer açmak"

        case "scorpio":

            theme =

                "duygularının altında ne olduğunu fark etmek ve biraz daha derine bakmak"

        case "sagittarius":

            theme =

                "yeni fikirler keşfetmek, perspektifini genişletmek ve biraz hareket etmek"

        case "capricorn":

            theme =

                "sorumluluklarına, hedeflerine ve somut olarak ilerletmek istediğin şeylere odaklanmak"

        case "aquarius":

            theme =

                "alışılmışın dışında düşünmek, sosyal çevrenle bağlantı kurmak ve yeni fikirleri değerlendirmek"

        case "pisces":

            theme =

                "biraz yavaşlamak, sezgilerine kulak vermek ve kendine daha yumuşak davranmak"

        default:

            theme =

                "bugünkü duygusal ihtiyaçlarını biraz daha yakından fark etmek"

        }

        return """

        Ay bugün \(displayName) burcunda ilerliyor.

        Günün duygusal ritminde \(theme) daha doğal gelebilir. Bunu bir zorunluluk gibi değil, bugün kendinde daha kolay fark edebileceğin bir eğilim gibi düşünebilirsin.

        ✨ Deneyebilirsin:

        Bugünün temposunda sana gerçekten neyin iyi geldiğini fark etmek için kendine küçük bir alan bırak.

        """

    }

}
