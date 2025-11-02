import SwiftUI
import WatchKit
import HealthKit
import WorkoutKit

@main
struct VitalSense_Watch_App: App {
    @StateObject private var workoutManager = WatchWorkoutManager()
    @StateObject private var healthManager = WatchHealthManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(workoutManager)
                .environmentObject(healthManager)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var workoutManager: WatchWorkoutManager
    @EnvironmentObject var healthManager: WatchHealthManager
    
    var body: some View {
        TabView {
            DashboardView()
                .tag(0)
            
            WorkoutView()
                .tag(1)
            
            HealthSummaryView()
                .tag(2)
        }
        .tabViewStyle(PageTabViewStyle())
        .onAppear {
            healthManager.requestHealthKitPermissions()
        }
    }
}

struct DashboardView: View {
    @EnvironmentObject var healthManager: WatchHealthManager
    @State private var gaitScore: Int = 78
    @State private var heartRate: Int = 72
    @State private var isDataLoaded = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // App Title
                Text("VitalSense")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding(.top, 8)
                
                // Main Gait Score
                VStack(spacing: 4) {
                    Text("\(gaitScore)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                    
                    Text("Gait Score")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
                
                // Heart Rate
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                    
                    Text("\(heartRate) BPM")
                        .font(.caption)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                // Quick Actions
                VStack(spacing: 8) {
                    NavigationLink(destination: WorkoutView()) {
                        HStack {
                            Image(systemName: "figure.walk")
                                .font(.caption)
                            Text("Start Workout")
                                .font(.caption2)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .cornerRadius(20)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    NavigationLink(destination: HealthSummaryView()) {
                        HStack {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.caption)
                            Text("View Health Data")
                                .font(.caption2)
                        }
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.blue, lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal)
                
                Spacer(minLength: 0)
            }
        }
        .onAppear {
            loadHealthData()
        }
    }
    
    private func loadHealthData() {
        guard !isDataLoaded else { return }
        
        healthManager.fetchLatestData { data in
            DispatchQueue.main.async {
                self.gaitScore = data.gaitScore ?? 78
                self.heartRate = Int(data.heartRate ?? 72)
                self.isDataLoaded = true
            }
        }
    }
}

struct WorkoutView: View {
    @EnvironmentObject var workoutManager: WatchWorkoutManager
    @State private var currentHeartRate: Int = 0
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 16) {
            if workoutManager.isWorkoutActive {
                // Active workout view
                VStack(spacing: 12) {
                    Text("Gait Analysis")
                        .font(.headline)
                        .foregroundColor(.green)
                    
                    // Timer
                    Text(timeString(from: elapsedTime))
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(.primary)
                    
                    // Heart Rate
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                        Text("\(currentHeartRate) BPM")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    
                    // Stop Button
                    Button(action: stopWorkout) {
                        HStack {
                            Image(systemName: "stop.fill")
                            Text("End Workout")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.red)
                        .cornerRadius(25)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            } else {
                // Start workout view
                VStack(spacing: 16) {
                    Image(systemName: "figure.walk.motion")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                    
                    Text("Ready for Gait Analysis")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                    
                    Text("Walk normally while wearing your Apple Watch")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button(action: startWorkout) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Start")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.green)
                        .cornerRadius(25)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding()
        .onReceive(workoutManager.$currentHeartRate) { heartRate in
            currentHeartRate = Int(heartRate)
        }
    }
    
    private func startWorkout() {
        workoutManager.startWorkout()
        startTimer()
    }
    
    private func stopWorkout() {
        workoutManager.stopWorkout()
        stopTimer()
        elapsedTime = 0
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            elapsedTime += 1.0
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct HealthSummaryView: View {
    @EnvironmentObject var healthManager: WatchHealthManager
    @State private var healthData: WatchHealthData = WatchHealthData()
    
    var body: some View {
        List {
            Section("Today's Metrics") {
                HealthMetricRow(
                    icon: "figure.walk",
                    title: "Steps",
                    value: "\(healthData.stepCount ?? 0)",
                    color: .green
                )
                
                HealthMetricRow(
                    icon: "speedometer",
                    title: "Walking Speed",
                    value: String(format: "%.1f mph", healthData.walkingSpeed ?? 0.0),
                    color: .blue
                )
                
                HealthMetricRow(
                    icon: "heart.fill",
                    title: "Heart Rate",
                    value: "\(Int(healthData.heartRate ?? 0)) BPM",
                    color: .red
                )
            }
            
            Section("Gait Analysis") {
                HealthMetricRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Gait Score",
                    value: "\(healthData.gaitScore ?? 0)/100",
                    color: .purple
                )
                
                HealthMetricRow(
                    icon: "exclamationmark.triangle",
                    title: "Fall Risk",
                    value: healthData.fallRisk ?? "Unknown",
                    color: healthData.fallRisk == "Low" ? .green : .orange
                )
            }
        }
        .onAppear {
            loadHealthData()
        }
    }
    
    private func loadHealthData() {
        healthManager.fetchLatestData { data in
            DispatchQueue.main.async {
                self.healthData = data
            }
        }
    }
}

struct HealthMetricRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 16)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Supporting Classes

class WatchWorkoutManager: NSObject, ObservableObject {
    @Published var isWorkoutActive = false
    @Published var currentHeartRate: Double = 0
    
    private let healthStore = HKHealthStore()
    private var workoutSession: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?
    
    override init() {
        super.init()
        setupWorkout()
    }
    
    private func setupWorkout() {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .walking
        configuration.locationType = .outdoor
        
        do {
            workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = workoutSession?.associatedWorkoutBuilder()
            
            workoutSession?.delegate = self
            builder?.delegate = self
            
            builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
        } catch {
            print("Failed to create workout session: \(error)")
        }
    }
    
    func startWorkout() {
        guard let workoutSession = workoutSession, let builder = builder else { return }
        
        let startDate = Date()
        workoutSession.startActivity(with: startDate)
        builder.beginCollection(withStart: startDate) { success, error in
            DispatchQueue.main.async {
                self.isWorkoutActive = success
            }
        }
    }
    
    func stopWorkout() {
        guard let workoutSession = workoutSession, let builder = builder else { return }
        
        workoutSession.end()
        builder.endCollection(withEnd: Date()) { success, error in
            DispatchQueue.main.async {
                self.isWorkoutActive = false
            }
        }
    }
}

extension WatchWorkoutManager: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        DispatchQueue.main.async {
            self.isWorkoutActive = (toState == .running)
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("Workout session failed: \(error)")
    }
}

extension WatchWorkoutManager: HKLiveWorkoutBuilderDelegate {
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            if type == HKQuantityType.quantityType(forIdentifier: .heartRate) {
                if let statistics = workoutBuilder.statistics(for: type) {
                    let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                    let value = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit) ?? 0
                    
                    DispatchQueue.main.async {
                        self.currentHeartRate = value
                    }
                }
            }
        }
    }
    
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        // Handle workout events
    }
}

