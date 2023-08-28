//
//  BatteryService.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/27/23.
//

import Foundation
import CoreBluetooth

class BatteryService: DeviceBatteryMonitor {
    
    static let uuid = CBUUID(string: "180F")
    
    @Published var currentBatteryLevel: Float = 0
    var currentBatteryLevelPublisher: Published<Float>.Publisher { $currentBatteryLevel }
}
