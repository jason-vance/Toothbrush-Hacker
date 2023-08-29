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
        
        setupSubscribers()
        
        deviceCommunicator.discover(services: [BatteryService.uuid])
    }
    
    func setupSubscribers() {
        deviceCommunicator.$discoveredService
            .filter { $0?.uuid == BatteryService.uuid }
            .compactMap { $0 }
            .sink(receiveValue: onDiscovered(batteryService:))
            .store(in: &subs)
        deviceCommunicator.$discoveredCharacteristic
            .filter { $0?.uuid == BatteryLevelCharacteristic.uuid }
            .compactMap { $0 }
            .sink(receiveValue: onDiscovered(batteryLevelCharacteristic:))
            .store(in: &subs)
        deviceCommunicator.$discoveredDescriptor
            .filter { $0?.uuid == CharacteristicPresentationFormatDescriptor.uuid }
            .compactMap { $0 }
            .sink(receiveValue: onDiscovered(presentationFormatDescriptor:))
            .store(in: &subs)
        deviceCommunicator.$updatedValueCharacteristic
            .filter { $0?.uuid == BatteryLevelCharacteristic.uuid }
            .compactMap { $0 }
            .sink(receiveValue: onUpdateValueOf(batteryLevelCharacteristic:))
            .store(in: &subs)
    }
    
    private func onDiscovered(batteryService: CBService) {
        deviceCommunicator.discover(characteristics: [BatteryLevelCharacteristic.uuid], for: batteryService)
    }
    
    private func onDiscovered(batteryLevelCharacteristic: CBCharacteristic) {
//        deviceCommunicator.discoverDescriptors(for: batteryLevelCharateristic)
        deviceCommunicator.readValue(for: batteryLevelCharacteristic)
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
