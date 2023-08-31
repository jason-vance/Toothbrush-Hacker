//
//  BlePeripheralCommunicator.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/28/23.
//

import Foundation
import CoreBluetooth

class BlePeripheralCommunicator: NSObject {
    
    private static var communicators: [CBPeripheral:BlePeripheralCommunicator] = [:]
    
    static func getOrCreate(from peripheral: CBPeripheral) -> BlePeripheralCommunicator {
        if !communicators.keys.contains(peripheral) {
            let communicator = BlePeripheralCommunicator(
                connection: BlePeripheralConnection.getOrCreate(from: peripheral)
            )
            communicators[peripheral] = communicator
        }
        
        return communicators[peripheral]!
    }
    
    private let connection: BlePeripheralConnection
    private var peripheral: CBPeripheral { connection.peripheral }
    private var bleServices: [CBUUID:BleService] = [:]
    
    private init(connection: BlePeripheralConnection) {
        self.connection = connection
        super.init()
        
        peripheral.delegate = self
    }
    
    func add(bleServices: [BleService]) {
        let existingServiceSet = Set(self.bleServices.values.map { $0 as BleService })
        let newServices = Set(bleServices).subtracting(existingServiceSet)
        guard !newServices.isEmpty else { return }
        
        newServices.forEach { self.bleServices[$0.uuid] = $0 }
        let serviceUuids = newServices.map { $0.uuid }
        peripheral.discoverServices(serviceUuids)
    }
    
    func discoverCharacteristics(for bleServices: BleService) {
        guard let cbService = bleServices.cbService else { return }
        let characteristicUuids = bleServices.bleCharacteristics.keys.map { $0 as CBUUID }
        peripheral.discoverCharacteristics(characteristicUuids, for: cbService)
    }
    
    func discoverDescriptors(for bleCharacteristic: BleCharacteristicProtocol) {
        guard let cbCharacteristic = bleCharacteristic.cbCharacteristic else { return }
        peripheral.discoverDescriptors(for: cbCharacteristic)
    }
    
    func readValue(for bleDescriptor: BleDescriptor) {
        peripheral.readValue(for: bleDescriptor.cbDescriptor)
    }
    
    func readValue(for bleCharacteristic: BleCharacteristicProtocol) {
        guard bleCharacteristic.canRead else {
            print("Attempted to readValue(for: \(bleCharacteristic.uuid)), but it's properties do not include .read")
            return
        }
        guard let cbCharacteristic = bleCharacteristic.cbCharacteristic else { return }
        peripheral.readValue(for: cbCharacteristic)
    }
    
    func startNotifications(for bleCharacteristic: BleCharacteristicProtocol) {
        guard bleCharacteristic.canNotify else {
            print("Attempted to setNotifyValue(true, for: \(bleCharacteristic.uuid)), but it's properties do not include .notify")
            return
        }
        guard let cbCharacteristic = bleCharacteristic.cbCharacteristic else { return }
        peripheral.setNotifyValue(true, for: cbCharacteristic)
    }
}

extension BlePeripheralCommunicator: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            //TODO: Surface this error
            print("Error in didDiscoverServices: \(error.localizedDescription)")
            return
        }
        
        for cbService in peripheral.services ?? [] {
            if let bleService = bleServices[cbService.uuid] {
                bleService.communicator(self, discovered: cbService)
            } else {
                print("didDiscoverService: \(cbService) uuid: \(cbService.uuid.uuidString)")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor cbService: CBService, error: Error?) {
        if let error = error {
            //TODO: Surface this error
            print("Error in didDiscoverCharacteristicsFor service: \(error.localizedDescription)")
            return
        }
        
        guard let bleService = bleServices[cbService.uuid] else { return }
        let serviceUuid = cbService.uuid
        
        for cbCharacteristic in cbService.characteristics ?? [] {
            if let characteristic = bleServices[serviceUuid]?.bleCharacteristics[cbCharacteristic.uuid] {
                characteristic.communicator(self, discovered: cbCharacteristic, for: bleService)
            } else {
                print("didDiscoverCharacteristic: \(cbCharacteristic) uuid: \(cbCharacteristic.uuid.uuidString)")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor cbCharacteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            //TODO: Surface this error
            print("Error in didDiscoverDescriptorsFor characteristic: \(error.localizedDescription)")
            return
        }
        
        guard let serviceUuid = cbCharacteristic.service?.uuid else { return }
        let characteristicUuid = cbCharacteristic.uuid
        
        if let characteristic = bleServices[serviceUuid]?.bleCharacteristics[characteristicUuid] {
            for cbDescriptor in cbCharacteristic.descriptors ?? [] {
                characteristic.communicator(self, discovered: cbDescriptor, for: cbCharacteristic)
            }
        } else {
            for d in cbCharacteristic.descriptors ?? [] {
                print("didDiscoverDescriptor: \(d) forCharacteristic: \(cbCharacteristic.uuid)")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor cbDescriptor: CBDescriptor, error: Error?) {
        if let error = error {
            //TODO: Surface this error
            print("Error in didUpdateValueFor descriptor: \(error.localizedDescription)")
            return
        }
        
        guard let serviceUuid = cbDescriptor.characteristic?.service?.uuid else { return }
        guard let characteristicUuid = cbDescriptor.characteristic?.uuid else { return }
        let descriptorUuid = cbDescriptor.uuid
        
        if let bleDescriptor = bleServices[serviceUuid]?.bleCharacteristics[characteristicUuid]?.bleDescriptors[descriptorUuid] {
            bleDescriptor.communicator(self, receivedValueUpdateFor: cbDescriptor)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor cbCharacteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            //TODO: Surface this error
            print("Error in didUpdateValueFor characteristics: \(error.localizedDescription)")
            return
        }
        
        guard let serviceUuid = cbCharacteristic.service?.uuid else { return }
        let characteristicUuid = cbCharacteristic.uuid
        
        if let characteristic = bleServices[serviceUuid]?.bleCharacteristics[characteristicUuid] {
            characteristic.communicator(self, receivedValueUpdateFor: cbCharacteristic)
        }
    }
}
