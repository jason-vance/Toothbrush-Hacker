//
//  BatteryMonitor.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/27/23.
//

import Foundation
import Combine
import CoreBluetooth

protocol BatteryMonitor {
    var batteryLevelPublisher: Published<Double?>.Publisher { get }
}

class BlePeripheralBatteryMonitor: BatteryMonitor {
    
    @Published var currentBatteryLevel: Double? = nil
    var batteryLevelPublisher: Published<Double?>.Publisher { $currentBatteryLevel }

    let deviceCommunicator: BlePeripheralCommunicator
    let batteryService: BatteryService
    
    var subs: Set<AnyCancellable> = []
    
    init(device: CBPeripheral) {
        deviceCommunicator = BlePeripheralCommunicator.getOrCreate(from: device)
        batteryService = BatteryService(communicator: deviceCommunicator)
        
        setupBatteryLevelSub()
        Task{
            await deviceCommunicator.register(bleServices: [batteryService])
        }        
    }
    
    private func setupBatteryLevelSub() {
        batteryService.batteryLevelPublisher
            .compactMap { $0 }
            .sink { self.currentBatteryLevel = Double($0) / 100.0 }
            .store(in: &subs)
    }
}
