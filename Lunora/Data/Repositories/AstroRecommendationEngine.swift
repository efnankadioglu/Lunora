//
//  AstroRecommendationEngine.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 21.08.2026.
//

import Foundation

final class AstroRecommendationEngine {

    static let shared = AstroRecommendationEngine()

    private init() {}

    // MARK: - Internal Models

    private struct MatchedRule {
        let rule: AstroRuleDefinition
        let signals: [AstroSignal]
    }

    private struct TagBuckets {

        var primary: Double = 0
        var aspect: Double = 0
        var secondary: Double = 0
        var planetStatus: Double = 0

        // Future direct-status rules için ayrı tutuluyor.
        var directStatusPositive: Double = 0
    }

    // MARK: - Public

    func rank(
        astro: DailyAstroDataDay,
        activities: [AstroActivity],
        rulesFile: AstroRulesFile,
        at date: Date = Date()
    ) -> [RankedAstroActivity] {

        let signals = activeSignals(
            astro.astroSignals,
            at: date
        )

        var matchedRules = rulesFile.rules.compactMap { rule -> MatchedRule? in

            let matches = matchingSignals(
                for: rule,
                in: signals
            )

            guard !matches.isEmpty else {
                return nil
            }

            return MatchedRule(
                rule: rule,
                signals: matches
            )
        }

        // Eclipse gibi replacement rule varsa,
        // replace ettiği normal rule uygulanmaz.
        let replacedRuleIDs = Set(
            matchedRules.flatMap {
                $0.rule.replaces ?? []
            }
        )

        matchedRules.removeAll {
            replacedRuleIDs.contains(
                $0.rule.id
            )
        }

        print(
            "🧠 Aktif astro rule'ları:",
            matchedRules.map { $0.rule.id }
        )

        let ranked = activities.map { activity in

            score(
                activity: activity,
                matchedRules: matchedRules,
                rulesFile: rulesFile
            )
        }

        return ranked.sorted {

            if $0.eligible != $1.eligible {
                return $0.eligible && !$1.eligible
            }

            if $0.astroFitScore != $1.astroFitScore {
                return $0.astroFitScore > $1.astroFitScore
            }

            return $0.activity.id < $1.activity.id
        }
    }

    // MARK: - Activity Score

