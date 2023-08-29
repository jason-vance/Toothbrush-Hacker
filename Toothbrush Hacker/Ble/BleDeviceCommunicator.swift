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
    //TODO: I should probably make this a map instead of a set
    private var services: Set<BleService> = []
    
    init(connection: BleDeviceConnection, services: Set<BleService>) {
        self.connection = connection
        super.init()
        
        peripheral.delegate = self
        add(services: services)
    }
    
    func add(services: Set<BleService>) {
        let newServices = services.subtracting(self.services)
        self.services = self.services.union(services)

        guard !newServices.isEmpty else { return }
        let serviceUuids = newServices.map { $0.uuid }
        peripheral.discoverServices(serviceUuids)
    }
    
    func discoverCharacteristics(for service: BleService) {
        guard let cbService = service.service else { return }
        let characteristicUuids = service.characteristics.map { $0.uuid }
        peripheral.discoverCharacteristics(characteristicUuids, for: cbService)
    }
    
    func discoverDescriptors(for characteristic: BleCharacteristic) {
        guard let cbCharacteristic = characteristic.characteristic else { return }
        peripheral.discoverDescriptors(for: cbCharacteristic)
    }
    
//    func readValue(for characteristic: CBCharacteristic) {
//        peripheral.readValue(for: characteristic)
//    }
}

extension BleDeviceCommunicator: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            //TODO: Surface this error
            print("Error in didDiscoverServices: \(error.localizedDescription)")
            return
        }
        
        guard let cbServices = peripheral.services else { return }
        for cbService in cbServices {
            if let service = (services.first { $0.uuid == cbService.uuid }) {
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

        guard let cbCharacteristics = cbService.characteristics else { return }
        for cbCharacteristic in cbCharacteristics {
            if let service = (services.first { $0.uuid == cbService.uuid }) {
                if let characteristic = (service.characteristics.first { $0.uuid == cbCharacteristic.uuid }) {
                    characteristic.communicator(self, discovered: cbCharacteristic)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor cbCharacteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            //TODO: Surface this error
            print("Error in didDiscoverDescriptorsFor characteristic: \(error.localizedDescription)")
            return
        }
        
        //TODO: Change this when services/characteristics are maps
        for service in services {
            guard service.uuid == cbCharacteristic.service?.uuid else { continue }
            for characteristic in service.characteristics {
                guard characteristic.uuid == cbCharacteristic.uuid else { continue }
                for cbDescriptor in cbCharacteristic.descriptors ?? [] {
                    characteristic.communicator(self, discovered: cbDescriptor, for: cbCharacteristic)
                }
            }
        }
    }
    
//    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//        if let error = error {
//            //TODO: Surface this error
//            print("Error in didUpdateValueFor characteristics: \(error.localizedDescription)")
//            return
//        }
//
//        updatedValueCharacteristic = characteristic
//        guard let characteristicData = characteristic.value else { return }
//        let byteArray = [UInt8](characteristicData)
//        print("Received \(characteristicData.count) bytes: \(byteArray)")
//    }
}
