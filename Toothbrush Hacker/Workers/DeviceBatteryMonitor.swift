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
    
    var currentBatteryLevelPublisher: Published<Float>.Publisher { get }
}

class BleDeviceBatteryMonitor: DeviceBatteryMonitor {
    
    @Published var currentBatteryLevel: Float = 0
    var currentBatteryLevelPublisher: Published<Float>.Publisher { $currentBatteryLevel }

    let deviceCommunicator: BleDeviceCommunicator
    
    var subs: Set<AnyCancellable> = []
    
    init(deviceCommunicator: BleDeviceCommunicator) {
        self.deviceCommunicator = deviceCommunicator
        
        let batteryLevelCharacteristic = CBMutableCharacteristic(
            type: BatteryLevelCharacteristic.uuid,
            properties: .read,
            value: nil,
            permissions: .readable
        )
        deviceCommunicator.readValue(for: batteryLevelCharacteristic)

        
//        deviceCommunicator.$connectedState
//            .sink(receiveValue: onUpdate(connectedState:))
//            .store(in: &subs)
//        deviceCommunicator.$discoveredService
//            .filter { $0?.uuid == BatteryService.uuid }
//            .compactMap { $0 }
//            .sink(receiveValue: onDiscovered(batteryService:))
//            .store(in: &subs)
//        deviceCommunicator.$discoveredCharacteristic
//            .filter { $0?.uuid == BatteryLevelCharacteristic.uuid }
//            .compactMap { $0 }
//            .sink(receiveValue: onDiscovered(batteryLevelCharacteristic:))
//            .store(in: &subs)
//        deviceCommunicator.$discoveredDescriptor
//            .filter { $0?.uuid == CharacteristicPresentationFormatDescriptor.uuid }
//            .compactMap { $0 }
//            .sink(receiveValue: onDiscovered(presentationFormatDescriptor:))
//            .store(in: &subs)
//        deviceCommunicator.$characteristicValueUpdate
//            .filter { $0?.uuid == BatteryLevelCharacteristic.uuid }
//            .compactMap { $0 }
//            .sink(receiveValue: onUpdateValueOf(batteryLevelCharacteristic:))
//            .store(in: &subs)
    }
    
//    private func onUpdate(connectedState: ConnectedState) {
//        switch connectedState {
//        case .connected:
//            onDeviceConnected()
//        case .disconnected:
//            cleanUp()
//        }
//    }
//
//    private func onDeviceConnected() {
//        guard let peripheral = deviceManager.connectedPeripheral else { return }
//        deviceManager.discover(services: [BatteryService.uuid], on: peripheral)
//    }
//
//    private func onDiscovered(batteryService: CBService) {
//        guard let peripheral = deviceManager.connectedPeripheral else { return }
//        deviceManager.discover(characteristics: [BatteryLevelCharacteristic.uuid], for: batteryService, on: peripheral)
//    }
    
    private func onDiscovered(batteryLevelCharacteristic: CBCharacteristic) {
//        guard let peripheral = deviceManager.connectedPeripheral else { return }
////        deviceManager.discoverDescriptors(for: batteryLevelCharateristic, on: peripheral)
//        deviceManager.readValue(for: batteryLevelCharacteristic, on: peripheral)
    }
    
//    private func onDiscovered(presentationFormatDescriptor: CBDescriptor) {
//
//    }
    
    private func onUpdateValueOf(batteryLevelCharacteristic: CBCharacteristic) {
        guard let batteryLevelData = batteryLevelCharacteristic.value else { return }
        let byteArray = [UInt8](batteryLevelData)
        let batteryLevel = byteArray[0]
        
        print("BleDeviceBatteryMonitor received batteryLevel: \(batteryLevel)")
    }
    
}
