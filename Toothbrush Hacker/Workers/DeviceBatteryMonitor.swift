//
//  DeviceBatteryMonitor.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/27/23.
//

import Foundation
import Combine
import CoreBluetooth

protocol DeviceBatteryMonitor {
    
    var batteryLevelPublisher: Published<Double?>.Publisher { get }
}

class BleDeviceBatteryMonitor: DeviceBatteryMonitor {
    
    @Published var currentBatteryLevel: Double? = nil
    var batteryLevelPublisher: Published<Double?>.Publisher { $currentBatteryLevel }

    let deviceCommunicator: BleDeviceCommunicator
    let batteryService = BatteryService()
    
    var subs: Set<AnyCancellable> = []
    
    init(device: CBPeripheral) {
        let communicator = BleDeviceCommunicator.getOrCreate(from: device)
        communicator.add(services: [batteryService])
        deviceCommunicator = communicator
        
        setupBatteryLevelSub()
    }
    
    private func setupBatteryLevelSub() {
        batteryService.batteryLevelPublisher
            .sink { self.currentBatteryLevel = $0 }
            .store(in: &subs)
    }
}
