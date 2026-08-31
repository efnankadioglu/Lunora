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

private struct EnrollmentProgressSummary {
    let progressPercent: Double
    let completedDaysCount: Int
    let isFinalDayFullyCompleted: Bool
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

                let badgeTitle =
                    programData["badgeTitle"] as? String
                    ?? "\(programName) Rozeti"

                let badgeImageName =
                    programData["badgeImageName"] as? String
                    ?? programImageName

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
                    "badgeTitle": badgeTitle,
                    "badgeDescription": badgeDescription,
                    "badgeImageName": badgeImageName,
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

                    "earnedBadge": false,
                    "badgeEvaluationCompleted": false,
                    "finalizationVersion": 0
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

                // MARK: - Zaten tamamlanmışsa

                if enrollment.status == "completed" || enrollment.isCompleted {

                    if enrollment.earnedBadge {
                        completion(.success(.completedWithBadge(enrollment)))
                    } else {
                        completion(.success(.completedWithoutBadge(enrollment)))
                    }

                    return
                }

                // MARK: - Programın takvim süresi bittiyse

                if self.hasEnrollmentDurationEnded(enrollment) {

                    self.finalizeEnrollment(
                        userId: userId,
                        enrollment: enrollment,
                        trigger: .durationEnded,
                        completion: completion
                    )

                    return
                }

                // MARK: - Son gün recovery kontrolü
                //
                // Kullanıcı son görevi bitirdi ama uygulama tam
                // finalization sırasında kapandıysa Progress tekrar
                // açıldığında burası sistemi kurtarır.

                let calculatedCurrentDay =
                    self.calculateCurrentDay(
                        from: enrollment.startedAt
                    )

                if calculatedCurrentDay >= enrollment.durationDays {

                    self.finalizeEnrollment(
                        userId: userId,
                        enrollment: enrollment,
                        trigger: .lastTask,
                        completion: completion
                    )

                    return
                }

                completion(.success(.stillActive(enrollment)))
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
            .collection(FirestoreCollection.dailyLogs)
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
            .collection(FirestoreCollection.dailyLogs)
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

