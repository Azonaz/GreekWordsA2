import Foundation
import Combine

final class TrainingAccessManager: ObservableObject {
    private let kvs = NSUbiquitousKeyValueStore.default

    private let trialStartKey = "trainingTrialStartDate"
    private let unlockKey = "trainingUnlocked"

    @Published private(set) var hasAccess: Bool = false
    @Published private(set) var isInTrial: Bool = false
    @Published private(set) var daysLeft: Int?

    private let trialDurationDays = 7

    init() {
        refreshState()
    }

    /// Call when attempting to open a training.
    /// If the trial has not yet started, start it.
    func startTrialIfNeeded() {
        kvs.synchronize()

        if kvs.object(forKey: trialStartKey) as? Date == nil {
            kvs.set(Date(), forKey: trialStartKey)
            kvs.synchronize()
        }

        refreshState()
    }

    /// Recalculate the state
    func refreshState() {
        kvs.synchronize()

        // If already purchased, we simply grant access (we will add the purchase logic later).
        if kvs.bool(forKey: unlockKey) == true {
            hasAccess = true
            isInTrial = false
            daysLeft = nil
            return
        }

        guard let startDate = kvs.object(forKey: trialStartKey) as? Date else {
            // The trial hasn't started yet — there's no access yet,
            // but as soon as the user clicks on ‘Training’,
            // we'll start the trial in startTrialIfNeeded()
            hasAccess = false
            isInTrial = false
            daysLeft = nil
            return
        }

        let now = Date()
        let secondsInDay: TimeInterval = 24 * 60 * 60
        let interval = now.timeIntervalSince(startDate)
        let daysPassed = Int(interval / secondsInDay)

        if daysPassed < trialDurationDays {
            hasAccess = true
            isInTrial = true
            daysLeft = max(trialDurationDays - daysPassed, 0)
        } else {
            hasAccess = false
            isInTrial = false
            daysLeft = 0
        }
    }

    /// Unlock access
    func setUnlocked() {
        kvs.set(true, forKey: unlockKey)
        kvs.synchronize()
        refreshState()
    }
}
