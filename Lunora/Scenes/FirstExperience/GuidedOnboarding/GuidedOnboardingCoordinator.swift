//
//  GuidedOnboardingCoordinator.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 28.08.2026.
//

import UIKit


// MARK: - Coach Mark Content

struct GuidedCoachContent {

    let title: String
    let body: String
    let primaryTitle: String
    let placement: LunoraCoachMarkView.Placement

    init(
        title: String,
        body: String,
        primaryTitle: String = "Devam et",
        placement: LunoraCoachMarkView.Placement = .above
    ) {
        self.title = title
        self.body = body
        self.primaryTitle = primaryTitle
        self.placement = placement
    }
}


// MARK: - Guided Onboarding Coordinator

final class GuidedOnboardingCoordinator {

    static let shared =
        GuidedOnboardingCoordinator()

    private init() {}


    // MARK: - Content

    private func content(
        for step: GuidedOnboardingStep
    ) -> GuidedCoachContent? {

        switch step {

        case .dailySkyCard:
            return GuidedCoachContent(
                title:
                    "Her gün buradan başlayabilirsin 🌙",
                body:
                    """
                    Gününün enerjisini; ilişkilerine, bakımına ve günlük rutinlerine nasıl yansıtabileceğini Günün Gökyüzü’nde görebilirsin.
                    """,
                primaryTitle:
                    "Bugünü keşfet",
                placement:
                    .below
            )


        case .dailySkyOverview:
            return GuidedCoachContent(
                title:
                    "Bugünün gökyüzü 🌙",
                body:
                    """
                    Mor kartta bugünkü gökyüzü hareketlerini, "Bugünün Enerjisi" kartında ise günün enerji yorumunu bulursun.
                    """,
                placement:
                    .above
            )


        case .dailySkyActions:
            return GuidedCoachContent(
                title:
                    "Gökyüzünü küçük adımlara çevirebilirsin. ✨",
                body:
                    """
                    Bugün Bunları Yapabilirsin bölümünde, günün gökyüzüne uygun günlük önerileri bulabilirsin. Sana iyi gelen bir tanesini seçmen yeter.
                    """,
                placement:
                    .above
            )


        case .dailySkyAvoid:
            return GuidedCoachContent(
                title:
                    "Bugün neyi zorlamamak iyi olabilir? 🌿",
                body:
                    """
                    Bugün biraz dikkat bölümünde, acele etmemek veya daha bilinçli yaklaşmak isteyebileceğin noktaları görebilirsin.
                    """,
                placement:
                    .above
            )


        case .dailySkyRelationships:
            return GuidedCoachContent(
                title:
                    "İlişkilerde bugünü daha yakından görebilirsin. 💗",
                body:
                    """
                    İlişkilerde Bugün bölümünde, günün temasının duygularına, ihtiyaçlarına ve sınırlarına nasıl yansıyabileceğini görebilirsin.
                    """,
                placement:
                    .above
            )


        case .dailySkyBeauty:
            return GuidedCoachContent(
                title:
                    "Bakımını günün ritmine göre planlayabilirsin. ✨",
                body:
                    """
                    Güzellik & Bakım bölümünde, bugün öne çıkan bakım önerilerini ve daha temkinli yaklaşabileceğin başlıkları görebilirsin.
                    """,
                placement:
                    .above
            )


        case .dailySkyUpcoming:
            return GuidedCoachContent(
                title:
                    "Biraz da önümüzdeki günlere bakalım. 🔮",
                body:
                    """
                    Yaklaşan Gökyüzü bölümünde, önümüzdeki günlerde öne çıkan önemli gökyüzü hareketlerini görebilirsin.
                    """,
                placement:
                    .above
            )


        case .programCard:
            return GuidedCoachContent(
                title:
                    "Sana iyi gelecek bir yolculuk seç ✨",
                body:
                    """
                    Programlar, bir konuyu gün gün küçük adımlarla çalışmana yardımcı olur. Sana uygun görünen bir programın detaylarını buradan keşfedebilirsin.
                    """,
                primaryTitle:
                    "Programı keşfet",
                placement:
                    .above
            )

        case .programDetail:
            return GuidedCoachContent(
                title:
                    "Programı yakından tanıyabilirsin 🌷",
                body:
                    """
                    Bu sayfada programın amacını, seni bekleyen adımları ve yolculuk boyunca neler kazanabileceğini inceleyebilirsin.
                    """,
                primaryTitle:
                    "İlerlemeyi gör",
                placement:
                    .above
            )


        case .todayTasks:
            return GuidedCoachContent(
                title:
                    "Bugünün küçük adımları burada ✨",
                body:
                    """
                    Her gün programına ait görevleri burada görebilir ve tamamladıkça yolculuğunu ilerletebilirsin.
                    """,
                placement:
                    .above
            )


        case .programProgress:
            return GuidedCoachContent(
                title:
                    "İlerlemen burada birikecek ✨",
                body:
                    """
                    Bir programa başladığında tamamladığın günleri, serini ve programdaki ilerlemeni bu ekrandan takip edebilirsin.
                    """,
                primaryTitle:
                    "Devam Et",
                placement:
                    .below
            )

        case .completed:
            return GuidedCoachContent(
                title:
                    "Başarıların burada birikecek 🌸",
                body:
                    """
                    Tamamladığın programları, kazandığın rozetleri ve yolculuğun boyunca büyüyen başarılarını burada görebilirsin.
                    """,
                primaryTitle:
                    "Devam Et",
                placement:
                    .above
            )
        }
    }


    // MARK: - Present

    @discardableResult
    func present(
        uid: String,
        step: GuidedOnboardingStep,
        over hostView: UIView,
        targetView: UIView,
        advanceOnPrimary: Bool = true,
        onPrimary: (() -> Void)? = nil,
        onSkip: (() -> Void)? = nil
    ) -> LunoraCoachMarkView? {

        guard
            let content = content(
                for: step
            )
        else {
            return nil
        }

        let coachMark =
            LunoraCoachMarkView.present(
                over: hostView,
                targetView: targetView,
                placement:
                    content.placement,
                title:
                    content.title,
                body:
                    content.body,
                primaryTitle:
                    content.primaryTitle,
                onPrimary: {

                    if advanceOnPrimary {

                        GuidedOnboardingManager
                            .shared
                            .advance(
                                for: uid
                            )
                    }

                    onPrimary?()
                },
                onSkip: {

                    GuidedOnboardingManager
                        .shared
                        .finish(
                            for: uid
                        )

                    onSkip?()
                }
            )

        return coachMark
    }
}
