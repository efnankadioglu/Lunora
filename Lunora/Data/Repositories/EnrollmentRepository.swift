//
//  EnrollmentRepository.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 6.04.2026.
//

import Foundation
import FirebaseFirestore


enum EnrollmentStartError: LocalizedError {
    case alreadyHasActiveProgram

    var errorDescription: String? {
        switch self {
        case .alreadyHasActiveProgram:
            return "Kullanıcının zaten aktif bir programı var."
        }
    }
}
enum EnrollmentLifecycleResult {
    case stillActive(ActiveEnrollment)
    case completedWithBadge(ActiveEnrollment)
    case completedWithoutBadge(ActiveEnrollment)
    case noActiveEnrollment
}


final class EnrollmentRepository {
    
    private let db = Firestore.firestore()
    
    func startProgram(userId: String, programId: String, completion: @escaping (Result<String, Error>) -> Void) {

        print("🟣 startProgram çağrıldı")
        print("🟣 userId:", userId)
        print("🟣 programId:", programId)

        let userRef = db
            .collection(FirestoreCollection.users)
            .document(userId)

        print("🟡 userRef path:", userRef.path)

        userRef.getDocument { snapshot, error in
            print("🟡 getDocument callback geldi")

            print("🟡 getDocument callback geldi")

            if let error = error {
                print("🔴 getDocument hata:", error.localizedDescription)
                completion(.failure(error))
                return
            }

            let userData = snapshot?.data()
            print("🟡 userData:", userData ?? [:])

            let activeEnrollmentId = userData?["activeEnrollmentId"] as? String
            print("🟡 activeEnrollmentId:", activeEnrollmentId ?? "nil")

            if let activeEnrollmentId, !activeEnrollmentId.isEmpty {
                print("🔴 zaten aktif program var")
                completion(.failure(EnrollmentStartError.alreadyHasActiveProgram))
                return
            }
            
            let programRef = self.db
                .collection(FirestoreCollection.programs)
                .document(programId)

            programRef.getDocument { programSnapshot, programError in
                if let programError = programError {
                    print("🔴 program document okunamadı:", programError.localizedDescription)
                    completion(.failure(programError))
                    return
                }

                guard let programData = programSnapshot?.data() else {
                    print("🔴 program document bulunamadı:", programId)
                    completion(.failure(NSError(
                        domain: "EnrollmentRepository",
                        code: -10,
                        userInfo: [NSLocalizedDescriptionKey: "Program bilgisi bulunamadı."]
                    )))
                    return
                }

                let programName = programData["name"] as? String ?? ""
                let durationDays = programData["durationDays"] as? Int ?? 0
                let badgeId = programData["badgeId"] as? String ?? ""
                let badgeDescription = programData["badgeDescription"] as? String ?? ""
                let programImageName = programData["imageName"] as? String ?? ""

                guard durationDays > 0 else {
                    print("🔴 durationDays geçersiz:", durationDays)
                    completion(.failure(NSError(
                        domain: "EnrollmentRepository",
                        code: -11,
                        userInfo: [NSLocalizedDescriptionKey: "Program süresi geçersiz."]
                    )))
                    return
                }

                let enrollmentRef = userRef
                    .collection(FirestoreCollection.programEnrollments)
                    .document()

                print("🟢 enrollmentRef path:", enrollmentRef.path)

                let now = Timestamp(date: Date())

                let enrollmentData: [String: Any] = [
                    "userId": userId,
                    "programId": programId,
                    "programName": programName,
                    "durationDays": durationDays,
                    "badgeId": badgeId,
                    "badgeDescription": badgeDescription,
                    "programImageName": programImageName,

                    "status": "active",
                    "startedAt": now,
                    "createdAt": now,
                    "updatedAt": now,

                    "currentDay": 1,
                    "completedDaysCount": 0,
                    "progressPercent": 0.0,

                    "isCompleted": false,
                    "isFailed": false,
                    "earnedBadge": false
                ]

                let userDataToMerge: [String: Any] = [
                    "activeEnrollmentId": enrollmentRef.documentID,
                    "updatedAt": now
                ]

                let batch = self.db.batch()
                batch.setData(enrollmentData, forDocument: enrollmentRef)
                batch.setData(userDataToMerge, forDocument: userRef, merge: true)

                print("🟢 batch commit başlayacak")

                batch.commit { error in
                    if let error = error {
                        print("🔴 batch commit hata:", error.localizedDescription)
                        completion(.failure(error))
                    } else {
                        print("🟢 batch commit başarılı")
                        print("🟢 enrollmentId:", enrollmentRef.documentID)
                        completion(.success(enrollmentRef.documentID))
                    }
                }
            }
            
        }
    }
    
    
    func fetchActiveEnrollmentId(userId: String, completion: @escaping (Result<String?, Error>) -> Void) {
        let userRef = db
            .collection(FirestoreCollection.users)
            .document(userId)

        userRef.getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            let activeEnrollmentId = snapshot?.data()?["activeEnrollmentId"] as? String
            completion(.success(activeEnrollmentId))
        }
    }
    
    func fetchActiveEnrollment(userId: String, completion: @escaping (Result<ActiveEnrollment?, Error>) -> Void) {
        let userRef = db
            .collection(FirestoreCollection.users)
            .document(userId)

        userRef.getDocument { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let activeEnrollmentId = snapshot?.data()?["activeEnrollmentId"] as? String,
                  !activeEnrollmentId.isEmpty else {
                completion(.success(nil))
                return
            }

            let enrollmentRef = userRef
                .collection(FirestoreCollection.programEnrollments)
                .document(activeEnrollmentId)

            enrollmentRef.getDocument { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard
                    let snapshot = snapshot,
                    let data = snapshot.data(),
                    let enrollment = ActiveEnrollment(documentId: snapshot.documentID, data: data)
                else {
                    completion(.success(nil))
                    return
                }

                completion(.success(enrollment))
            }
        }
    }
    
    func fetchActiveEnrollmentForProgress(
        userId: String,
        completion: @escaping (Result<EnrollmentLifecycleResult, Error>) -> Void
    ) {
        fetchActiveEnrollment(userId: userId) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure(let error):
                completion(.failure(error))

            case .success(let enrollment):
                guard let enrollment = enrollment else {
                    completion(.success(.noActiveEnrollment))
                    return
                }

                if enrollment.status == "completed" || enrollment.isCompleted {
                    if enrollment.earnedBadge {
                        completion(.success(.completedWithBadge(enrollment)))
                    } else {
                        completion(.success(.completedWithoutBadge(enrollment)))
                    }
                    return
                }

                guard self.hasEnrollmentDurationEnded(enrollment) else {
                    completion(.success(.stillActive(enrollment)))
                    return
                }

                self.finalizeEnrollmentAfterDurationEnd(
                    userId: userId,
                    enrollment: enrollment,
                    completion: completion
                )
            }
        }
    }
    
    // MARK: - DateKey Helper
    private func generateDateKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: Date())
    }
    
    func getOrCreateTodayLog(
        userId: String,
        enrollment: ActiveEnrollment,
        completion: @escaping (Result<DailyLog, Error>) -> Void
    ) {
        
        let dateKey = generateDateKey()
        let currentDayNumber = calculateCurrentDay(from: enrollment.startedAt)
        
        let userRef = db.collection(FirestoreCollection.users).document(userId)
        
        let logRef = userRef
            .collection(FirestoreCollection.programEnrollments)
            .document(enrollment.enrollmentId)
            .collection("dailyLogs")
            .document(dateKey)
        
        logRef.getDocument { snapshot, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let snapshot = snapshot,
               snapshot.exists,
               let data = snapshot.data(),
               let log = DailyLog(documentId: snapshot.documentID, data: data) {
                
                print("🟢 DailyLog zaten var:", dateKey)
                completion(.success(log))
                return
            }
            
            print("🟡 DailyLog oluşturuluyor:", dateKey)
            
            let now = Timestamp(date: Date())
            
            let logData: [String: Any] = [
                "enrollmentId": enrollment.enrollmentId,
                "userId": userId,
                "programId": enrollment.programId,
                "dateKey": dateKey,
                "dayNumber": currentDayNumber,
                "completedTaskIds": [],
                "isCompleted": false,
                "createdAt": now,
                "updatedAt": now
            ]
            
            logRef.setData(logData) { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                logRef.getDocument { snapshot, error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    guard
                        let snapshot = snapshot,
                        let data = snapshot.data(),
                        let log = DailyLog(documentId: snapshot.documentID, data: data)
                    else {
                        completion(.failure(NSError(domain: "DailyLog", code: -1)))
                        return
                    }
                    
                    print("🟢 DailyLog oluşturuldu:", dateKey)
                    completion(.success(log))
                }
            }
        }
    }
    
    func updateCompletedTaskIds(
        userId: String,
        enrollmentId: String,
        dateKey: String,
        completedTaskIds: [String],
        isCompleted: Bool,
        completion: @escaping (Result<DailyLog, Error>) -> Void
    ) {
        let logRef = db
            .collection(FirestoreCollection.users)
            .document(userId)
            .collection(FirestoreCollection.programEnrollments)
            .document(enrollmentId)
            .collection("dailyLogs")
            .document(dateKey)

        var updateData: [String: Any] = [
            "completedTaskIds": completedTaskIds,
            "isCompleted": isCompleted,
            "updatedAt": Timestamp(date: Date())
        ]

        if isCompleted {
            updateData["completedAt"] = Timestamp(date: Date())
        } else {
            updateData["completedAt"] = NSNull()
        }

        logRef.updateData(updateData) { error in
            if let error = error {
                completion(.failure(error))
                return
            }

            logRef.getDocument { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard
                    let snapshot = snapshot,
                    let data = snapshot.data(),
                    let log = DailyLog(documentId: snapshot.documentID, data: data)
                else {
                    completion(.failure(NSError(domain: "DailyLog", code: -2)))
                    return
                }

                completion(.success(log))
            }
        }
    }
    
    // MARK: - Current Day Helper
    private func calculateCurrentDay(from startedAt: Timestamp?) -> Int {
        guard let startedAt = startedAt?.dateValue() else {
            return 1
        }

        let calendar = Calendar.current
        let startOfStartDate = calendar.startOfDay(for: startedAt)
        let startOfToday = calendar.startOfDay(for: Date())

        let dayDifference = calendar.dateComponents([.day], from: startOfStartDate, to: startOfToday).day ?? 0

        return max(1, dayDifference + 1)
    }
    
    
    func refreshEnrollmentProgressSummary(
        userId: String,
        enrollment: ActiveEnrollment,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let userRef = db
            .collection(FirestoreCollection.users)
            .document(userId)

        let enrollmentRef = userRef
            .collection(FirestoreCollection.programEnrollments)
            .document(enrollment.enrollmentId)

        calculateEnrollmentProgressPercent(
            userId: userId,
            enrollment: enrollment
        ) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure(let error):
                completion(.failure(error))

            case .success(let summary):
                let currentDay = self.calculateCurrentDay(from: enrollment.startedAt)

                let updateData: [String: Any] = [
                    "currentDay": min(currentDay, max(1, enrollment.durationDays)),
                    "completedDaysCount": summary.completedDaysCount,
                    "progressPercent": summary.progressPercent,
                    "updatedAt": Timestamp(date: Date())
                ]

                enrollmentRef.updateData(updateData) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            }
        }
    }
    
    private func calculateEnrollmentProgressPercent(
        userId: String,
        enrollment: ActiveEnrollment,
        completion: @escaping (Result<(progressPercent: Double, completedDaysCount: Int), Error>) -> Void
    ) {
        let programRef = db
            .collection(FirestoreCollection.programs)
            .document(enrollment.programId)

        programRef.getDocument { [weak self] programSnapshot, programError in
            guard let self = self else { return }

            if let programError = programError {
                completion(.failure(programError))
                return
            }

            let programData = programSnapshot?.data() ?? [:]
            let dailyTasks = programData["dailyTasks"] as? [[String: Any]] ?? []
            let taskCountPerDay = max(1, dailyTasks.count)
            let totalDays = max(1, enrollment.durationDays)
            let totalPossibleTaskCompletions = totalDays * taskCountPerDay

            let logsRef = self.db
                .collection(FirestoreCollection.users)
                .document(userId)
                .collection(FirestoreCollection.programEnrollments)
                .document(enrollment.enrollmentId)
                .collection("dailyLogs")

            logsRef.getDocuments { snapshot, logsError in
                if let logsError = logsError {
                    completion(.failure(logsError))
                    return
                }

                let logs: [DailyLog] = snapshot?.documents.compactMap { document in
                    DailyLog(documentId: document.documentID, data: document.data())
                } ?? []

                let completedTaskCount = logs.reduce(0) { result, log in
                    result + Set(log.completedTaskIds).count
                }

                let completedDaysCount = logs.filter { $0.isCompleted }.count

                let rawProgress = Double(completedTaskCount) / Double(totalPossibleTaskCompletions)
                let progressPercent = min(100.0, max(0.0, rawProgress * 100.0))

                completion(.success((
                    progressPercent: progressPercent,
                    completedDaysCount: completedDaysCount
                )))
            }
        }
    }
    
    
    
    func refreshUserStreak(
        userId: String,
        todayLog: DailyLog,
        completion: @escaping (Result<(currentStreak: Int, lastCompletedDateKey: String?), Error>) -> Void
    ) {
        let userRef = db
            .collection(FirestoreCollection.users)
            .document(userId)

        userRef.getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            let userData = snapshot?.data() ?? [:]

            let currentStreak = userData["currentStreak"] as? Int ?? 0
            let lastCompletedDateKey = userData["lastCompletedDateKey"] as? String

            // Gün tamamlanmamışsa streak değiştirme
            guard todayLog.isCompleted else {
                completion(.success((currentStreak, lastCompletedDateKey)))
                return
            }

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = TimeZone.current

            guard let todayDate = formatter.date(from: todayLog.dateKey) else {
                completion(.success((currentStreak, lastCompletedDateKey)))
                return
            }

            let calendar = Calendar.current
            let yesterdayDate = calendar.date(byAdding: .day, value: -1, to: todayDate)
            let yesterdayKey = yesterdayDate.map { formatter.string(from: $0) }

            var newStreak = currentStreak

            if lastCompletedDateKey == todayLog.dateKey {
                // Aynı gün tekrar tamamlandıysa streak tekrar artmasın
                completion(.success((currentStreak, lastCompletedDateKey)))
                return
            } else if lastCompletedDateKey == yesterdayKey {
                newStreak = currentStreak + 1
            } else {
                newStreak = 1
            }

            let updateData: [String: Any] = [
                "currentStreak": newStreak,
                "lastCompletedDateKey": todayLog.dateKey,
                "updatedAt": Timestamp(date: Date())
            ]

            userRef.setData(updateData, merge: true) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success((newStreak, todayLog.dateKey)))
                }
            }
        }
    }
    
    func fetchAllDailyLogs(
        userId: String,
        enrollmentId: String,
        completion: @escaping (Result<[DailyLog], Error>) -> Void
    ) {
        let logsRef = db
            .collection(FirestoreCollection.users)
            .document(userId)
            .collection(FirestoreCollection.programEnrollments)
            .document(enrollmentId)
            .collection("dailyLogs")

        logsRef.getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            let logs: [DailyLog] = snapshot?.documents.compactMap { document in
                DailyLog(documentId: document.documentID, data: document.data())
            } ?? []

            completion(.success(logs))
        }
    }
    
    func fetchLongestFullTaskStreak(
        userId: String,
        programs: [Program],
        completion: @escaping (Result<Int, Error>) -> Void
    ) {
        
        let programTaskCounts: [String: Int] = Dictionary(
            uniqueKeysWithValues: programs.map { program in
                (program.id, program.dailyTasks.count)
            }
        )
        
        let enrollmentsRef = db
            .collection(FirestoreCollection.users)
            .document(userId)
            .collection(FirestoreCollection.programEnrollments)
        
        enrollmentsRef.getDocuments { snapshot, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            let enrollmentDocuments = snapshot?.documents ?? []
            
            if enrollmentDocuments.isEmpty {
                completion(.success(0))
                return
            }
            
            let group = DispatchGroup()
            var fullCompletedDateKeys = Set<String>()
            var firstError: Error?
            
            for enrollmentDocument in enrollmentDocuments {
                group.enter()
                
                let logsRef = enrollmentDocument.reference.collection("dailyLogs")
                
                logsRef.getDocuments { logsSnapshot, logsError in
                    defer { group.leave() }
                    
                    if let logsError = logsError {
                        firstError = logsError
                        return
                    }
                    
                    let logs: [DailyLog] = logsSnapshot?.documents.compactMap { document in
                        DailyLog(documentId: document.documentID, data: document.data())
                    } ?? []
                    
                    for log in logs {
                        guard let requiredTaskCount = programTaskCounts[log.programId],
                              requiredTaskCount > 0 else {
                            continue
                        }
                        
                        let completedTaskCount = Set(log.completedTaskIds).count
                        
                        if completedTaskCount >= requiredTaskCount {
                            fullCompletedDateKeys.insert(log.dateKey)
                        }
                    }
                }
            }
            
            group.notify(queue: .main) {
                if let firstError = firstError {
                    completion(.failure(firstError))
                    return
                }
                
                let longestStreak = self.calculateLongestConsecutiveDateKeyStreak(
                    from: fullCompletedDateKeys
                )
                
                completion(.success(longestStreak))
            }
        }
    }

    private func calculateLongestConsecutiveDateKeyStreak(
        from dateKeys: Set<String>
    ) -> Int {
        
        if dateKeys.isEmpty {
            return 0
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        
        let dates = dateKeys
            .compactMap { formatter.date(from: $0) }
            .sorted()
        
        if dates.isEmpty {
            return 0
        }
        
        var longestStreak = 1
        var currentStreak = 1
        
        let calendar = Calendar.current
        
        for index in 1..<dates.count {
            let previousDate = calendar.startOfDay(for: dates[index - 1])
            let currentDate = calendar.startOfDay(for: dates[index])
            
            let dayDifference = calendar.dateComponents(
                [.day],
                from: previousDate,
                to: currentDate
            ).day ?? 0
            
            if dayDifference == 1 {
                currentStreak += 1
                longestStreak = max(longestStreak, currentStreak)
            } else if dayDifference > 1 {
                currentStreak = 1
            }
        }
        
        return longestStreak
    }
    
    private func finalizeEnrollmentAfterDurationEnd(
        userId: String,
        enrollment: ActiveEnrollment,
        completion: @escaping (Result<EnrollmentLifecycleResult, Error>) -> Void
    ) {
        let userRef = db
            .collection(FirestoreCollection.users)
            .document(userId)

        let enrollmentRef = userRef
            .collection(FirestoreCollection.programEnrollments)
            .document(enrollment.enrollmentId)

        calculateEnrollmentProgressPercent(
            userId: userId,
            enrollment: enrollment
        ) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure(let error):
                completion(.failure(error))

            case .success(let summary):
                let now = Timestamp(date: Date())
                let finalProgress = summary.progressPercent
                let earnedBadge = finalProgress >= 80.0

                let batch = self.db.batch()

                let enrollmentUpdate: [String: Any] = [
                    "status": "completed",
                    "isCompleted": true,
                    "isFailed": false,
                    "earnedBadge": earnedBadge,
                    "completedDaysCount": summary.completedDaysCount,
                    "progressPercent": finalProgress,
                    "completionReason": "duration_ended",
                    "finalProgressPercent": finalProgress,
                    "completedAt": now,
                    "updatedAt": now
                ]

                batch.updateData(enrollmentUpdate, forDocument: enrollmentRef)

                batch.updateData([
                    "activeEnrollmentId": FieldValue.delete(),
                    "updatedAt": now
                ], forDocument: userRef)

                if earnedBadge {
                    let badgeDocumentId = enrollment.badgeId.isEmpty
                        ? enrollment.programId
                        : enrollment.badgeId

                    let earnedBadgeRef = userRef
                        .collection(FirestoreCollection.earnedBadges)
                        .document(badgeDocumentId)

                    let earnedBadgeData: [String: Any] = [
                        "badgeId": badgeDocumentId,
                        "badgeDescription": enrollment.badgeDescription,
                        "programId": enrollment.programId,
                        "programName": enrollment.programName ?? "",
                        "programImageName": enrollment.programImageName,
                        "enrollmentId": enrollment.enrollmentId,
                        "earnedAt": now,
                        "progressPercent": finalProgress,
                        "completionReason": "duration_ended",
                        "isFeatured": false,
                        "isSeen": false
                    ]

                    batch.setData(earnedBadgeData, forDocument: earnedBadgeRef, merge: true)
                }

                batch.commit { error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }

                    enrollmentRef.getDocument { snapshot, error in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }

                        guard
                            let snapshot = snapshot,
                            let data = snapshot.data(),
                            let finalizedEnrollment = ActiveEnrollment(
                                documentId: snapshot.documentID,
                                data: data
                            )
                        else {
                            completion(.failure(NSError(
                                domain: "EnrollmentRepository",
                                code: -20,
                                userInfo: [
                                    NSLocalizedDescriptionKey: "Tamamlanan enrollment yeniden okunamadı."
                                ]
                            )))
                            return
                        }

                        if earnedBadge {
                            completion(.success(.completedWithBadge(finalizedEnrollment)))
                        } else {
                            completion(.success(.completedWithoutBadge(finalizedEnrollment)))
                        }
                    }
                }
            }
        }
    }
    
    
    // MARK: - Completed Enrollments
    func fetchCompletedEnrollments(
        userId: String,
        completion: @escaping (Result<[CompletedEnrollment], Error>) -> Void
    ) {
        
        let enrollmentsRef = db
            .collection(FirestoreCollection.users)
            .document(userId)
            .collection(FirestoreCollection.programEnrollments)
        
        enrollmentsRef.getDocuments { snapshot, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            let completed: [CompletedEnrollment] = snapshot?.documents.compactMap { document in
                CompletedEnrollment(
                    documentId: document.documentID,
                    data: document.data()
                )
            } ?? []

            let sorted = completed.sorted {
                ($0.completedAt?.dateValue() ?? Date()) >
                ($1.completedAt?.dateValue() ?? Date())
            }
            
            completion(.success(sorted))
        }
    }

    func completeJourney(
        userId: String,
        enrollmentId: String,
        note: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let userRef = db
            .collection(FirestoreCollection.users)
            .document(userId)

        let enrollmentRef = userRef
            .collection(FirestoreCollection.programEnrollments)
            .document(enrollmentId)

        let now = Timestamp(date: Date())

        let enrollmentUpdate: [String: Any] = [
            "status": "completed",
            "isCompleted": true,
            "isFailed": false,
            "completionNote": note,
            "completedAt": now,
            "updatedAt": now
        ]

        let userUpdate: [String: Any] = [
            "activeEnrollmentId": FieldValue.delete(),
            "updatedAt": now
        ]

        let batch = db.batch()
        batch.updateData(enrollmentUpdate, forDocument: enrollmentRef)
        batch.setData(userUpdate, forDocument: userRef, merge: true)

        batch.commit { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func endJourney(
        userId: String,
        enrollmentId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let userRef = db
            .collection(FirestoreCollection.users)
            .document(userId)

        let enrollmentRef = userRef
            .collection(FirestoreCollection.programEnrollments)
            .document(enrollmentId)

        let now = Timestamp(date: Date())

        let enrollmentUpdate: [String: Any] = [
            "status": "abandoned",
            "updatedAt": now
        ]

        let userUpdate: [String: Any] = [
            "activeEnrollmentId": FieldValue.delete(),
            "updatedAt": now
        ]

        let batch = db.batch()
        batch.updateData(enrollmentUpdate, forDocument: enrollmentRef)
        batch.setData(userUpdate, forDocument: userRef, merge: true)

        batch.commit { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    private func hasEnrollmentDurationEnded(_ enrollment: ActiveEnrollment) -> Bool {
        guard let startedAtDate = enrollment.startedAt?.dateValue(),
              enrollment.durationDays > 0 else {
            return false
        }

        let calendar = Calendar.current

        let startOfStartDate = calendar.startOfDay(for: startedAtDate)
        let startOfToday = calendar.startOfDay(for: Date())

        guard let endDate = calendar.date(
            byAdding: .day,
            value: enrollment.durationDays,
            to: startOfStartDate
        ) else {
            return false
        }

        return startOfToday >= endDate
    }
    
}