    private func score(
        activity: AstroActivity,
        matchedRules: [MatchedRule],
        rulesFile: AstroRulesFile
    ) -> RankedAstroActivity {

        let policy = rulesFile.scoringPolicy
        let aggregation = policy.aggregation

        let baseScore = policy.baseScore

        var actionBuckets =
            makeBuckets(for: activity.actions)

        var topicBuckets =
            makeBuckets(for: activity.topics)

        var contextBuckets =
            makeBuckets(for: activity.context)

        var relationshipBuckets =
            makeBuckets(
                for: activity.relationshipModes
            )

        var strongNegativeRuleIDs =
            Set<String>()

        var suppressionReasons =
            Set<String>()

        var conditionalModifier: Double = 0

        // MARK: Apply matched rules

        for matched in matchedRules {

            let rule = matched.rule

            apply(
                modifiers: rule.modifiers.actions,
                to: &actionBuckets,
                rule: rule
            )

            apply(
                modifiers: rule.modifiers.topics,
                to: &topicBuckets,
                rule: rule
            )

            apply(
                modifiers: rule.modifiers.contexts,
                to: &contextBuckets,
                rule: rule
            )

            apply(
                modifiers:
                    rule.modifiers.relationshipModes,
                to: &relationshipBuckets,
                rule: rule
            )

            // Strong negative:
            // Primary rule, action veya required
            // relationship mode üzerinde <= -2.
            if rule.role == "primary" {

                let negativeActionMatch =
                    rule.modifiers.actions.contains {
                        key, value in

                        value <= -2 &&
                        activity.actions.contains(key)
                    }

                let negativeRelationshipMatch =
                    rule.modifiers
                        .relationshipModes
                        .contains {
                            key, value in

                            value <= -2 &&
                            activity
                                .relationshipModes
                                .contains(key)
                        }

                if negativeActionMatch ||
                    negativeRelationshipMatch {

                    strongNegativeRuleIDs.insert(
                        rule.id
                    )
                }
            }

            // Planet profile effect
            applyPlanetProfileEffect(
                matchedRule: matched,
                activity: activity,
                rulesFile: rulesFile,
                actionBuckets: &actionBuckets,
                topicBuckets: &topicBuckets,
                relationshipBuckets:
                    &relationshipBuckets
            )

            // Conditional activity modifiers
            if let conditionals =
                rule.conditionalActivityRules {

                for conditional in conditionals {

                    guard conditionalMatches(
                        conditional.when,
                        activity: activity
                    ) else {
                        continue
                    }

                    let value =
                        conditional.activityModifier

                    // -4 = arithmetic modifier değil,
                    // hard suppression control signal.
                    if value == -4 {

                        if conditional
                            .hardBlockAllowed != false {

                            suppressionReasons.insert(
                                rule.id
                            )
                        }

                        continue
                    }

                    conditionalModifier +=
                        Double(value)

                    if rule.role == "primary",
                       value <= -2,
                       conditional
                        .hardBlockAllowed != false {

                        strongNegativeRuleIDs.insert(
                            rule.id
                        )
                    }
                }
            }
        }

        // MARK: Direct-status activity cap

        let directPositiveTotal =
            totalDirectPositive(
                actionBuckets,
                topicBuckets,
                contextBuckets,
                relationshipBuckets
            )

        let directCap = Double(
            aggregation
                .directStatusTotalBonusCapPerActivity
        )

        let directScale: Double

        if directPositiveTotal > directCap,
           directPositiveTotal > 0 {

            directScale =
                directCap / directPositiveTotal

        } else {

            directScale = 1
        }

        // MARK: Final Tag Scores

        let actionScores = finalize(
            buckets: actionBuckets,
            baseScore: baseScore,
            aggregation: aggregation,
            directScale: directScale
        )

        let topicScores = finalize(
            buckets: topicBuckets,
            baseScore: baseScore,
            aggregation: aggregation,
            directScale: directScale
        )

        let contextScores = finalize(
            buckets: contextBuckets,
            baseScore: baseScore,
            aggregation: aggregation,
            directScale: directScale
        )

        let relationshipScores = finalize(
            buckets: relationshipBuckets,
            baseScore: baseScore,
            aggregation: aggregation,
            directScale: directScale
        )

        // MARK: Weighted Astro Fit

        let useRelationshipFormula =
            !activity.relationshipModes.isEmpty

        let weights =
            useRelationshipFormula
            ? aggregation.rankingFormula.relationship
            : aggregation.rankingFormula
                .nonRelationship

        var dimensions:
            [String: Double] = [:]

        if let mean = mean(
            actionScores.values
        ) {
            dimensions["actions"] = mean
        }

        if let mean = mean(
            topicScores.values
        ) {
            dimensions["topics"] = mean
        }

        if let mean = mean(
            contextScores.values
        ) {
            dimensions["contexts"] = mean
        }

        if useRelationshipFormula,
           let mean = mean(
                relationshipScores.values
           ) {

            dimensions[
                "relationship_modes"
            ] = mean
        }

        let availableWeightTotal =
            dimensions.keys.reduce(0.0) {
                partialResult, key in

                partialResult +
                (weights[key] ?? 0)
            }

        var astroFitScore: Double

        if availableWeightTotal > 0 {

            let weighted =
                dimensions.reduce(0.0) {
                    partialResult,
                    element in

                    let key = element.key
                    let value = element.value

                    let weight =
                        weights[key] ?? 0

                    return partialResult +
                        (
                            value *
                            weight /
                            availableWeightTotal
                        )
                }

            astroFitScore = weighted

        } else {

            astroFitScore = baseScore
        }

        // MARK: Conditional modifier cap

        let conditionalCap =
            aggregation
                .conditionalActivityModifierTotalCap

        if conditionalCap.count >= 2 {

            conditionalModifier = clamp(
                conditionalModifier,
                min: Double(
                    conditionalCap[0]
                ),
                max: Double(
                    conditionalCap[1]
                )
            )
        }

        astroFitScore += conditionalModifier

        // MARK: Eligibility

        var eligible =
            suppressionReasons.isEmpty

        // Critical action gate

        if let gate =
            aggregation
                .criticalActionGateByIntensity[
                    activity.intensity
                ],
           let minimum =
            gate.minimumScore {

            let criticalActions =
                activity.actions.filter {
                    aggregation
                        .criticalActions
                        .contains($0)
                }

            for action in criticalActions {

                let score =
                    actionScores[action] ??
                    baseScore

                if score < minimum {

                    eligible = false

                    suppressionReasons.insert(
                        "critical_action_gate:\(action)"
                    )
                }
            }
        }

        // Strong negative convergence
        // low intensity bununla gizlenmez.

        if activity.intensity == "medium" ||
            activity.intensity == "high" {

            if strongNegativeRuleIDs.count >= 2 {

                eligible = false

                suppressionReasons.insert(
                    "strong_negative_convergence"
                )
            }
        }

        // Relationship-mode gate

        if !activity.relationshipModes.isEmpty,
           let gate =
            aggregation.relationshipModeGate[
                activity.intensity
            ],
           let threshold =
            gate.relationshipModeThreshold,
           !strongNegativeRuleIDs.isEmpty {

            for mode in
                activity.relationshipModes {

                let score =
                    relationshipScores[mode] ??
                    baseScore

                if score <= threshold {

                    eligible = false

                    suppressionReasons.insert(
                        "relationship_mode_gate:\(mode)"
                    )
                }
            }
        }

        // MARK: Clamp + Round

        if policy.finalScoreRange.count >= 2 {

            astroFitScore = clamp(
                astroFitScore,
                min:
                    policy.finalScoreRange[0],
                max:
                    policy.finalScoreRange[1]
            )
        }

        astroFitScore = round(
            astroFitScore,
            decimals:
                policy.scorePrecisionDecimals
        )

        let scoreBreakdown = AstroScoreBreakdown(
            contributions: [],
            dimensionScores: dimensions,
            conditionalModifier: conditionalModifier
        )

        return RankedAstroActivity(
            activity: activity,
            astroFitScore: astroFitScore,
            eligible: eligible,
            suppressionReasons:
                Array(
                    suppressionReasons
                ).sorted(),
            strongNegativeRuleIds:
                Array(
                    strongNegativeRuleIDs
                ).sorted(),
            scoreBreakdown: scoreBreakdown
        )
    }