        calculateEnrollmentProgressSummary(
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
    
    private func calculateEnrollmentProgressSummary(
        userId: String,
        enrollment: ActiveEnrollment,
        completion: @escaping (
            Result<EnrollmentProgressSummary, Error>
        ) -> Void
    ) {

        let programRef = db
            .collection(FirestoreCollection.programs)
            .document(enrollment.programId)

        programRef.getDocument { [weak self] programSnapshot, programError in

            guard let self = self else {
                return
            }

            if let programError = programError {
                completion(.failure(programError))
                return
            }

            guard let programData = programSnapshot?.data() else {

                completion(
                    .failure(
                        NSError(
                            domain: "EnrollmentRepository",
                            code: -30,
                            userInfo: [
                                NSLocalizedDescriptionKey:
                                    "Program bilgisi bulunamadı."
                            ]
                        )
                    )
                )

                return
            }

            let totalDays = max(
                1,
                enrollment.durationDays
            )

            // Her gün için zorunlu task ID'lerini tutacağız.
            var requiredTaskIdsByDay: [Int: Set<String>] = [:]

            // MARK: - Yeni Program Formatı

            if let programDays =
                programData["days"] as? [[String: Any]],
               !programDays.isEmpty {

                for dayData in programDays {

                    guard
                        let dayNumber =
                            dayData["dayNumber"] as? Int,
                        dayNumber >= 1,
                        dayNumber <= totalDays
                    else {
                        continue
                    }

                    let tasks =
                        dayData["tasks"] as? [[String: Any]]
                        ?? []

                    let requiredTaskIds = Set(
                        tasks.compactMap { task -> String? in

                            let isRequired =
                                task["isRequired"] as? Bool
                                ?? true

                            guard isRequired else {
                                return nil
                            }

                            return task["id"] as? String
                        }
                    )

                    requiredTaskIdsByDay[dayNumber] =
                        requiredTaskIds
                }

            } else {

                // MARK: - Eski Program Formatı

                let dailyTasks =
                    programData["dailyTasks"]
                    as? [[String: Any]]
                    ?? []

                let requiredTaskIds = Set(
                    dailyTasks.compactMap { task -> String? in

                        let isRequired =
                            task["isRequired"] as? Bool
                            ?? true

                        guard isRequired else {
                            return nil
                        }

                        return task["id"] as? String
                    }
                )

                for dayNumber in 1...totalDays {

                    requiredTaskIdsByDay[dayNumber] =
                        requiredTaskIds
                }
            }

            // Eksik gün varsa güvenli şekilde boş Set oluştur.
            for dayNumber in 1...totalDays {

                if requiredTaskIdsByDay[dayNumber] == nil {

                    requiredTaskIdsByDay[dayNumber] = []
                }
            }

            let totalRequiredTaskCount =
                requiredTaskIdsByDay
                    .values
                    .reduce(0) {
                        $0 + $1.count
                    }

            guard totalRequiredTaskCount > 0 else {

                completion(
                    .failure(
                        NSError(
                            domain: "EnrollmentRepository",
                            code: -31,
                            userInfo: [
                                NSLocalizedDescriptionKey:
                                    "Programda zorunlu görev bulunamadı."
                            ]
                        )
                    )
                )

                return
            }

            // Programdaki günlük tamamlanma eşiği.
            let dailyThreshold =
                min(
                    max(
                        (
                            programData[
                                "dailyTaskCompletionThreshold"
                            ] as? NSNumber
                        )?.doubleValue ?? 0.5,
                        0.0
                    ),
                    1.0
                )

            let logsRef = self.db
                .collection(FirestoreCollection.users)
                .document(userId)
                .collection(
                    FirestoreCollection.programEnrollments
                )
                .document(enrollment.enrollmentId)
                .collection(FirestoreCollection.dailyLogs)

            logsRef.getDocuments { snapshot, logsError in

                if let logsError = logsError {

                    completion(.failure(logsError))
                    return
                }

                let logs: [DailyLog] =
                    snapshot?.documents.compactMap { document in

                        DailyLog(
                            documentId: document.documentID,
                            data: document.data()
                        )
                    } ?? []

                /*
                 Aynı dayNumber için bir şekilde birden fazla
                 DailyLog oluşmuşsa task'ları birleştiriyoruz.
                */
                var completedTaskIdsByDay:
                    [Int: Set<String>] = [:]

                for log in logs {

                    guard
                        log.dayNumber >= 1,
                        log.dayNumber <= totalDays
                    else {
                        continue
                    }

                    completedTaskIdsByDay[
                        log.dayNumber,
                        default: []
                    ].formUnion(
                        log.completedTaskIds
                    )
                }

                var completedRequiredTaskCount = 0
                var completedDaysCount = 0

                for dayNumber in 1...totalDays {

                    let requiredIds =
                        requiredTaskIdsByDay[dayNumber]
                        ?? []

                    guard !requiredIds.isEmpty else {
                        continue
                    }

                    let completedIds =
                        completedTaskIdsByDay[dayNumber]
                        ?? []

                    let completedRequiredIds =
                        requiredIds.intersection(
                            completedIds
                        )

                    completedRequiredTaskCount +=
                        completedRequiredIds.count

                    let dayCompletionRate =
                        Double(
                            completedRequiredIds.count
                        )
                        /
                        Double(
                            requiredIds.count
                        )

                    if dayCompletionRate >= dailyThreshold {

                        completedDaysCount += 1
                    }
                }

                let rawProgress =
                    Double(completedRequiredTaskCount)
                    /
                    Double(totalRequiredTaskCount)

                let progressPercent =
                    min(
                        100.0,
                        max(
                            0.0,
                            rawProgress * 100.0
                        )
                    )

                // Son gün tamamen tamamlandı mı?
                let finalDayRequiredIds =
                    requiredTaskIdsByDay[totalDays]
                    ?? []

                let finalDayCompletedIds =
                    completedTaskIdsByDay[totalDays]
                    ?? []

                let isFinalDayFullyCompleted =
                    !finalDayRequiredIds.isEmpty
                    &&
                    finalDayRequiredIds.isSubset(
                        of: finalDayCompletedIds
                    )

                completion(
                    .success(
                        EnrollmentProgressSummary(
                            progressPercent:
                                progressPercent,

                            completedDaysCount:
                                completedDaysCount,

                            isFinalDayFullyCompleted:
                                isFinalDayFullyCompleted
                        )
                    )
                )
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
            .collection(FirestoreCollection.dailyLogs)

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
    
    func fetchTotalActivityDays(
        userId: String,
        completion: @escaping (Result<Int, Error>) -> Void
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

            let enrollmentDocuments = snapshot?.documents ?? []

            guard !enrollmentDocuments.isEmpty else {
                completion(.success(0))
                return
            }

            let group = DispatchGroup()
            let lock = NSLock()

            var activeDateKeys = Set<String>()
            var firstError: Error?

            for enrollmentDocument in enrollmentDocuments {

                group.enter()

                enrollmentDocument.reference
                    .collection(FirestoreCollection.dailyLogs)
                    .getDocuments { logsSnapshot, logsError in

                        defer {
                            group.leave()
                        }

                        if let logsError = logsError {
                            lock.lock()

                            if firstError == nil {
                                firstError = logsError
                            }

                            lock.unlock()
                            return
                        }

                        let logDocuments = logsSnapshot?.documents ?? []

                        for logDocument in logDocuments {

                            let data = logDocument.data()

                            let completedTaskIds =
                                data["completedTaskIds"] as? [String] ?? []

                            guard !completedTaskIds.isEmpty else {
                                continue
                            }

                            let dateKey =
                                data["dateKey"] as? String
                                ?? logDocument.documentID

                            lock.lock()
                            activeDateKeys.insert(dateKey)
                            lock.unlock()
                        }
                    }
            }

            group.notify(queue: .main) {

                if let firstError = firstError {
                    completion(.failure(firstError))
                    return
                }

                completion(.success(activeDateKeys.count))
            }
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
                
                let logsRef = enrollmentDocument.reference.collection(FirestoreCollection.dailyLogs)
                
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
    
    func finalizeEnrollment(
        userId: String,
        enrollment: ActiveEnrollment,
        trigger: EnrollmentCompletionTrigger,
        completion: @escaping (Result<EnrollmentLifecycleResult, Error>) -> Void
    ) {

        calculateEnrollmentProgressSummary(
            userId: userId,
            enrollment: enrollment
        ) { [weak self] result in

            guard let self = self else { return }

            switch result {

            case .failure(let error):
                completion(.failure(error))

            case .success(let summary):

                // MARK: - Trigger doğrulaması

                switch trigger {

                case .lastTask:

                    let currentDay =
                        self.calculateCurrentDay(
                            from: enrollment.startedAt
                        )

                    /*
                     UI yanlışlıkla finalize çağırsa bile:
                     - gerçekten son gün olmalı
                     - son günün bütün required task'ları bitmiş olmalı
                    */
                    guard
                        currentDay >= enrollment.durationDays,
                        summary.isFinalDayFullyCompleted
                    else {

                        completion(.success(.stillActive(enrollment)))
                        return
                    }

                case .durationEnded:

                    /*
                     durationEnded yalnızca takvim süresi
                     gerçekten bittiyse geçerli.
                    */
                    guard self.hasEnrollmentDurationEnded(enrollment) else {
                        completion(.success(.stillActive(enrollment)))
                        return
                    }
                }

                // MARK: - Tek rozet kararı

                let earnedBadge =
                    summary.progressPercent
                    >= ProgramCompletionPolicy.badgeUnlockPercent

                self.commitFinalization(
                    userId: userId,
                    enrollment: enrollment,
                    summary: summary,
                    trigger: trigger,
                    earnedBadge: earnedBadge,
                    completion: completion
                )
            }
        }
    }
    
    private func commitFinalization(
        userId: String,
        enrollment: ActiveEnrollment,
        summary: EnrollmentProgressSummary,
        trigger: EnrollmentCompletionTrigger,
        earnedBadge: Bool,
        completion: @escaping (Result<EnrollmentLifecycleResult, Error>) -> Void
    ) {

        let userRef = db
            .collection(FirestoreCollection.users)
            .document(userId)

        let enrollmentRef = userRef
            .collection(FirestoreCollection.programEnrollments)
            .document(enrollment.enrollmentId)

        let badgeDocumentId =
            enrollment.badgeId.isEmpty
            ? enrollment.programId
            : enrollment.badgeId

        let earnedBadgeRef = userRef
            .collection(FirestoreCollection.earnedBadges)
            .document(badgeDocumentId)

        db.runTransaction({ transaction, errorPointer -> Any? in

            // MARK: - Önce bütün READ işlemleri

            let enrollmentSnapshot: DocumentSnapshot
            let userSnapshot: DocumentSnapshot
            var existingBadgeSnapshot: DocumentSnapshot?

            do {

                enrollmentSnapshot =
                    try transaction.getDocument(enrollmentRef)

                userSnapshot =
                    try transaction.getDocument(userRef)

                if earnedBadge {
                    existingBadgeSnapshot =
                        try transaction.getDocument(earnedBadgeRef)
                }

            } catch let error as NSError {

                errorPointer?.pointee = error
                return nil
            }

            guard
                enrollmentSnapshot.exists,
                let enrollmentData = enrollmentSnapshot.data(),
                let currentEnrollment = ActiveEnrollment(
                    documentId: enrollmentSnapshot.documentID,
                    data: enrollmentData
                )
            else {

                errorPointer?.pointee = NSError(
                    domain: "EnrollmentRepository",
                    code: -40,
                    userInfo: [
                        NSLocalizedDescriptionKey:
                            "Finalization sırasında enrollment okunamadı."
                    ]
                )

                return nil
            }

            guard userSnapshot.exists else {

                errorPointer?.pointee = NSError(
                    domain: "EnrollmentRepository",
                    code: -41,
                    userInfo: [
                        NSLocalizedDescriptionKey:
                            "Finalization sırasında kullanıcı belgesi bulunamadı."
                    ]
                )

                return nil
            }

            // MARK: - Idempotency
            //
            // Bu program daha önce kesin olarak finalize edilmişse
            // ikinci kez hiçbir şey yazma.

            if currentEnrollment.isCompleted &&
                currentEnrollment.badgeEvaluationCompleted {

                return nil
            }

            let now = Timestamp(date: Date())

            // MARK: - Enrollment Final State

            let enrollmentUpdate: [String: Any] = [
                "status": "completed",
                "isCompleted": true,
                "isFailed": false,

                "completedDaysCount":
                    summary.completedDaysCount,

                "progressPercent":
                    summary.progressPercent,

                "finalProgressPercent":
                    summary.progressPercent,

                "earnedBadge":
                    earnedBadge,

                "badgeEvaluationCompleted":
                    true,

                "finalizationVersion":
                    ProgramCompletionPolicy.finalizationVersion,

                "completionReason":
                    trigger.rawValue,

                "completedAt":
                    now,

                "updatedAt":
                    now
            ]

            transaction.updateData(
                enrollmentUpdate,
                forDocument: enrollmentRef
            )

            // MARK: - Active Enrollment temizliği
            //
            // Sadece kullanıcının activeEnrollmentId'si gerçekten
            // bu enrollment ise siliyoruz.

            if let activeEnrollmentId =
                userSnapshot.data()?["activeEnrollmentId"] as? String,
               activeEnrollmentId == enrollment.enrollmentId {

                transaction.updateData(
                    [
                        "activeEnrollmentId":
                            FieldValue.delete(),

                        "updatedAt":
                            now
                    ],
                    forDocument: userRef
                )
            }

            // MARK: - Badge

            if earnedBadge {

                /*
                 Aynı badge document zaten varsa yeniden oluşturmuyoruz.

                 Böylece finalization iki kez çağrılsa bile
                 ikinci badge üretilemez.
                */

                if existingBadgeSnapshot?.exists != true {

                    let badgeTitle =
                        enrollment.badgeTitle.isEmpty
                        ? "\(enrollment.programName ?? "Program") Rozeti"
                        : enrollment.badgeTitle

                    let badgeImageName =
                        enrollment.badgeImageName.isEmpty
                        ? enrollment.programImageName
                        : enrollment.badgeImageName

                    let earnedBadgeData: [String: Any] = [
                        "badgeId":
                            badgeDocumentId,

                        "programId":
                            enrollment.programId,

                        "enrollmentId":
                            enrollment.enrollmentId,

                        "awardedAt":
                            now,

                        "status":
                            "earned",

                        "isSeen":
                            false,

                        "isFeatured":
                            false,

                        "badgeTitleSnapshot":
                            badgeTitle,

                        "badgeDescriptionSnapshot":
                            enrollment.badgeDescription,

                        "iconNameSnapshot":
                            badgeImageName,

                        "progressPercent":
                            summary.progressPercent,

                        "completionReason":
                            trigger.rawValue,

                        "createdAt":
                            now,

                        "updatedAt":
                            now
                    ]

                    transaction.setData(
                        earnedBadgeData,
                        forDocument: earnedBadgeRef
                    )
                }
            }

            return nil

        }) { _, error in

            if let error = error {

                completion(.failure(error))
                return
            }

            /*
             Transaction başarılı olduktan sonra enrollment'ı
             yeniden Firestore'dan okuyoruz.

             UI kendi tahminini yapmayacak.
             Firestore'daki kesin sonucu kullanacak.
            */

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

                    completion(
                        .failure(
                            NSError(
                                domain: "EnrollmentRepository",
                                code: -42,
                                userInfo: [
                                    NSLocalizedDescriptionKey:
                                        "Finalized enrollment yeniden okunamadı."
                                ]
                            )
                        )
                    )

                    return
                }

                if finalizedEnrollment.earnedBadge {

                    completion(
                        .success(
                            .completedWithBadge(
                                finalizedEnrollment
                            )
                        )
                    )

                } else {

                    completion(
                        .success(
                            .completedWithoutBadge(
                                finalizedEnrollment
                            )
                        )
                    )
                }
            }
        }
    }
    
    
    // MARK: - Completed Enrollments
//    func fetchCompletedEnrollments(
//        userId: String,
//        completion: @escaping (Result<[CompletedEnrollment], Error>) -> Void
//    ) {
//        
//        let enrollmentsRef = db
//            .collection(FirestoreCollection.users)
//            .document(userId)
//            .collection(FirestoreCollection.programEnrollments)
//        
//        enrollmentsRef.getDocuments { snapshot, error in
//            
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//            
//            let completed: [CompletedEnrollment] = snapshot?.documents.compactMap { document in
//                CompletedEnrollment(
//                    documentId: document.documentID,
//                    data: document.data()
//                )
//            } ?? []
//
//            let sorted = completed.sorted {
//                ($0.completedAt?.dateValue() ?? Date()) >
//                ($1.completedAt?.dateValue() ?? Date())
//            }
//            
//            completion(.success(sorted))
//        }
//    }

    
    // MARK: - Completed Enrollments

    func fetchCompletedEnrollments(
        userId: String,
        completion: @escaping (Result<[CompletedEnrollment], Error>) -> Void
    ) {

        let enrollmentsRef = db
            .collection(FirestoreCollection.users)
            .document(userId)
            .collection(FirestoreCollection.programEnrollments)


        // Offline tamamlanmış ama henüz Firebase'de finalize
        // edilmemiş enrollment'ları buluyoruz.
        let pendingFinalizations =
            PendingProgressManager.shared
                .loadAll()
                .filter {
                    $0.userId == userId &&
                    $0.shouldFinalizeProgram == true
                }


        var pendingByEnrollmentId:
            [String: PendingProgressAction] = [:]

        for action in pendingFinalizations {
            pendingByEnrollmentId[action.enrollmentId] = action
        }


        let source: FirestoreSource =
            NetworkMonitor.shared.isConnected
            ? .default
            : .cache


        enrollmentsRef.getDocuments(
            source: source
        ) { snapshot, error in

            if let error = error {

                completion(.failure(error))
                return
            }


            let completed: [CompletedEnrollment] =
                snapshot?.documents.compactMap { document in

                    var data = document.data()


                    // Eğer bu enrollment offline olarak programı
                    // tamamladıysa, SADECE UI için completed gibi
                    // decode ediyoruz.
                    //
                    // Firestore'a burada hiçbir şey yazılmıyor.
                    if let pendingAction =
                        pendingByEnrollmentId[
                            document.documentID
                        ] {

                        data["status"] = "completed"
                        data["isCompleted"] = true
                        data["isFailed"] = false

                        // Gerçek completedAt henüz backend'de yoksa
                        // offline completion zamanını göster.
                        if data["completedAt"] == nil {

                            data["completedAt"] =
                                Timestamp(
                                    date:
                                        pendingAction.createdAt
                                )
                        }
                    }


                    return CompletedEnrollment(
                        documentId:
                            document.documentID,
                        data:
                            data
                    )
                } ?? []


            let sorted = completed.sorted {

                ($0.completedAt?.dateValue() ?? Date())
                >
                ($1.completedAt?.dateValue() ?? Date())
            }


            completion(
                .success(sorted)
            )
        }
    }
    
    func completeJourney(
        userId: String,
        enrollmentId: String,
        note: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {

        let enrollmentRef = db
            .collection(FirestoreCollection.users)
            .document(userId)
            .collection(FirestoreCollection.programEnrollments)
            .document(enrollmentId)

        enrollmentRef.updateData([
            "completionNote": note,
            "updatedAt": Timestamp(date: Date())
        ]) { error in

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
