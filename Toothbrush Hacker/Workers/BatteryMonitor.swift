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
    var isListeningPublisher: Published<Bool>.Publisher { get }
    func listenToBatteryLevel()
}

class BlePeripheralBatteryMonitor: BatteryMonitor {
    
    @Published var currentBatteryLevel: Double? = nil
    var batteryLevelPublisher: Published<Double?>.Publisher { $currentBatteryLevel }

    @Published var isListening: Bool = false
    var isListeningPublisher: Published<Bool>.Publisher { $isListening }

    let deviceCommunicator: BlePeripheralCommunicator
    var notificationsRegistration: NotificationsRegistration? = nil
    
    var subs: Set<AnyCancellable> = []
    
    init(device: CBPeripheral) {
        deviceCommunicator = BlePeripheralCommunicator.getOrCreate(from: device)
    }
    
    func listenToBatteryLevel() {
        guard notificationsRegistration == nil else {
            notificationsRegistration = nil
            isListening = false
            return
        }
        
        Task{
            do {
                notificationsRegistration = try await deviceCommunicator.enableNotifications(
                    forCharacteristic: BatteryLevelCharacteristic.uuid,
                    inService: BatteryService.uuid,
                    onUpdate: onBatterLevelUpdate(_:)
                )
                isListening = true
            } catch {
                print("Error in listenToBatteryLevel: \(error.localizedDescription)")
                isListening = false
            }
        }
    }
    
    private func onBatterLevelUpdate(_ valueBytes: [UInt8]) {
        guard let batteryLevelInt = valueBytes.getValue(Int.self) else {
            print("Failed to parse batteryLevelInt out of \(valueBytes.toString())")
            return
        }
        currentBatteryLevel = Double(batteryLevelInt) / 100.0
    }
}