    // MARK: - Rule Matching

    private func matchingSignals(
        for rule: AstroRuleDefinition,
        in signals: [AstroSignal]
    ) -> [AstroSignal] {

        let match = rule.match

        // Lunar condition

        if let condition = match.condition {

            return signals.filter {
                $0.type == "lunar_condition" &&
                $0.condition == condition
            }
        }

        // Eclipse

        if let event = match.event {

            return signals.filter {
                $0.type == "eclipse" &&
                $0.event == event
            }
        }

        // Moon next aspect

        if let next =
            match.moonNextAspect {

            return signals.filter {
                $0.type == "moon_next_aspect" &&
                $0.value == next
            }
        }

        // Moon phase

        if let moonPhase =
            match.moonPhase {

            return signals.filter {
                $0.type == "moon_phase" &&
                $0.value == moonPhase
            }
        }

        // Moon sign

        if let moonSign =
            match.moonSign {

            return signals.filter {
                $0.type == "moon_sign" &&
                $0.value == moonSign
            }
        }

        // Planet status

        if let status = match.status {

            return signals.filter { signal in

                guard
                    signal.type ==
                        "planet_status",
                    signal.status == status
                else {
                    return false
                }

                guard let planet =
                        match.planet
                else {
                    return true
                }

                if planet == "*" {
                    return true
                }

                return signal.planet ==
                    planet
            }
        }

        // Aspect

        if let pair =
            match.planetPair,
           let aspectTypes =
            match.aspectTypes {

            return signals.filter { signal in

                guard
                    signal.type == "aspect",
                    let signalPair =
                        signal.planetPair,
                    let aspect =
                        signal.aspectType
                else {
                    return false
                }

                return samePair(
                    pair,
                    signalPair
                ) &&
                aspectTypes.contains(
                    aspect
                )
            }
        }

        return []
    }

