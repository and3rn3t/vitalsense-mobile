import Foundation
import CoreMotion
import Combine

class GaitAnalyzer: ObservableObject {
    private let motionManager = CMMotionManager()
    private let pedometer = CMPedometer()
    
    @Published var isAnalyzing = false
    @Published var analysisProgress: Double = 0.0
    @Published var latestResult: GaitAnalysisResult?
    
    private var analysisTimer: Timer?
    private var motionData: [CMAccelerometerData] = []
    private var gyroscopeData: [CMGyroData] = []
    private var pedometerData: [CMPedometerData] = []
    
    // Analysis parameters from Config.plist
    private let minimumWalkingDuration: TimeInterval = 30.0 // 30 seconds minimum
    private let samplingFrequency: Double = 100.0 // 100 Hz
    private let fallRiskThreshold: Double = 0.75
    
    init() {
        setupMotionManager()
    }
    
    private func setupMotionManager() {
        motionManager.accelerometerUpdateInterval = 1.0 / samplingFrequency
        motionManager.gyroUpdateInterval = 1.0 / samplingFrequency
    }
    
    func startAnalysis(progressCallback: @escaping (Double) -> Void, completion: @escaping (GaitAnalysisResult) -> Void) {
        guard !isAnalyzing else { return }
        
        isAnalyzing = true
        motionData.removeAll()
        gyroscopeData.removeAll()
        pedometerData.removeAll()
        analysisProgress = 0.0
        
        // Check if motion data is available
        guard motionManager.isAccelerometerAvailable && motionManager.isGyroAvailable else {
            print("Motion sensors not available")
            isAnalyzing = false
            return
        }
        
        // Check pedometer authorization
        guard CMPedometer.authorizationStatus() == .authorized else {
            print("Pedometer not authorized")
            isAnalyzing = false
            return
        }
        
        startMotionUpdates()
        startPedometerUpdates()
        
        // Progress timer
        analysisTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.analysisProgress += 1.0 / self.minimumWalkingDuration
            progressCallback(self.analysisProgress)
            
            if self.analysisProgress >= 1.0 {
                self.stopAnalysis(completion: completion)
            }
        }
    }
    
    private func startMotionUpdates() {
        // Start accelerometer updates
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let data = data else { return }
            self?.motionData.append(data)
            
            // Keep only recent data to manage memory
            if let motionData = self?.motionData, motionData.count > Int(self?.samplingFrequency ?? 100) * 60 {
                self?.motionData.removeFirst()
            }
        }
        
        // Start gyroscope updates
        motionManager.startGyroUpdates(to: .main) { [weak self] data, error in
            guard let data = data else { return }
            self?.gyroscopeData.append(data)
            
            // Keep only recent data to manage memory
            if let gyroData = self?.gyroscopeData, gyroData.count > Int(self?.samplingFrequency ?? 100) * 60 {
                self?.gyroscopeData.removeFirst()
            }
        }
    }
    
    private func startPedometerUpdates() {
        let startDate = Date()
        
        pedometer.startUpdates(from: startDate) { [weak self] data, error in
            guard let data = data else { return }
            
            DispatchQueue.main.async {
                self?.pedometerData.append(data)
            }
        }
    }
    
    private func stopAnalysis(completion: @escaping (GaitAnalysisResult) -> Void) {
        isAnalyzing = false
        analysisTimer?.invalidate()
        analysisTimer = nil
        
        motionManager.stopAccelerometerUpdates()
        motionManager.stopGyroUpdates()
        pedometer.stopUpdates()
        
        // Process the collected data
        let result = processGaitData()
        latestResult = result
        
        completion(result)
    }
    
    private func processGaitData() -> GaitAnalysisResult {
        // This is a simplified gait analysis - in a real app you'd use more sophisticated algorithms
        
        // Calculate basic metrics from accelerometer data
        let walkingSpeed = calculateWalkingSpeed()
        let stepLength = calculateStepLength()
        let asymmetryPercentage = calculateAsymmetry()
        let doubleSupportPercentage = calculateDoubleSupportPercentage()
        let cadence = calculateCadence()
        
        // Calculate gait score (0-100)
        let gaitScore = calculateGaitScore(
            walkingSpeed: walkingSpeed,
            stepLength: stepLength,
            asymmetry: asymmetryPercentage,
            doubleSupport: doubleSupportPercentage,
            cadence: cadence
        )
        
        // Determine fall risk
        let fallRisk = determineFallRisk(gaitScore: gaitScore)
        
        return GaitAnalysisResult(
            walkingSpeed: walkingSpeed,
            stepLength: stepLength,
            asymmetryPercentage: asymmetryPercentage,
            doubleSupportPercentage: doubleSupportPercentage,
            cadence: cadence,
            gaitScore: gaitScore,
            fallRisk: fallRisk,
            date: Date()
        )
    }
    
    private func calculateWalkingSpeed() -> Double {
        // Use pedometer data if available
        if let latestPedometerData = pedometerData.last,
           let distance = latestPedometerData.distance,
           let duration = analysisTimer?.timeInterval {
            let speed = distance.doubleValue / duration // m/s
            return speed * 2.237 // Convert to mph
        }
        
        // Fallback: estimate from accelerometer data
        let avgAcceleration = motionData.reduce(0.0) { sum, data in
            sum + sqrt(pow(data.acceleration.x, 2) + pow(data.acceleration.y, 2) + pow(data.acceleration.z, 2))
        } / Double(motionData.count)
        
        // Simple estimation (this would be more sophisticated in a real app)
        return max(1.0, min(5.0, avgAcceleration * 1.5)) // mph
    }
    
    private func calculateStepLength() -> Double {
        // Estimate step length based on walking speed and cadence
        let speed = calculateWalkingSpeed()
        let cadence = calculateCadence()
        
        if cadence > 0 {
            let speedMPS = speed / 2.237 // Convert mph to m/s
            let stepLength = speedMPS / (cadence / 60.0) // meters per step
            return stepLength
        }
        
        return 0.65 // Average step length in meters
    }
    
    private func calculateAsymmetry() -> Double {
        // Analyze acceleration patterns to detect gait asymmetry
        guard motionData.count > 100 else { return 10.0 } // Default 10%
        
        // Simple asymmetry calculation based on acceleration variance
        let xVariance = calculateVariance(motionData.map { $0.acceleration.x })
        let yVariance = calculateVariance(motionData.map { $0.acceleration.y })
        
        let asymmetry = abs(xVariance - yVariance) / max(xVariance, yVariance) * 100
        return min(asymmetry, 50.0) // Cap at 50%
    }
    
    private func calculateDoubleSupportPercentage() -> Double {
        // Analyze when both feet are on the ground during gait cycle
        // This is a simplified calculation
        let avgMagnitude = motionData.reduce(0.0) { sum, data in
            sum + sqrt(pow(data.acceleration.x, 2) + pow(data.acceleration.y, 2) + pow(data.acceleration.z, 2))
        } / Double(motionData.count)
        
        // Higher acceleration magnitude typically indicates longer double support
        let doubleSupport = min(40.0, max(15.0, avgMagnitude * 15.0))
        return doubleSupport
    }
    
    private func calculateCadence() -> Double {
        // Use pedometer data if available
        if let latestPedometerData = pedometerData.last,
           let steps = latestPedometerData.numberOfSteps,
           let duration = analysisTimer?.timeInterval {
            let stepsPerMinute = steps.doubleValue / (duration / 60.0)
            return stepsPerMinute
        }
        
        // Fallback: estimate from accelerometer peaks
        let peaks = detectStepPeaks(in: motionData)
        let duration = minimumWalkingDuration / 60.0 // Convert to minutes
        return Double(peaks) / duration
    }
    
    private func calculateGaitScore(walkingSpeed: Double, stepLength: Double, asymmetry: Double, doubleSupport: Double, cadence: Double) -> Int {
        // Composite score based on multiple gait parameters
        // This would use validated clinical algorithms in a real app
        
        var score = 100.0
        
        // Penalize slow walking speed
        if walkingSpeed < 2.5 {
            score -= (2.5 - walkingSpeed) * 10
        }
        
        // Penalize high asymmetry
        if asymmetry > 15.0 {
            score -= (asymmetry - 15.0) * 2
        }
        
        // Penalize abnormal double support
        if doubleSupportPercentage > 30.0 || doubleSupportPercentage < 20.0 {
            score -= abs(doubleSupportPercentage - 25.0)
        }
        
        // Penalize abnormal cadence
        if cadence < 100 || cadence > 130 {
            score -= abs(cadence - 115) * 0.5
        }
        
        return max(0, min(100, Int(score)))
    }
    
    private func determineFallRisk(gaitScore: Int) -> GaitAnalysisResult.FallRiskLevel {
        switch gaitScore {
        case 80...100:
            return .low
        case 60...79:
            return .moderate
        default:
            return .high
        }
    }
    
    private func calculateVariance(_ values: [Double]) -> Double {
        guard values.count > 1 else { return 0.0 }
        
        let mean = values.reduce(0.0, +) / Double(values.count)
        let sumOfSquares = values.reduce(0.0) { sum, value in
            sum + pow(value - mean, 2)
        }
        
        return sumOfSquares / Double(values.count - 1)
    }
    
    private func detectStepPeaks(in data: [CMAccelerometerData]) -> Int {
        guard data.count > 10 else { return 0 }
        
        // Simple peak detection algorithm
        let threshold = 0.5 // Acceleration threshold for step detection
        var peakCount = 0
        var lastPeakIndex = 0
        
        for (index, accelerometerData) in data.enumerated() {
            let magnitude = sqrt(pow(accelerometerData.acceleration.x, 2) + 
                               pow(accelerometerData.acceleration.y, 2) + 
                               pow(accelerometerData.acceleration.z, 2))
            
            // Check if this is a peak (above threshold and separated from last peak)
            if magnitude > threshold && index - lastPeakIndex > 10 {
                // Verify it's actually a local maximum
                let windowStart = max(0, index - 5)
                let windowEnd = min(data.count - 1, index + 5)
                
                let isLocalMax = (windowStart..<windowEnd).allSatisfy { i in
                    let windowMagnitude = sqrt(pow(data[i].acceleration.x, 2) + 
                                             pow(data[i].acceleration.y, 2) + 
                                             pow(data[i].acceleration.z, 2))
                    return magnitude >= windowMagnitude
                }
                
                if isLocalMax {
                    peakCount += 1
                    lastPeakIndex = index
                }
            }
        }
        
        return peakCount
    }
}