//
//  BlePeripheralCommunicator.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 9/4/23.
//

import Foundation
import CoreBluetooth

public actor BlePeripheralCommunicator: NSObject {
    
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
    private var peripheral: CBPeripheral {
        connection.peripheral.delegate = self
        return connection.peripheral
    }
    private var peripheralsServiceDict: [CBUUID:CBService] {
        var dict: [CBUUID:CBService] = [:]
        peripheral.services?.forEach { service in
            dict[service.uuid] = service
        }
        return dict
    }

    private var discoverServiceContinuation: CheckedContinuation<CBService,Error>? = nil
    private var discoverServiceUuid: CBUUID? = nil
    private var discoverCharacteristicContinuation: CheckedContinuation<CBCharacteristic,Error>? = nil
    private var discoverCharacteristicUuid: CBUUID? = nil
    private var discoverDescriptorsContinuation: CheckedContinuation<[CBDescriptor],Error>? = nil
    private var discoverDescriptorsUuid: CBUUID? = nil
    private var readValueContinuation: CheckedContinuation<[UInt8],Error>? = nil
    private var readValueUuid: CBUUID? = nil

    private init(connection: BlePeripheralConnection) {
        self.connection = connection
        super.init()
    }
    
    private func discoverService(_ serviceUuid: CBUUID) async throws -> CBService {
        defer {
            discoverServiceContinuation = nil
            discoverServiceUuid = nil
        }
        
        guard discoverServiceUuid == nil else {
            throw "Service discovery is already in progress"
        }
        discoverServiceUuid = serviceUuid

        return try await withCheckedThrowingContinuation {
            discoverServiceContinuation = $0

            if let knownService = (peripheral.services?.first { $0.uuid == serviceUuid }) {
                print("Service \"\(serviceUuid)\" has already been discovered")
                discoverServiceContinuation?.resume(returning: knownService)
            } else {
                print("Discovering service \"\(serviceUuid)\"")
                peripheral.discoverServices([serviceUuid])
            }
        }
    }
    
    private func discoverCharacteric(
        _ characteristicUuid: CBUUID,
        inService serviceUuid: CBUUID
    ) async throws -> CBCharacteristic {
        defer {
            discoverCharacteristicContinuation = nil
            discoverCharacteristicUuid = nil
        }
        
        guard discoverCharacteristicUuid == nil else {
            throw "Characteric discovery is already in progress"
        }
        discoverCharacteristicUuid = characteristicUuid
        
        let service = try await discoverService(serviceUuid)
        return try await withCheckedThrowingContinuation {
            discoverCharacteristicContinuation = $0
            
            if let knownCharacteristic = (service.characteristics?.first { $0.uuid == characteristicUuid }) {
                print("Characteristic \"\(characteristicUuid)\" has already been discovered")
                discoverCharacteristicContinuation?.resume(returning: knownCharacteristic)
            } else {
                print("Discovering characteristic \"\(characteristicUuid)\" for \"\(serviceUuid)\"")
                peripheral.discoverCharacteristics([characteristicUuid], for: service)
            }
        }
    }
    
    private func discoverDescriptors(
        forCharacteristic characteristicUuid: CBUUID,
        inService serviceUuid: CBUUID
    ) async throws -> [CBDescriptor] {
        defer {
            discoverDescriptorsContinuation = nil
            discoverDescriptorsUuid = nil
        }
        
        guard discoverDescriptorsUuid == nil else {
            throw "Descriptor discovery is already in progress"
        }
        discoverDescriptorsUuid = characteristicUuid
        
        let characteristic = try await discoverCharacteric(characteristicUuid, inService: serviceUuid)
        return try await withCheckedThrowingContinuation {
            discoverDescriptorsContinuation = $0
            
            if let descriptors = characteristic.descriptors {
                print("Descriptors for \"\(characteristicUuid)\" have already been discovered")
                discoverDescriptorsContinuation?.resume(returning: descriptors)
            } else {
                print("Discovering descriptors for \"\(characteristicUuid)\"")
                peripheral.discoverDescriptors(for: characteristic)
            }
        }
    }
    
    public func readCharacteristicValue(
        _ characteristicUuid: CBUUID,
        inService serviceUuid: CBUUID
    ) async throws -> [UInt8] {
        defer {
            readValueContinuation = nil
            readValueUuid = nil
        }
        
        guard readValueUuid == nil else {
            throw "Value read is already in progress"
        }
        readValueUuid = characteristicUuid
        
        let characteristic = try await discoverCharacteric(characteristicUuid, inService: serviceUuid)
        //TODO: Check properties contains `read`
        return try await withCheckedThrowingContinuation {
            readValueContinuation = $0
            print("Reading value of \"\(characteristicUuid)\"")
            peripheral.readValue(for: characteristic)
        }
    }
    
    private func readDescriptorValue(
        _ descriptorUuid: CBUUID,
        forCharacteristic characteristicUuid: CBUUID,
        inService serviceUuid: CBUUID
    ) async throws -> [UInt8] {
        defer {
            readValueContinuation = nil
            readValueUuid = nil
        }
        
        guard readValueUuid == nil else {
            throw "Value read is already in progress"
        }
        readValueUuid = descriptorUuid

        let descriptors = try await discoverDescriptors(forCharacteristic: characteristicUuid, inService: serviceUuid)
        guard let descriptor = (descriptors.first { $0.uuid == descriptorUuid }) else {
            throw "Descriptor \"\(descriptorUuid)\" was not found among the descriptors of \"\(characteristicUuid)\""
        }
        return try await withCheckedThrowingContinuation {
            readValueContinuation = $0
            peripheral.readValue(for: descriptor)
        }
    }
    
    //TODO: Add notifying values
    //TODO: Explore writing values w/wo response
}