    // MARK: - Rule Modifier Application

    private func apply(
        modifiers: [String: Int],
        to buckets:
            inout [String: TagBuckets],
        rule: AstroRuleDefinition
    ) {

        for (tag, value) in modifiers {

            guard var bucket =
                    buckets[tag]
            else {
                continue
            }

            add(
                Double(value),
                to: &bucket,
                rule: rule
            )

            buckets[tag] = bucket
        }
    }

    private func add(
        _ value: Double,
        to bucket: inout TagBuckets,
        rule: AstroRuleDefinition
    ) {

        if rule.category == "aspect" {

            bucket.aspect += value
            return
        }

        if rule.category ==
            "planet_status" {

            if rule.match.status == "direct",
               value > 0 {

                bucket
                    .directStatusPositive +=
                    value

            } else {

                bucket.planetStatus += value
            }

            return
        }

        if rule.role == "secondary" {

            bucket.secondary += value
            return
        }

        bucket.primary += value
    }

    // MARK: - Planet Profile

    private func applyPlanetProfileEffect(
        matchedRule: MatchedRule,
        activity: AstroActivity,
        rulesFile: AstroRulesFile,
        actionBuckets:
            inout [String: TagBuckets],
        topicBuckets:
            inout [String: TagBuckets],
        relationshipBuckets:
            inout [String: TagBuckets]
    ) {

        let rule = matchedRule.rule

        guard
            rule.match.usePlanetProfile == true,
            let effect =
                rule.profileEffect
        else {
            return
        }

        let planets = Set(
            matchedRule.signals.compactMap {
                $0.planet
            }
        )

        for planet in planets {

            guard let profile =
                rulesFile.planetProfiles[
                    planet
                ]
            else {
                continue
            }

            if let value = effect.actions {

                for tag in profile.actions {

                    guard
                        activity.actions
                            .contains(tag),
                        var bucket =
                            actionBuckets[tag]
                    else {
                        continue
                    }

                    add(
                        Double(value),
                        to: &bucket,
                        rule: rule
                    )

                    actionBuckets[tag] =
                        bucket
                }
            }

            if let value = effect.topics {

                for tag in profile.topics {

                    guard
                        activity.topics
                            .contains(tag),
                        var bucket =
                            topicBuckets[tag]
                    else {
                        continue
                    }

                    add(
                        Double(value),
                        to: &bucket,
                        rule: rule
                    )

                    topicBuckets[tag] =
                        bucket
                }
            }

            if let value =
                effect.relationshipModes {

                for tag in
                    profile.relationshipModes {

                    guard
                        activity
                            .relationshipModes
                            .contains(tag),
                        var bucket =
                            relationshipBuckets[
                                tag
                            ]
                    else {
                        continue
                    }

                    add(
                        Double(value),
                        to: &bucket,
                        rule: rule
                    )

                    relationshipBuckets[tag] =
                        bucket
                }
            }
        }
    }

    // MARK: - Conditional Matching

