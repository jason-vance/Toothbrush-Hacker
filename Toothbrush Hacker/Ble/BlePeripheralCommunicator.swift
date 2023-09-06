//
//  BlePeripheralCommunicator.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 9/4/23.
//

import Foundation
import CoreBluetooth

//TODO: Explore writing values w/wo response
public actor BlePeripheralCommunicator: NSObject {
    
    private struct HashableListener: Hashable {
        let id = UUID()
        let listener: ([UInt8]) -> Void
        
        var hashValue: Int { id.hashValue }
        func hash(into hasher: inout Hasher) { id.hash(into: &hasher) }
        static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
    }
    
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
    private var notifyValueContinuation: CheckedContinuation<Void,Error>? = nil
    private var notifyValueUuid: CBUUID? = nil
    private var readValueContinuation: CheckedContinuation<[UInt8],Error>? = nil
    private var readValueUuid: CBUUID? = nil
    
    private var notificationListeners: [CBCharacteristic:Set<HashableListener>] = [:]

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
    
    public func enableNotifications(
        forCharacteristic characteristicUuid: CBUUID,
        inService serviceUuid: CBUUID,
        onUpdate: @escaping ([UInt8]) -> Void
    ) async throws -> NotificationsRegistration {
        defer {
            notifyValueContinuation = nil
            notifyValueUuid = nil
        }
        
        guard notifyValueUuid == nil else {
            throw "Notification enabling/disabling is already in progress"
        }
        notifyValueUuid = characteristicUuid
        
        let characteristic = try await discoverCharacteric(characteristicUuid, inService: serviceUuid)
        let charProps = characteristic.properties
        guard charProps.contains(.notify) || charProps.contains(.indicate) else {
            throw "Characteristic '\(characteristicUuid)' cannot notify or indicate"
        }

        let listener = HashableListener(listener: onUpdate)
        add(listener: listener, for: characteristic)
        
        try await withCheckedThrowingContinuation {
            notifyValueContinuation = $0
            print("Enabling notifications for \"\(characteristicUuid)\"")
            peripheral.setNotifyValue(true, for: characteristic)
        }
        
        return BleNotificationsRegistration {
            Task {
                try? await self.remove(listener: listener, for: characteristic)
            }
        }
    }
    
    public func disableNotifications(forCharacteristic characteristic: CBCharacteristic) async throws {
        defer {
            notifyValueContinuation = nil
            notifyValueUuid = nil
        }
        
        guard notifyValueUuid == nil else {
            throw "Notification enabling/disabling is already in progress"
        }
        notifyValueUuid = characteristic.uuid
        
        let charProps = characteristic.properties
        guard charProps.contains(.notify) || charProps.contains(.indicate) else {
            print("Attempted to disable notifications for characteristic '\(characteristic.uuid)' but it can't notify or indicate")
            return
        }

        try await withCheckedThrowingContinuation {
            notifyValueContinuation = $0
            print("Disabling notifications for \"\(characteristic.uuid)\"")
            peripheral.setNotifyValue(false, for: characteristic)
        }
    }
    
    private func add(listener: HashableListener, for characteristic: CBCharacteristic) {
        if notificationListeners[characteristic] == nil {
            notificationListeners[characteristic] = []
        }
        notificationListeners[characteristic]?.insert(listener)
    }
    
    private func remove(listener: HashableListener, for characteristic: CBCharacteristic) async throws {
        notificationListeners[characteristic]?.remove(listener)
        if notificationListeners[characteristic]?.isEmpty == true {
            print("Disabling notifications for characteristic '\(characteristic.uuid)' because all listeners removed")
            try await disableNotifications(forCharacteristic: characteristic)
        }
    }

    public func readCharacteristicValue<ValueType>(
        _ characteristicUuid: CBUUID,
        inService serviceUuid: CBUUID,
        as valueType: ValueType.Type = [UInt8].self
    ) async throws -> ValueType {
        //TODO: All of these defer blocks need to be re-thought, I'm nil'ing out the continuation
        defer {
            readValueContinuation = nil
            readValueUuid = nil
        }
        
        guard readValueUuid == nil else {
            throw "Value read is already in progress"
        }
        readValueUuid = characteristicUuid
        
        let characteristic = try await discoverCharacteric(characteristicUuid, inService: serviceUuid)
        guard characteristic.properties.contains(.read) else {
            throw "Characteristic '\(characteristicUuid)' is not readable"
        }
        
        let valueBytes = try await withCheckedThrowingContinuation {
            readValueContinuation = $0
            print("Reading value of \"\(characteristicUuid)\"")
            peripheral.readValue(for: characteristic)
        }
        
        guard let rv = format(valueBytes, as: valueType) else {
            throw "Bytes \(valueBytes.toString()) could not be formatted as \(String(describing: valueType))"
        }
        
        return rv
    }
    
    //TODO: Format this value using the format descriptor (maybe just the exponent)
    private func format<ValueType>(_ valueBytes: [UInt8], as valueType: ValueType.Type) -> ValueType? {
        if valueType == [UInt8].self {
            return valueBytes as? ValueType
        }
        
        if valueType == Bool.self {
            guard let value = valueBytes.getValue(UInt8.self, at: 0) else { return nil }
            return (value != 0) as? ValueType
        }
        
        if valueType == Int.self {
            return valueBytes.getValue(Int.self, at: 0) as? ValueType
        }
        
        if valueType == String.self {
            //TODO: Extend this to properly handle utf16 strings (prob should look at the format descriptor)
            if let value = String(bytes: valueBytes, encoding: .utf8) {
                return value as? ValueType
            }
            if let value = String(bytes: valueBytes, encoding: .utf16) {
                return value as? ValueType
            }
        }

        print("BlePeripheralCommunicator.format(valueBytes: [UInt8]) can't handle type: \(String(describing: valueType))")
        return nil
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
    
    nonisolated public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        Task {
            guard let notifyValueUuid = await notifyValueUuid else {
                print("Unexpected didUpdateNotificationStateFor '\(characteristic.uuid)' notifying: \(characteristic.isNotifying)")
                return
            }
            
            if notifyValueUuid == characteristic.uuid {
                print("Notification state for \"\(notifyValueUuid)\" was updated succesfully")
                await notifyValueContinuation?.resume()
            } else {
                print("Notification state for \"\(notifyValueUuid)\" failed to update")
                await notifyValueContinuation?.resume(throwing: error ?? "Unknown error in didUpdateNotificationStateFor characteristic")
            }
        }
    }
    
    nonisolated public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        Task {
            guard characteristic.value != nil else {
                print("Characteristic value was nil in didUpdateValueFor characteristic")
                return
            }
            
            await updateReadValueContinuation(characteristic, error: error)
            await updateCharacteristicValueListeners(characteristic, error: error)
        }
    }
    
    private func updateReadValueContinuation(_ characteristic: CBCharacteristic, error: Error?) {
        guard let readValueUuid = readValueUuid, readValueUuid == characteristic.uuid else {
            return
        }
        
        if let data = characteristic.value {
            print("Characteristic value for \"\(readValueUuid)\" was successfully updated")
            readValueContinuation?.resume(returning: [UInt8](data))
        } else {
            print("Characteristic value for \"\(readValueUuid)\" was not updated")
            readValueContinuation?.resume(throwing: error ?? "Unknown error in didUpdateValueFor characteristic")
        }
    }
    
    private func updateCharacteristicValueListeners(_ characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value else {
            return
        }
        let dataBytes = [UInt8](data)
        
        print("Value updated for \"\(characteristic.uuid)\" value: \(dataBytes.toString())")
        for listener in notificationListeners[characteristic] ?? [] {
            listener.listener(dataBytes)
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

