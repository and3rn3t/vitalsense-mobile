import SwiftUI
import HealthKit
import CoreMotion

@main
struct VitalSenseApp: App {
    @StateObject private var healthManager = HealthKitManager()
    @StateObject private var gaitAnalyzer = GaitAnalyzer()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(healthManager)
                .environmentObject(gaitAnalyzer)
                .onAppear {
                    healthManager.requestHealthKitPermissions()
                }
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var healthManager: HealthKitManager
    @EnvironmentObject var gaitAnalyzer: GaitAnalyzer
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Dashboard")
                }
                .tag(0)
            
            GaitAnalysisView()
                .tabItem {
                    Image(systemName: "figure.walk")
                    Text("Gait Analysis")
                }
                .tag(1)
            
            HealthDataView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Health Data")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(3)
        }
        .accentColor(.blue)
    }
}

struct DashboardView: View {
    @EnvironmentObject var healthManager: HealthKitManager
    @State private var gaitScore: Int = 78
    @State private var fallRisk: String = "Low"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack {
                        Text("VitalSense")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        
                        Text("Health Dashboard")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    // Main Health Score
                    VStack {
                        ZStack {
                            Circle()
                                .stroke(Color.blue.opacity(0.3), lineWidth: 20)
                                .frame(width: 200, height: 200)
                            
                            Circle()
                                .trim(from: 0, to: CGFloat(gaitScore) / 100)
                                .stroke(Color.blue, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                                .frame(width: 200, height: 200)
                                .rotationEffect(.degrees(-90))
                            
                            VStack {
                                Text("\(gaitScore)")
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(.blue)
                                
                                Text("Gait Score")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Text("Fall Risk: \(fallRisk)")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(fallRisk == "Low" ? .green : .orange)
                            .padding(.top)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    
                    // Quick Stats
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 15) {
                        HealthStatCard(title: "Steps Today", value: "8,247", icon: "figure.walk", color: .green)
                        HealthStatCard(title: "Walking Speed", value: "3.2 mph", icon: "speedometer", color: .blue)
                        HealthStatCard(title: "Balance Score", value: "85%", icon: "scale.3d", color: .purple)
                        HealthStatCard(title: "Heart Rate", value: "72 BPM", icon: "heart.fill", color: .red)
                    }
                    
                    // Start Analysis Button
                    Button(action: {
                        // Navigate to gait analysis
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Start Gait Analysis")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            loadHealthData()
        }
    }
    
    private func loadHealthData() {
        // Load recent health data from HealthKit
        healthManager.fetchLatestHealthData { data in
            DispatchQueue.main.async {
                // Update UI with real health data
                self.gaitScore = data.gaitScore ?? 78
                self.fallRisk = data.fallRisk ?? "Low"
            }
        }
    }
}

struct HealthStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct GaitAnalysisView: View {
    @EnvironmentObject var gaitAnalyzer: GaitAnalyzer
    @State private var isAnalyzing = false
    @State private var analysisProgress: Double = 0.0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Gait Analysis")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                if isAnalyzing {
                    VStack(spacing: 20) {
                        ProgressView(value: analysisProgress)
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            .scaleEffect(2.0)
                        
                        Text("Analyzing your walking pattern...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Keep your phone in your pocket and walk normally")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "figure.walk.motion")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        Text("Ready to analyze your gait")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("This analysis will take about 2-3 minutes of normal walking")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        Button(action: startGaitAnalysis) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Start Analysis")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 40)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
    
    private func startGaitAnalysis() {
        isAnalyzing = true
        gaitAnalyzer.startAnalysis { progress in
            DispatchQueue.main.async {
                self.analysisProgress = progress
            }
        } completion: { result in
            DispatchQueue.main.async {
                self.isAnalyzing = false
                // Handle analysis results
            }
        }
    }
}

struct HealthDataView: View {
    @EnvironmentObject var healthManager: HealthKitManager
    
    var body: some View {
        NavigationView {
            List {
                Section("Recent Measurements") {
                    HealthDataRow(title: "Walking Speed", value: "3.2 mph", date: "Today")
                    HealthDataRow(title: "Step Length", value: "68 cm", date: "Today")
                    HealthDataRow(title: "Cadence", value: "112 steps/min", date: "Today")
                    HealthDataRow(title: "Double Support", value: "28%", date: "Today")
                }
                
                Section("Apple Health Integration") {
                    Button("Export to Health App") {
                        healthManager.exportToHealthApp()
                    }
                    .foregroundColor(.blue)
                    
                    Button("Share with Healthcare Provider") {
                        // Share functionality
                    }
                    .foregroundColor(.blue)
                }
                
                Section("Privacy") {
                    NavigationLink("Data & Privacy Settings") {
                        PrivacySettingsView()
                    }
                }
            }
            .navigationTitle("Health Data")
        }
    }
}

struct HealthDataRow: View {
    let title: String
    let value: String
    let date: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
        }
        .padding(.vertical, 4)
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                Section("Permissions") {
                    NavigationLink("HealthKit Permissions") {
                        HealthKitPermissionsView()
                    }
                    NavigationLink("Motion & Fitness") {
                        MotionPermissionsView()
                    }
                }
                
                Section("Analysis Settings") {
                    NavigationLink("Gait Analysis Preferences") {
                        GaitPreferencesView()
                    }
                    NavigationLink("Notification Settings") {
                        NotificationSettingsView()
                    }
                }
                
                Section("Apple Watch") {
                    NavigationLink("Watch App Settings") {
                        WatchSettingsView()
                    }
                }
                
                Section("About") {
                    NavigationLink("Privacy Policy") {
                        PrivacyPolicyView()
                    }
                    NavigationLink("Medical Disclaimer") {
                        MedicalDisclaimerView()
                    }
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

// Placeholder views for navigation
struct HealthKitPermissionsView: View {
    var body: some View {
        Text("HealthKit Permissions Settings")
            .navigationTitle("HealthKit")
    }
}

struct MotionPermissionsView: View {
    var body: some View {
        Text("Motion & Fitness Permissions")
            .navigationTitle("Motion & Fitness")
    }
}

struct GaitPreferencesView: View {
    var body: some View {
        Text("Gait Analysis Preferences")
            .navigationTitle("Gait Analysis")
    }
}

struct NotificationSettingsView: View {
    var body: some View {
        Text("Notification Settings")
            .navigationTitle("Notifications")
    }
}

struct WatchSettingsView: View {
    var body: some View {
        Text("Apple Watch Settings")
            .navigationTitle("Apple Watch")
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy Policy")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("VitalSense is committed to protecting your privacy and health data...")
                    .font(.body)
                
                // Add full privacy policy content here
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
    }
}

struct MedicalDisclaimerView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Medical Disclaimer")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("IMPORTANT: This app is for informational purposes only and should not be used for medical diagnosis or treatment...")
                    .font(.body)
                
                // Add full medical disclaimer
            }
            .padding()
        }
        .navigationTitle("Medical Disclaimer")
    }
}

struct PrivacySettingsView: View {
    var body: some View {
        List {
            Section("Data Collection") {
                Text("Health data is processed locally on your device")
                Text("No personal information is shared without consent")
            }
            
            Section("Data Retention") {
                Button("Delete All Data") {
                    // Delete user data
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("Privacy Settings")
    }
}