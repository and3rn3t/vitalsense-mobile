#!/bin/bash

# VitalSense Project Setup Script
# Creates missing core files for the health monitoring app

echo "🔧 VitalSense Setup - Generating Core Files"
echo "==========================================="

# Create HealthKitManager.swift
cat > HealthKitManager.swift << 'EOF'
//
//  HealthKitManager.swift
//  VitalSense
//
//  Core HealthKit integration for health data management
//

import Foundation
import HealthKit
import Combine

@MainActor
class HealthKitManager: ObservableObject {
    private let healthStore = HKHealthStore()
    
    @Published var isHealthKitAvailable = false
    @Published var authorizationStatus: HKAuthorizationStatus = .notDetermined
    @Published var stepCount: Int = 0
    @Published var heartRate: Double = 0
    @Published var walkingSpeed: Double = 0
    
    // Health data types we want to read
    private let typesToRead: Set<HKObjectType> = [
        HKQuantityType.quantityType(forIdentifier: .stepCount)!,
        HKQuantityType.quantityType(forIdentifier: .heartRate)!,
        HKQuantityType.quantityType(forIdentifier: .walkingSpeed)!,
        HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKQuantityType.quantityType(forIdentifier: .appleWalkingSteadiness)!,
        HKCategoryType.categoryType(forIdentifier: .appleWalkingSteadinessEvent)!
    ]
    
    init() {
        checkHealthKitAvailability()
    }
    
    private func checkHealthKitAvailability() {
        isHealthKitAvailable = HKHealthStore.isHealthDataAvailable()
    }
    
