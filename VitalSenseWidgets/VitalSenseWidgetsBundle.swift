//
//  VitalSenseWidgetsBundle.swift
//  VitalSenseWidgets
//
//  Main widget bundle - consolidated to avoid duplication
//  Created: 2025-11-01
//

import WidgetKit
import SwiftUI

@main
struct VitalSenseWidgetsBundle: WidgetBundle {
    var body: some Widget {
        // Only include the basic working widget
        VitalSenseWidgets()
    }
}
