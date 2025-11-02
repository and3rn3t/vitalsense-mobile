//
//  GaitAnalyzerTests.swift
//  VitalSenseTests
//
//  Unit tests for gait analysis functionality
//

import XCTest
import CoreMotion
@testable import VitalSense

final class GaitAnalyzerTests: XCTestCase {
    var gaitAnalyzer: GaitAnalyzer!
    
    override func setUpWithError() throws {
        gaitAnalyzer = GaitAnalyzer()
    }
    
    override func tearDownWithError() throws {
        gaitAnalyzer = nil
    }
    
    func testGaitAnalyzerInitialization() throws {
        XCTAssertNotNil(gaitAnalyzer)
        XCTAssertFalse(gaitAnalyzer.isAnalyzing)
        XCTAssertEqual(gaitAnalyzer.fallRiskScore, 0.0)
        XCTAssertEqual(gaitAnalyzer.gaitStability, 0.0)
    }
    
    func testFallRiskScoreRange() throws {
        // Test that fall risk score is always in valid range (0.0 to 1.0)
        XCTAssertGreaterThanOrEqual(gaitAnalyzer.fallRiskScore, 0.0)
        XCTAssertLessThanOrEqual(gaitAnalyzer.fallRiskScore, 1.0)
    }
    
    func testGaitStabilityRange() throws {
        // Test that gait stability is always in valid range (0.0 to 1.0)
        XCTAssertGreaterThanOrEqual(gaitAnalyzer.gaitStability, 0.0)
        XCTAssertLessThanOrEqual(gaitAnalyzer.gaitStability, 1.0)
    }
    
    // Add more gait analysis tests
    func testStandardDeviationCalculation() throws {
        let testData: [Double] = [1.0, 2.0, 3.0, 4.0, 5.0]
        let standardDev = testData.standardDeviation()
        XCTAssertGreaterThan(standardDev, 0)
        XCTAssertLessThan(standardDev, 10) // Reasonable range
    }
}
