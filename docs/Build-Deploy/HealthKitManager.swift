import Foundation
import HealthKit
import Combine
import UIKit

class HealthKitManager: ObservableObject {
    private let healthStore = HKHealthStore()
    
    @Published var isHealthKitAvailable = false
    @Published var authorizationStatus: HKAuthorizationStatus = .notDetermined
    
    // Health data types we need
    private let healthDataTypesToRead: Set<HKObjectType> = [
        HKQuantityType.quantityType(forIdentifier: .stepCount)!,
        HKQuantityType.quantityType(forIdentifier: .walkingSpeed)!,
        HKQuantityType.quantityType(forIdentifier: .walkingStepLength)!,
        HKQuantityType.quantityType(forIdentifier: .walkingAsymmetryPercentage)!,
        HKQuantityType.quantityType(forIdentifier: .walkingDoubleSupportPercentage)!,
        HKQuantityType.quantityType(forIdentifier: .sixMinuteWalkTestDistance)!,
        HKQuantityType.quantityType(forIdentifier: .heartRate)!,
        HKCategoryType.categoryType(forIdentifier: .appleWalkingSteadinessEvent)!
    ]
    
    private let healthDataTypesToWrite: Set<HKSampleType> = [
        HKQuantityType.quantityType(forIdentifier: .walkingSpeed)!,
        HKQuantityType.quantityType(forIdentifier: .walkingStepLength)!,
        HKQuantityType.quantityType(forIdentifier: .walkingAsymmetryPercentage)!,
        HKQuantityType.quantityType(forIdentifier: .walkingDoubleSupportPercentage)!
    ]
    
    init() {
        isHealthKitAvailable = HKHealthStore.isHealthDataAvailable()
    }
    
    func requestHealthKitPermissions() {
        guard isHealthKitAvailable else {
            print("HealthKit is not available on this device")
            return
        }
        
        healthStore.requestAuthorization(toShare: healthDataTypesToWrite, read: healthDataTypesToRead) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.authorizationStatus = .sharingAuthorized
                    print("HealthKit authorization granted")
                } else {
                    self?.authorizationStatus = .sharingDenied
                    print("HealthKit authorization denied: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
    
    func fetchLatestHealthData(completion: @escaping (HealthData) -> Void) {
        let group = DispatchGroup()
        var healthData = HealthData()
        
        // Fetch step count
        group.enter()
        fetchLatestStepCount { stepCount in
            healthData.stepCount = stepCount
            group.leave()
        }
        
        // Fetch walking speed
        group.enter()
        fetchLatestWalkingSpeed { walkingSpeed in
            healthData.walkingSpeed = walkingSpeed
            group.leave()
        }
        
        // Fetch heart rate
        group.enter()
        fetchLatestHeartRate { heartRate in
            healthData.heartRate = heartRate
            group.leave()
        }
        
        group.notify(queue: .main) {
            completion(healthData)
        }
    }
    
    private func fetchLatestStepCount(completion: @escaping (Int?) -> Void) {
        guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion(nil)
            return
        }
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepCountType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(nil)
                return
            }
            
            let stepCount = Int(sum.doubleValue(for: HKUnit.count()))
            completion(stepCount)
        }
        
