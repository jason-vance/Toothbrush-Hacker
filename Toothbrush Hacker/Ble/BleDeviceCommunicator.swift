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
    
    @Published var discoveredService: CBService? = nil
    @Published var discoveredCharacteristic: CBCharacteristic? = nil
    @Published var discoveredDescriptor: CBDescriptor? = nil
    @Published var updatedValueCharacteristic: CBCharacteristic? = nil

    private let connection: BleDeviceConnection
    private var peripheral: CBPeripheral { connection.peripheral }
    
    init(connection: BleDeviceConnection) {
        self.connection = connection
        super.init()
        peripheral.delegate = self
    }
    
    func discover(services: [CBUUID]? = nil) {
        peripheral.discoverServices(services)
    }
    
    func discover(characteristics: [CBUUID]? = nil, for service: CBService) {
        peripheral.discoverCharacteristics(characteristics, for: service)
    }
    
    func discoverDescriptors(for characteristic: CBCharacteristic) {
        peripheral.discoverDescriptors(for: characteristic)
    }
    
    func readValue(for characteristic: CBCharacteristic) {
        peripheral.readValue(for: characteristic)
    }
}

extension BleDeviceCommunicator: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        //TODO: Surface this error
        if let error = error {
            print("Error in didDiscoverServices: \(error.localizedDescription)")
            return
        }
        
        guard let services = peripheral.services else { return }
        
        for service in services {
            discoveredService = service
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        //TODO: Surface this error
        if let error = error {
            print("Error in didDiscoverCharacteristicsFor service: \(error.localizedDescription)")
            return
        }
        
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            discoveredCharacteristic = characteristic
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        //TODO: Surface this error
        if let error = error {
            print("Error in didDiscoverDescriptorsFor characteristic: \(error.localizedDescription)")
            return
        }
        
        guard let descriptors = characteristic.descriptors else { return }
        
        for descriptor in descriptors {
            discoveredDescriptor = descriptor
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        //TODO: Surface this error
        if let error = error {
            print("Error in didUpdateValueFor characteristics: \(error.localizedDescription)")
            return
        }
        
        updatedValueCharacteristic = characteristic
        guard let characteristicData = characteristic.value else { return }
        let byteArray = [UInt8](characteristicData)
        print("Received \(characteristicData.count) bytes: \(byteArray)")
    }
}