    func requestHealthKitPermissions() {
        guard isHealthKitAvailable else {
            print("HealthKit not available on this device")
            return
        }
        
        healthStore.requestAuthorization(toShare: [], read: typesToRead) { success, error in
            DispatchQueue.main.async {
                if success {
                    self.authorizationStatus = .sharingAuthorized
                    self.startHealthDataCollection()
                } else {
                    self.authorizationStatus = .sharingDenied
                    print("HealthKit authorization failed: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
    
    private func startHealthDataCollection() {
        fetchStepCount()
        fetchLatestHeartRate()
        fetchWalkingSpeed()
    }
    
    private func fetchStepCount() {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            DispatchQueue.main.async {
                self.stepCount = Int(result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0)
            }
        }
        
        healthStore.execute(query)
    }
    
    private func fetchLatestHeartRate() {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, samples, _ in
            DispatchQueue.main.async {
                if let sample = samples?.first as? HKQuantitySample {
                    self.heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    private func fetchWalkingSpeed() {
        let walkingSpeedType = HKQuantityType.quantityType(forIdentifier: .walkingSpeed)!
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: walkingSpeedType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, samples, _ in
            DispatchQueue.main.async {
                if let sample = samples?.first as? HKQuantitySample {
                    self.walkingSpeed = sample.quantity.doubleValue(for: HKUnit(from: "m/s"))
                }
            }
        }
        
        healthStore.execute(query)
    }
}
EOF

# Create GaitAnalyzer.swift
cat > GaitAnalyzer.swift << 'EOF'
//
//  GaitAnalyzer.swift
//  VitalSense
//
//  Advanced gait analysis and fall risk assessment
//

import Foundation
import CoreMotion
import Combine

@MainActor
class GaitAnalyzer: ObservableObject {
    private let motionManager = CMMotionManager()
    private let pedometer = CMPedometer()
    
    @Published var isAnalyzing = false
    @Published var fallRiskScore: Double = 0.0 // 0.0 = low risk, 1.0 = high risk
    @Published var gaitStability: Double = 0.0
    @Published var stepRegularity: Double = 0.0
    @Published var walkingAsymmetry: Double = 0.0
    
    private var accelerometerData: [CMAccelerometerData] = []
    private var analysisTimer: Timer?
    
    init() {
        checkMotionAvailability()
    }
    
    private func checkMotionAvailability() {
        if !CMMotionManager().isAccelerometerAvailable {
            print("Accelerometer not available")
        }
        if !CMPedometer.isStepCountingAvailable() {
            print("Step counting not available")
        }
    }
    
    func startGaitAnalysis() {
        guard motionManager.isAccelerometerAvailable else {
            print("Accelerometer not available for gait analysis")
            return
        }
        
        isAnalyzing = true
        accelerometerData.removeAll()
        
        // Start accelerometer updates
        motionManager.accelerometerUpdateInterval = 1.0 / 50.0 // 50 Hz
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let data = data, error == nil else {
                print("Accelerometer error: \(error?.localizedDescription ?? "Unknown")")
                return
            }
            
            self?.accelerometerData.append(data)
            
            // Keep only last 500 samples (10 seconds at 50 Hz)
            if let dataCount = self?.accelerometerData.count, dataCount > 500 {
                self?.accelerometerData.removeFirst(dataCount - 500)
            }
        }
        
        // Start periodic analysis
        analysisTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            Task { @MainActor in
                self.performGaitAnalysis()
            }
        }
    }
    
    func stopGaitAnalysis() {
        isAnalyzing = false
        motionManager.stopAccelerometerUpdates()
        analysisTimer?.invalidate()
        analysisTimer = nil
    }
    
    private func performGaitAnalysis() {
        guard accelerometerData.count > 100 else { return }
        
        // Calculate gait metrics
        calculateStepRegularity()
        calculateGaitStability()
        calculateWalkingAsymmetry()
        calculateFallRiskScore()
    }
    
    private func calculateStepRegularity() {
        // Simplified step regularity calculation
        let accelerations = accelerometerData.map { sqrt($0.acceleration.x * $0.acceleration.x + $0.acceleration.y * $0.acceleration.y + $0.acceleration.z * $0.acceleration.z) }
        
        // Calculate variance in acceleration magnitude
        let mean = accelerations.reduce(0, +) / Double(accelerations.count)
        let variance = accelerations.map { pow($0 - mean, 2) }.reduce(0, +) / Double(accelerations.count)
        
        // Lower variance indicates more regular steps
        stepRegularity = max(0, 1.0 - (variance / 10.0))
    }
    
    private func calculateGaitStability() {
        // Simplified stability calculation based on acceleration variation
        let recentData = Array(accelerometerData.suffix(100))
        let xVariation = recentData.map { $0.acceleration.x }.standardDeviation()
        let yVariation = recentData.map { $0.acceleration.y }.standardDeviation()
        let zVariation = recentData.map { $0.acceleration.z }.standardDeviation()
        
        let totalVariation = (xVariation + yVariation + zVariation) / 3.0
        gaitStability = max(0, 1.0 - (totalVariation * 2.0))
    }
    
    private func calculateWalkingAsymmetry() {
        // Simplified asymmetry calculation
        let leftRightVariation = accelerometerData.suffix(100).map { abs($0.acceleration.x) }.standardDeviation()
        walkingAsymmetry = min(1.0, leftRightVariation * 3.0)
    }
    
    private func calculateFallRiskScore() {
        // Combine metrics into fall risk score
        let stabilityWeight = 0.4
        let regularityWeight = 0.3
        let asymmetryWeight = 0.3
        
        fallRiskScore = (1.0 - gaitStability) * stabilityWeight +
                       (1.0 - stepRegularity) * regularityWeight +
                       walkingAsymmetry * asymmetryWeight
        
        // Clamp to 0-1 range
        fallRiskScore = max(0, min(1.0, fallRiskScore))
    }
}

// Helper extension for standard deviation calculation
extension Array where Element: FloatingPoint {
    func standardDeviation() -> Element {
        let mean = self.reduce(0, +) / Element(self.count)
        let variance = self.map { pow($0 - mean, 2) }.reduce(0, +) / Element(self.count)
        return variance.squareRoot()
    }
}
EOF

# Create VitalSenseWatchApp.swift
cat > VitalSenseWatchApp.swift << 'EOF'
//
//  VitalSenseWatchApp.swift
//  VitalSenseWatch Watch App
//
//  Apple Watch companion app for VitalSense
//

import SwiftUI
import HealthKit
import WorkoutKit

@main
struct VitalSenseWatchApp: App {
    @StateObject private var workoutManager = WatchWorkoutManager()
    @StateObject private var healthKitManager = WatchHealthKitManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(workoutManager)
                .environmentObject(healthKitManager)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var workoutManager: WatchWorkoutManager
    @EnvironmentObject var healthKitManager: WatchHealthKitManager
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("VitalSense")
                    .font(.headline)
                    .foregroundColor(.blue)
                
                if workoutManager.isActive {
                    VStack(spacing: 10) {
                        Text("Active Session")
                            .font(.caption)
                            .foregroundColor(.green)
                        
                        Text("\(workoutManager.heartRate, specifier: "%.0f") BPM")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Button("Stop") {
                            workoutManager.endWorkout()
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                    }
                } else {
                    VStack(spacing: 10) {
                        Text("Ready to Track")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button("Start Gait Analysis") {
                            workoutManager.startWorkout()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                
                HStack {
                    VStack {
                        Text("Steps")
                            .font(.caption2)
                        Text("\(healthKitManager.stepCount)")
                            .font(.headline)
                    }
                    
                    Spacer()
                    
                    VStack {
                        Text("Fall Risk")
                            .font(.caption2)
                        Text(riskLevel(healthKitManager.fallRisk))
                            .font(.headline)
                            .foregroundColor(riskColor(healthKitManager.fallRisk))
                    }
                }
                .padding(.horizontal)
            }
            .padding()
        }
    }
    
    private func riskLevel(_ risk: Double) -> String {
        switch risk {
        case 0..<0.3: return "Low"
        case 0.3..<0.7: return "Medium"
        default: return "High"
        }
    }
    
    private func riskColor(_ risk: Double) -> Color {
        switch risk {
        case 0..<0.3: return .green
        case 0.3..<0.7: return .yellow
        default: return .red
        }
    }
}

@MainActor
class WatchWorkoutManager: ObservableObject {
    @Published var isActive = false
    @Published var heartRate: Double = 0
    
    private let healthStore = HKHealthStore()
    private var workoutSession: HKWorkoutSession?
    
    func startWorkout() {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .walking
        configuration.locationType = .indoor
        
        do {
            workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            workoutSession?.delegate = self
            workoutSession?.startActivity(with: Date())
            isActive = true
        } catch {
            print("Failed to start workout: \(error)")
        }
    }
    
    func endWorkout() {
        workoutSession?.end()
        isActive = false
        workoutSession = nil
    }
}

extension WatchWorkoutManager: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        // Handle workout state changes
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("Workout failed: \(error)")
        DispatchQueue.main.async {
            self.isActive = false
        }
    }
}

@MainActor
class WatchHealthKitManager: ObservableObject {
    @Published var stepCount: Int = 0
    @Published var fallRisk: Double = 0.2
    
    private let healthStore = HKHealthStore()
    
    init() {
        if HKHealthStore.isHealthDataAvailable() {
            requestPermissions()
        }
    }
    
    private func requestPermissions() {
        let types: Set<HKObjectType> = [
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKQuantityType.quantityType(forIdentifier: .heartRate)!
        ]
        
        healthStore.requestAuthorization(toShare: types, read: types) { success, error in
            if success {
                DispatchQueue.main.async {
                    self.fetchStepCount()
                }
            }
        }
    }
    
    private func fetchStepCount() {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            DispatchQueue.main.async {
                self.stepCount = Int(result?.sumQuantity()?.doubleValue(for: .count()) ?? 0)
            }
        }
        
        healthStore.execute(query)
    }
}
EOF

# Create basic Info.plist
cat > Info.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSHealthShareUsageDescription</key>
    <string>VitalSense needs access to your health data to provide gait analysis and fall risk assessment.</string>
    <key>NSHealthUpdateUsageDescription</key>
    <string>VitalSense needs to update your health data to record workout sessions and health metrics.</string>
    <key>NSMotionUsageDescription</key>
    <string>VitalSense uses motion data to analyze your gait and assess fall risk.</string>
    <key>CFBundleDisplayName</key>
    <string>VitalSense</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
</dict>
</plist>
EOF

# Create entitlements file
cat > VitalSense.entitlements << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.healthkit</key>
    <true/>
    <key>com.apple.developer.healthkit.access</key>
    <array/>
</dict>
</plist>
EOF

echo "✅ Core files created successfully!"
echo ""
echo "📁 Generated files:"
echo "  • HealthKitManager.swift - Health data integration"
echo "  • GaitAnalyzer.swift - Gait analysis engine" 
echo "  • VitalSenseWatchApp.swift - Apple Watch app"
echo "  • Info.plist - App permissions and metadata"
echo "  • VitalSense.entitlements - HealthKit entitlements"
echo ""
echo "🚀 Ready to import into Xcode!"