        healthStore.execute(query)
    }
    
    private func fetchLatestWalkingSpeed(completion: @escaping (Double?) -> Void) {
        guard let walkingSpeedType = HKQuantityType.quantityType(forIdentifier: .walkingSpeed) else {
            completion(nil)
            return
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: walkingSpeedType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, samples, _ in
            guard let sample = samples?.first as? HKQuantitySample else {
                completion(nil)
                return
            }
            
            let speed = sample.quantity.doubleValue(for: HKUnit.mile().unitDivided(by: HKUnit.hour()))
            completion(speed)
        }
        
        healthStore.execute(query)
    }
    
    private func fetchLatestHeartRate(completion: @escaping (Double?) -> Void) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            completion(nil)
            return
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, samples, _ in
            guard let sample = samples?.first as? HKQuantitySample else {
                completion(nil)
                return
            }
            
            let heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            completion(heartRate)
        }
        
        healthStore.execute(query)
    }
    
    func saveGaitAnalysisResults(_ results: GaitAnalysisResult) {
        let samples: [HKQuantitySample] = [
            createQuantitySample(for: .walkingSpeed, value: results.walkingSpeed, unit: HKUnit.mile().unitDivided(by: HKUnit.hour())),
            createQuantitySample(for: .walkingStepLength, value: results.stepLength, unit: HKUnit.meter()),
            createQuantitySample(for: .walkingAsymmetryPercentage, value: results.asymmetryPercentage, unit: HKUnit.percent()),
            createQuantitySample(for: .walkingDoubleSupportPercentage, value: results.doubleSupportPercentage, unit: HKUnit.percent())
        ].compactMap { $0 }
        
        healthStore.save(samples) { success, error in
            if success {
                print("Gait analysis results saved to HealthKit")
            } else {
                print("Failed to save gait analysis results: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    private func createQuantitySample(for identifier: HKQuantityTypeIdentifier, value: Double, unit: HKUnit) -> HKQuantitySample? {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: identifier) else {
            return nil
        }
        
        let quantity = HKQuantity(unit: unit, doubleValue: value)
        let now = Date()
        
        return HKQuantitySample(type: quantityType, quantity: quantity, start: now, end: now)
    }
    
    func exportToHealthApp() {
        // Open the Health app if available
        if let healthURL = URL(string: "x-apple-health://") {
            if UIKit.UIApplication.shared.canOpenURL(healthURL) {
                UIKit.UIApplication.shared.open(healthURL)
            }
        }
    }
    
    // MARK: - Background Delivery
    func enableBackgroundDelivery() {
        guard authorizationStatus == .sharingAuthorized else { return }
        
        let healthTypesToObserve = [
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKQuantityType.quantityType(forIdentifier: .walkingSpeed)!,
            HKQuantityType.quantityType(forIdentifier: .heartRate)!
        ]
        
        for type in healthTypesToObserve {
            let query = HKObserverQuery(sampleType: type, predicate: nil) { [weak self] _, completionHandler, error in
                if let error = error {
                    print("Observer query error: \(error.localizedDescription)")
                } else {
                    print("New health data available for: \(type.identifier)")
                    // Trigger app refresh or notification
                }
                completionHandler()
            }
            
            healthStore.execute(query)
            healthStore.enableBackgroundDelivery(for: type, frequency: .immediate) { success, error in
                if success {
                    print("Background delivery enabled for \(type.identifier)")
                } else {
                    print("Failed to enable background delivery: \(error?.localizedDescription ?? "")")
                }
            }
        }
    }
    
    // MARK: - Privacy and Data Export
    func exportHealthDataForSharing() -> String {
        // Create a formatted summary for sharing with healthcare providers
        var exportString = "VitalSense Health Report\n"
        exportString += "Generated: \(Date())\n\n"
        exportString += "=== Gait Analysis Summary ===\n"
        
        if let latestResult = latestGaitResult {
            exportString += "Walking Speed: \(String(format: "%.1f", latestResult.walkingSpeed)) mph\n"
            exportString += "Step Length: \(String(format: "%.2f", latestResult.stepLength)) m\n"
            exportString += "Gait Asymmetry: \(String(format: "%.1f", latestResult.asymmetryPercentage))%\n"
            exportString += "Double Support: \(String(format: "%.1f", latestResult.doubleSupportPercentage))%\n"
            exportString += "Cadence: \(String(format: "%.0f", latestResult.cadence)) steps/min\n"
            exportString += "Gait Score: \(latestResult.gaitScore)/100\n"
            exportString += "Fall Risk: \(latestResult.fallRisk.rawValue)\n"
            exportString += "Assessment Date: \(latestResult.date)\n"
        }
        
        exportString += "\n=== Medical Disclaimer ===\n"
        exportString += "This report is for informational purposes only and should not be used for medical diagnosis or treatment. Please consult with qualified healthcare professionals.\n"
        
        return exportString
    }
    
    // Store latest gait result for export
    private var latestGaitResult: GaitAnalysisResult?
    
    func updateLatestGaitResult(_ result: GaitAnalysisResult) {
        latestGaitResult = result
    }
}

struct HealthData {
    var stepCount: Int?
    var walkingSpeed: Double?
    var heartRate: Double?
    var gaitScore: Int?
    var fallRisk: String?
    
    init() {}
}

struct GaitAnalysisResult {
    let walkingSpeed: Double
    let stepLength: Double
    let asymmetryPercentage: Double
    let doubleSupportPercentage: Double
    let cadence: Double
    let gaitScore: Int
    let fallRisk: FallRiskLevel
    let date: Date
    
    enum FallRiskLevel: String, CaseIterable {
        case low = "Low"
        case moderate = "Moderate"
        case high = "High"
        
        var color: String {
            switch self {
            case .low: return "green"
            case .moderate: return "orange"
            case .high: return "red"
            }
        }
    }
}