//
//  LearnProgressManager.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//

import SwiftUI
import Observation

// Tracks per-group, per-module learning progress using UserDefaults.
@Observable
class LearnProgressManager {
    static let shared = LearnProgressManager()

    // Keys are formatted as "learn_<group>_<module>_step" and "learn_<group>_<module>_total"
    private let defaults = UserDefaults.standard
    /// Incremented whenever progress data changes so @Observable views re-render.
    var _updateToken: Int = 0

    private init() {}

    // MARK: - Step Progress

    private func stepKey(group: HydrocarbonGroup, module: String) -> String {
        "learn_\(group.rawValue)_\(module)_step"
    }

    private func totalKey(group: HydrocarbonGroup, module: String) -> String {
        "learn_\(group.rawValue)_\(module)_total"
    }

    private func completedKey(group: HydrocarbonGroup, module: String) -> String {
        "learn_\(group.rawValue)_\(module)_completed"
    }

    func lastStep(group: HydrocarbonGroup, module: String) -> Int {
        defaults.integer(forKey: stepKey(group: group, module: module))
    }

    func saveStep(group: HydrocarbonGroup, module: String, step: Int, total: Int) {
        defaults.set(step, forKey: stepKey(group: group, module: module))
        defaults.set(total, forKey: totalKey(group: group, module: module))
        _updateToken += 1
    }

    func markCompleted(group: HydrocarbonGroup, module: String) {
        defaults.set(true, forKey: completedKey(group: group, module: module))
        _updateToken += 1
    }

    func isCompleted(group: HydrocarbonGroup, module: String) -> Bool {
        defaults.bool(forKey: completedKey(group: group, module: module))
    }

    func hasStarted(group: HydrocarbonGroup, module: String) -> Bool {
        defaults.integer(forKey: stepKey(group: group, module: module)) > 0 ||
        defaults.bool(forKey: completedKey(group: group, module: module))
    }

    func progress(group: HydrocarbonGroup, module: String) -> Double {
        let total = defaults.integer(forKey: totalKey(group: group, module: module))
        guard total > 0 else { return 0 }
        if isCompleted(group: group, module: module) { return 1.0 }
        let step = defaults.integer(forKey: stepKey(group: group, module: module))
        return Double(step) / Double(total)
    }

    // Overall progress for a group across all 3 modules.
    func groupProgress(group: HydrocarbonGroup) -> Double {
        let modules = ["naming", "structure", "reactions"]
        let total = modules.reduce(0.0) { $0 + progress(group: group, module: $1) }
        return total / Double(modules.count)
    }

    // Button text for a module.
    func actionText(group: HydrocarbonGroup, module: String) -> String {
        if isCompleted(group: group, module: module) {
            return "Review"
        } else if hasStarted(group: group, module: module) {
            return "Continue"
        }
        return "Start"
    }
}