class WatchHealthManager: ObservableObject {
    private let healthStore = HKHealthStore()
    
    func requestHealthKitPermissions() {
        let typesToRead: Set<HKObjectType> = [
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKQuantityType.quantityType(forIdentifier: .walkingSpeed)!,
            HKQuantityType.quantityType(forIdentifier: .heartRate)!
        ]
        
        healthStore.requestAuthorization(toShare: [], read: typesToRead) { success, error in
            if success {
                print("HealthKit authorization granted on Watch")
            } else {
                print("HealthKit authorization denied on Watch: \(error?.localizedDescription ?? "")")
            }
        }
    }
    
    func fetchLatestData(completion: @escaping (WatchHealthData) -> Void) {
        let group = DispatchGroup()
        var data = WatchHealthData()
        
        // Fetch step count
        group.enter()
        fetchStepCount { stepCount in
            data.stepCount = stepCount
            group.leave()
        }
        
        // Fetch walking speed
        group.enter()
        fetchWalkingSpeed { walkingSpeed in
            data.walkingSpeed = walkingSpeed
            group.leave()
        }
        
        // Fetch heart rate
        group.enter()
        fetchHeartRate { heartRate in
            data.heartRate = heartRate
            group.leave()
        }
        
        group.notify(queue: .main) {
            completion(data)
        }
    }
    
    private func fetchStepCount(completion: @escaping (Int?) -> Void) {
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
    
    private func fetchWalkingSpeed(completion: @escaping (Double?) -> Void) {
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
    
    private func fetchHeartRate(completion: @escaping (Double?) -> Void) {
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
}

struct WatchHealthData {
    var stepCount: Int?
    var walkingSpeed: Double?
    var heartRate: Double?
    var gaitScore: Int?
    var fallRisk: String?
    
    init() {}
}