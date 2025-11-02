//
//  AnderMotionApp.swift
//  AnderMotion
//
//  Created by Matthew Anderson on 11/2/25.
//

import SwiftUI
import HealthKit
import WatchConnectivity

@main
struct AnderMotionApp: App {
    // Core managers - shared across the app
    @StateObject private var healthKitManager = HealthKitManager()
    @StateObject private var gaitAnalyzer = GaitAnalyzer()
    @StateObject private var watchConnectivityManager = WatchConnectivityManager()

    // App state
    @AppStorage("hasAcceptedHealthDisclaimer") private var hasAcceptedDisclaimer = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    MainTabView()
                } else {
                    OnboardingView()
                }
            }
            .environmentObject(healthKitManager)
            .environmentObject(gaitAnalyzer)
            .environmentObject(watchConnectivityManager)
            .onAppear {
                setupApp()
            }
        }
    }

    private func setupApp() {
        // Initialize Watch Connectivity if available
        if WCSession.isSupported() {
            watchConnectivityManager.activate()
        }

        // Request permissions if disclaimer accepted
        if hasAcceptedDisclaimer {
            healthKitManager.requestHealthKitPermissions()
        }
    }
}

// MARK: - Main App Interface
struct MainTabView: View {
    @EnvironmentObject var healthKitManager: HealthKitManager
    @EnvironmentObject var gaitAnalyzer: GaitAnalyzer

    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.line.uptrend.xyaxis")
                }

            GaitAnalysisView()
                .tabItem {
                    Label("Analysis", systemImage: "figure.walk")
                }

            HealthDataView()
                .tabItem {
                    Label("Health", systemImage: "heart.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

// MARK: - Watch Connectivity Manager
class WatchConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    @Published var isWatchAppInstalled = false
    @Published var isWatchConnected = false

    override init() {
        super.init()
    }

    func activate() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    func sendDataToWatch(_ data: [String: Any]) {
        guard WCSession.default.isReachable else { return }

        WCSession.default.sendMessage(data, replyHandler: nil) { error in
            print("Failed to send data to watch: \(error.localizedDescription)")
        }
    }

    // MARK: - WCSessionDelegate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isWatchConnected = activationState == .activated
            self.isWatchAppInstalled = session.isWatchAppInstalled
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isWatchConnected = false
        }
    }

    func sessionDidDeactivate(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isWatchConnected = false
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // Handle messages from watch
        DispatchQueue.main.async {
            // Process watch data
        }
    }
}
