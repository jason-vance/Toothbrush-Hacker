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
    func fetchCurrentBatteryLevel()
}

class BlePeripheralBatteryMonitor: BatteryMonitor {
    
    @Published var currentBatteryLevel: Double? = nil
    var batteryLevelPublisher: Published<Double?>.Publisher { $currentBatteryLevel }

    let deviceCommunicator: BlePeripheralCommunicator
    
    var subs: Set<AnyCancellable> = []
    
    init(device: CBPeripheral) {
        deviceCommunicator = BlePeripheralCommunicator.getOrCreate(from: device)
    }

    func fetchCurrentBatteryLevel() {
        Task{
            do {
                let bytes = try await deviceCommunicator.readCharacteristicValue(
                    BatteryLevelCharacteristic.uuid,
                    inService: BatteryService.uuid
                )
                if let batteryLevelInt = bytes.getValue(Int.self) {
                    currentBatteryLevel = Double(batteryLevelInt) / 100.0
                } else {
                    print("Something went wrong parsing those bytes")
                }
            } catch {
                print("Error in readCurrentBatteryLevel: \(error.localizedDescription)")
            }
        }
    }
}