extension BlePeripheralCommunicator: CBPeripheralDelegate {
    
    nonisolated public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        Task {
            guard let serviceUuid = await discoverServiceUuid else { return }
            if let service = (peripheral.services?.first { $0.uuid == serviceUuid }) {
                print("Service \"\(serviceUuid)\" was successfully discovered")
                await discoverServiceContinuation?.resume(returning: service)
            } else {
                print("Service \"\(serviceUuid)\" was not discovered")
                await discoverServiceContinuation?.resume(throwing: error ?? "Unkown error in didDiscoverServices")
            }
        }
    }
    
    nonisolated public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        Task {
            guard let characteristicUuid = await discoverCharacteristicUuid else { return }
            if let characteristic = (service.characteristics?.first { $0.uuid == characteristicUuid }) {
                print("Characteristic \"\(characteristicUuid)\" was successfully discovered")
                await discoverCharacteristicContinuation?.resume(returning: characteristic)
            } else {
                print("Characteristic \"\(characteristicUuid)\" was not discovered")
                await discoverCharacteristicContinuation?.resume(throwing: error ?? "Unkown error in didDiscoverCharacteristicsFor")
            }
        }
    }
    
    nonisolated public func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        Task {
            guard let characteristicUuid = await discoverDescriptorsUuid else { return }
            if let descriptors = characteristic.descriptors {
                print("Descriptors for \"\(characteristicUuid)\" were successfully discovered")
                await discoverDescriptorsContinuation?.resume(returning: descriptors)
            } else {
                print("Descriptors for \"\(characteristicUuid)\" were not discovered")
                await discoverDescriptorsContinuation?.resume(throwing: error ?? "Unkown error in didDiscoverDescriptorsFor")
            }
        }
    }
    
    nonisolated public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        Task {
            let data = characteristic.value
            
            if let readValueUuid = await readValueUuid, readValueUuid == characteristic.uuid {
                if let data = data {
                    print("Characteristic value for \"\(readValueUuid)\" was successfully updated")
                    await readValueContinuation?.resume(returning: [UInt8](data))
                } else {
                    print("Characteristic value for \"\(readValueUuid)\" was not updated")
                    await readValueContinuation?.resume(throwing: error ?? "Unknown error in didUpdateValueFor characteristic")
                }
            } else {
                let dataBytes = data == nil ? nil : [UInt8](data!)
                print("Unexpected characteristic value update for \"\(characteristic.uuid)\" value: \(String(describing: dataBytes?.toString())))")
            }
        }
    }
    
    nonisolated public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        Task {
            let data = descriptor.value as? Data
            
            if let readValueUuid = await readValueUuid, readValueUuid == descriptor.uuid {
                if let data = data {
                    print("Descriptor value for \"\(readValueUuid)\" was successfully updated")
                    await readValueContinuation?.resume(returning: [UInt8](data))
                } else {
                    print("Descriptor value for \"\(readValueUuid)\" was not updated")
                    await readValueContinuation?.resume(throwing: error ?? "Unknown error in didUpdateValueFor descriptor")
                }
            } else {
                let dataBytes = data == nil ? nil : [UInt8](data!)
                print("Unexpected descriptor value update for \"\(descriptor.uuid)\" value: \(String(describing: dataBytes?.toString())))")
            }
        }
    }
}