    private func conditionalMatches(
        _ condition: AstroConditionalWhen,
        activity: AstroActivity
    ) -> Bool {

        if let intensities =
            condition.intensity,
           !intensities.contains(
                activity.intensity
           ) {

            return false
        }

        if let actions =
            condition.anyActions,
           !hasAny(
                activity.actions,
                actions
           ) {

            return false
        }

        if let topics =
            condition.topicsAny,
           !hasAny(
                activity.topics,
                topics
           ) {

            return false
        }

        if let contexts =
            condition.contextAny,
           !hasAny(
                activity.context,
                contexts
           ) {

            return false
        }

        return true
    }

    // MARK: - Final Tag Scores

    private func finalize(
        buckets: [String: TagBuckets],
        baseScore: Double,
        aggregation:
            AstroAggregationPolicy,
        directScale: Double
    ) -> [String: Double] {

        var result:
            [String: Double] = [:]

        for (tag, bucket) in buckets {

            let aspect = clamp(
                bucket.aspect,
                range:
                    aggregation
                    .aspectTotalCapPerTag
            )

            let secondary = clamp(
                bucket.secondary,
                range:
                    aggregation
                    .secondaryTotalCapPerTag
            )

            let direct =
                bucket.directStatusPositive *
                directScale

            let planetStatus = clamp(
                bucket.planetStatus +
                direct,
                range:
                    aggregation
                    .planetStatusTotalCapPerTag
            )

            var score =
                baseScore +
                bucket.primary +
                aspect +
                secondary +
                planetStatus

            score = clamp(
                score,
                min: 0,
                max: 10
            )

            result[tag] = score
        }

        return result
    }

    // MARK: - Time

    private func activeSignals(
        _ signals: [AstroSignal],
        at date: Date
    ) -> [AstroSignal] {

        let formatter =
            ISO8601DateFormatter()

        return signals.filter { signal in

            let start =
                signal.startAt.flatMap {
                    formatter.date(
                        from: $0
                    )
                }

            let end =
                signal.endAt.flatMap {
                    formatter.date(
                        from: $0
                    )
                }

            if let start,
               let end {

                return date >= start &&
                    date < end
            }

            if let start {
                return date >= start
            }

            if let end {
                return date < end
            }

            return true
        }
    }

    // MARK: - Helpers

    private func makeBuckets(
        for tags: [String]
    ) -> [String: TagBuckets] {

        Dictionary(
            uniqueKeysWithValues:
                tags.map {
                    (
                        $0,
                        TagBuckets()
                    )
                }
        )
    }

    private func totalDirectPositive(
        _ groups:
            [String: TagBuckets]...
    ) -> Double {

        groups.reduce(0) {
            groupTotal,
            group in

            groupTotal +
                group.values.reduce(0) {
                    $0 +
                    $1.directStatusPositive
                }
        }
    }

    private func hasAny(
        _ lhs: [String],
        _ rhs: [String]
    ) -> Bool {

        !Set(lhs)
            .isDisjoint(
                with: Set(rhs)
            )
    }

    private func samePair(
        _ lhs: [String],
        _ rhs: [String]
    ) -> Bool {

        guard lhs.count == 2,
              rhs.count == 2
        else {
            return false
        }

        return Set(lhs) == Set(rhs)
    }

    private func mean<C>(
        _ values: C
    ) -> Double?
    where
        C: Collection,
        C.Element == Double {

        guard !values.isEmpty else {
            return nil
        }

        return values.reduce(0, +) /
            Double(values.count)
    }

    private func clamp(
        _ value: Double,
        range: [Int]
    ) -> Double {

        guard range.count >= 2 else {
            return value
        }

        return clamp(
            value,
            min: Double(range[0]),
            max: Double(range[1])
        )
    }

    private func clamp(
        _ value: Double,
        min minimum: Double,
        max maximum: Double
    ) -> Double {

        Swift.max(
            minimum,
            Swift.min(
                maximum,
                value
            )
        )
    }

    private func round(
        _ value: Double,
        decimals: Int
    ) -> Double {

        let multiplier =
            pow(
                10,
                Double(decimals)
            )

        return Foundation.round(
            value * multiplier
        ) / multiplier
    }
}
