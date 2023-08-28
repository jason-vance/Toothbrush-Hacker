//
//  BleDeviceBatteryMonitor.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/27/23.
//

import Foundation
import Combine
import CoreBluetooth

protocol BleDeviceBatteryMonitor {
    
    var currentBatteryLevelPublisher: Published<Float>.Publisher { get }
}

class DefaultBleDeviceBatteryMonitor: BleDeviceBatteryMonitor {
    
    @Published var currentBatteryLevel: Float = 0
    var currentBatteryLevelPublisher: Published<Float>.Publisher { $currentBatteryLevel }

    let deviceManager: BleDeviceManager
    
    var subs: Set<AnyCancellable> = []
    
    init(deviceManager: BleDeviceManager) {
        self.deviceManager = deviceManager
        
        deviceManager.$connectedState
            .sink(receiveValue: onUpdate(connectedState:))
            .store(in: &subs)
        deviceManager.$discoveredService
            .filter { $0?.uuid == BatteryService.uuid }
            .compactMap { $0 }
            .sink(receiveValue: onDiscovered(batteryService:))
            .store(in: &subs)
        deviceManager.$discoveredCharacteristic
            .filter { $0?.uuid == BatteryLevelCharacteristic.uuid }
            .compactMap { $0 }
            .sink(receiveValue: onDiscovered(batteryLevelCharacteristic:))
            .store(in: &subs)
        deviceManager.$discoveredDescriptor
            .filter { $0?.uuid == CharacteristicPresentationFormatDescriptor.uuid }
            .compactMap { $0 }
            .sink(receiveValue: onDiscovered(presentationFormatDescriptor:))
            .store(in: &subs)
        deviceManager.$characteristicValueUpdate
            .filter { $0?.uuid == BatteryLevelCharacteristic.uuid }
            .compactMap { $0 }
            .sink(receiveValue: onUpdateValueOf(batteryLevelCharacteristic:))
            .store(in: &subs)
    }
    
    private func cleanUp() {
        //TODO: Do I actually need to do anything here?
    }
    
    private func onUpdate(connectedState: BleConnectedState) {
        switch connectedState {
        case .connected:
            onDeviceConnected()
        case .disconnected:
            cleanUp()
        }
    }
    
    private func onDeviceConnected() {
        guard let peripheral = deviceManager.connectedPeripheral else { return }
        deviceManager.discover(services: [BatteryService.uuid], on: peripheral)
    }
    
    private func onDiscovered(batteryService: CBService) {
        guard let peripheral = deviceManager.connectedPeripheral else { return }
        deviceManager.discover(characteristics: [BatteryLevelCharacteristic.uuid], for: batteryService, on: peripheral)
    }
    
    private func onDiscovered(batteryLevelCharacteristic: CBCharacteristic) {
        guard let peripheral = deviceManager.connectedPeripheral else { return }
//        deviceManager.discoverDescriptors(for: batteryLevelCharateristic, on: peripheral)
        deviceManager.readValue(for: batteryLevelCharacteristic, on: peripheral)
    }
    
    private func onDiscovered(presentationFormatDescriptor: CBDescriptor) {
        
    }
    
    private func onUpdateValueOf(batteryLevelCharacteristic: CBCharacteristic) {
        guard let batteryLevelData = batteryLevelCharacteristic.value else { return }
        let byteArray = [UInt8](batteryLevelData)
        let batteryLevel = byteArray[0]
        
        print("BleDeviceBatteryMonitor received batteryLevel: \(batteryLevel)")
    }
    
}
