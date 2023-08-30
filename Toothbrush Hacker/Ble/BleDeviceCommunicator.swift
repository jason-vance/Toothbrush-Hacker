//
//  BleDeviceCommunicator.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/28/23.
//

import Foundation
import CoreBluetooth

//TODO: I should probably get this object from the connection (ie. connection.getCommunicator())
//TODO: These should probably be unique to the peripheral like BleDeviceConnection is
class BleDeviceCommunicator: NSObject {
    
    private let connection: BleDeviceConnection
    private var peripheral: CBPeripheral { connection.peripheral }
    private var services: [CBUUID:BleService] = [:]
    
    init(connection: BleDeviceConnection, services: [BleService]) {
        self.connection = connection
        super.init()
        
        peripheral.delegate = self
        add(services: services)
    }
    
    func add(services: [BleService]) {
        let existingServiceSet = Set(self.services.values.map { $0 as BleService })
        let newServices = Set(services).subtracting(existingServiceSet)
        guard !newServices.isEmpty else { return }
        
        newServices.forEach { self.services[$0.uuid] = $0 }
        let serviceUuids = newServices.map { $0.uuid }
        peripheral.discoverServices(serviceUuids)
    }
    
    func discoverCharacteristics(for service: BleService) {
        guard let cbService = service.service else { return }
        let characteristicUuids = service.characteristics.keys.map { $0 as CBUUID }
        peripheral.discoverCharacteristics(characteristicUuids, for: cbService)
    }
    
    func discoverDescriptors(for characteristic: BleCharacteristic) {
        guard let cbCharacteristic = characteristic.characteristic else { return }
        peripheral.discoverDescriptors(for: cbCharacteristic)
    }
    
    func readValue(for descriptor: BleDescriptor) {
        peripheral.readValue(for: descriptor.descriptor)
    }
    
    func readValue(for characteristic: BleCharacteristic) {
        guard let cbCharacteristic = characteristic.characteristic else { return }
        peripheral.readValue(for: cbCharacteristic)
    }
}

extension BleDeviceCommunicator: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            //TODO: Surface this error
            print("Error in didDiscoverServices: \(error.localizedDescription)")
            return
        }
        
        for cbService in peripheral.services ?? [] {
            if let service = services[cbService.uuid] {
                service.communicator(self, discovered: cbService)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor cbService: CBService, error: Error?) {
        if let error = error {
            //TODO: Surface this error
            print("Error in didDiscoverCharacteristicsFor service: \(error.localizedDescription)")
            return
        }
        
        let serviceUuid = cbService.uuid
        
        for cbCharacteristic in cbService.characteristics ?? [] {
            if let characteristic = services[serviceUuid]?.characteristics[cbCharacteristic.uuid] {
                characteristic.communicator(self, discovered: cbCharacteristic)
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
        
        if let characteristic = services[serviceUuid]?.characteristics[characteristicUuid] {
            for cbDescriptor in cbCharacteristic.descriptors ?? [] {
                characteristic.communicator(self, discovered: cbDescriptor, for: cbCharacteristic)
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
        
        if let descriptor = services[serviceUuid]?.characteristics[characteristicUuid]?.descriptors[descriptorUuid] {
            descriptor.communicator(self, receivedValueUpdateFor: cbDescriptor)
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
        
        if let characteristic = services[serviceUuid]?.characteristics[characteristicUuid] {
            characteristic.communicator(self, receivedValueUpdateFor: cbCharacteristic)
        }
    }
}
