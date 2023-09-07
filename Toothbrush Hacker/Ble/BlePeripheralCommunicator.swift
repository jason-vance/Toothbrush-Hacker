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
    private func servicesCharacteristicDict(_ serviceUuid: CBUUID) -> [CBUUID:CBCharacteristic] {
        var dict: [CBUUID:CBCharacteristic] = [:]
        peripheralsServiceDict[serviceUuid]?.characteristics?.forEach { characteristic in
            dict[characteristic.uuid] = characteristic
        }
        return dict
    }

    private var discoverServiceContinuation: (serviceUuid: CBUUID, continuation: CheckedContinuation<CBService,Error>)? = nil
    private var discoverCharacteristicContinuation: (characteristicUuid: CBUUID, continuation: CheckedContinuation<CBCharacteristic,Error>)? = nil
    private var discoverDescriptorsContinuation: (characteristicUuid: CBUUID, continuation: CheckedContinuation<[CBDescriptor],Error>)? = nil
    private var notifyValueContinuation: (characteristicUuid: CBUUID, continuation: CheckedContinuation<Void,Error>)? = nil
    private var readValueContinuation: (attributeUuid: CBUUID, continuation: CheckedContinuation<[UInt8],Error>)? = nil
    
    private var notificationListeners: [CBCharacteristic:Set<HashableListener>] = [:]

    private init(connection: BlePeripheralConnection) {
        self.connection = connection
        super.init()
    }
    
    private func discoverService(_ serviceUuid: CBUUID) async throws -> CBService {
        if let knownService = peripheralsServiceDict[serviceUuid] {
            print("\(serviceUuid) service has already been discovered")
            return knownService
        }
        
        return try await withCheckedThrowingContinuation {
            discoverServiceContinuation = (serviceUuid, $0)
            print("Discovering \(serviceUuid) service")
            peripheral.discoverServices([serviceUuid])
        }
    }
    
    private func didDiscoverServices(error: Error?) {
        guard let discoverServiceContinuation = discoverServiceContinuation else { return }
        let serviceUuid = discoverServiceContinuation.serviceUuid
        let continuation = discoverServiceContinuation.continuation
        
        if let service = peripheralsServiceDict[serviceUuid] {
            print("\(serviceUuid) service was successfully discovered")
            continuation.resume(returning: service)
        } else {
            print("\(serviceUuid) service was not discovered")
            continuation.resume(throwing: error ?? "Unkown error in didDiscoverServices")
        }
    }
    
    private func discoverCharacteric(
        _ characteristicUuid: CBUUID,
        inService serviceUuid: CBUUID
    ) async throws -> CBCharacteristic {
        if let knownCharacteristic = servicesCharacteristicDict(serviceUuid)[characteristicUuid] {
            print("\(characteristicUuid) characteristic has already been discovered")
            return knownCharacteristic
        }
        
        let service = try await discoverService(serviceUuid)
        return try await withCheckedThrowingContinuation {
            discoverCharacteristicContinuation = (characteristicUuid, $0)
            print("Discovering \(characteristicUuid) characteristic")
            peripheral.discoverCharacteristics([characteristicUuid], for: service)
        }
    }
    
    private func didDiscoverCharacteristics(for service: CBService, error: Error?) {
        guard let discoverCharacteristicContinuation = discoverCharacteristicContinuation else { return }
        let characteristicUuid = discoverCharacteristicContinuation.characteristicUuid
        let continuation = discoverCharacteristicContinuation.continuation
        
        if let characteristic = servicesCharacteristicDict(service.uuid)[characteristicUuid] {
            print("\(characteristicUuid) characteristic was successfully discovered")
            continuation.resume(returning: characteristic)
        } else {
            print("\(characteristicUuid) characteristic was not discovered")
            continuation.resume(throwing: error ?? "Unkown error in didDiscoverCharacteristicsFor")
        }
    }
    
    private func discoverDescriptors(
        forCharacteristic characteristicUuid: CBUUID,
        inService serviceUuid: CBUUID
    ) async throws -> [CBDescriptor] {
        if let knownDescriptors = servicesCharacteristicDict(serviceUuid)[characteristicUuid]?.descriptors {
            print("\(characteristicUuid)'s descriptors have already been discovered")
            return knownDescriptors
        }
        
        let characteristic = try await discoverCharacteric(characteristicUuid, inService: serviceUuid)
        return try await withCheckedThrowingContinuation {
            discoverDescriptorsContinuation = (characteristicUuid, $0)
            print("Discovering \(characteristicUuid)'s descriptors")
            peripheral.discoverDescriptors(for: characteristic)
        }
    }
    
    private func didDiscoverDescriptors(for characteristic: CBCharacteristic, error: Error?) {
        guard let discoverDescriptorsContinuation = discoverDescriptorsContinuation else { return }
        let characteristicUuid = discoverDescriptorsContinuation.characteristicUuid
        let continuation = discoverDescriptorsContinuation.continuation
        
        if let descriptors = characteristic.descriptors {
            print("\(characteristicUuid)'s descriptors were successfully discovered")
            continuation.resume(returning: descriptors)
        } else {
            print("\(characteristicUuid)'s descriptors were not discovered")
            continuation.resume(throwing: error ?? "Unkown error in didDiscoverDescriptorsFor")
        }
    }
    
    public func enableNotifications(
        forCharacteristic characteristicUuid: CBUUID,
        inService serviceUuid: CBUUID,
        onUpdate: @escaping ([UInt8]) -> Void
    ) async throws -> NotificationsRegistration {
        let characteristic = try await discoverCharacteric(characteristicUuid, inService: serviceUuid)
        guard !characteristic.isNotifying else {
            print("\(characteristicUuid) is already notifying")
            return add(listener: onUpdate, for: characteristic)
        }
        
        let charProps = characteristic.properties
        guard charProps.contains(.notify) || charProps.contains(.indicate) else {
            throw "\(characteristicUuid) cannot notify or indicate"
        }

        try await withCheckedThrowingContinuation {
            notifyValueContinuation = (characteristicUuid, $0)
            print("Enabling notifications for \(characteristicUuid)")
            peripheral.setNotifyValue(true, for: characteristic)
        }
        
        return add(listener: onUpdate, for: characteristic)
    }
    
    public func disableNotifications(forCharacteristic characteristic: CBCharacteristic) async throws {
        let charProps = characteristic.properties
        guard charProps.contains(.notify) || charProps.contains(.indicate) else {
            print("Attempted to disable notifications for \(characteristic.uuid) which can't notify/indicate")
            return
        }

        try await withCheckedThrowingContinuation {
            notifyValueContinuation = (characteristic.uuid, $0)
            print("Disabling notifications for \(characteristic.uuid)")
            peripheral.setNotifyValue(false, for: characteristic)
        }
    }
    
    private func add(listener: @escaping ([UInt8]) -> Void, for characteristic: CBCharacteristic) -> BleNotificationsRegistration {
        let listener = HashableListener(listener: listener)
        
        if notificationListeners[characteristic] == nil {
            notificationListeners[characteristic] = []
        }
        notificationListeners[characteristic]?.insert(listener)
        
        return BleNotificationsRegistration {
            Task {
                try? await self.remove(listener: listener, for: characteristic)
            }
        }
    }
    
    private func remove(listener: HashableListener, for characteristic: CBCharacteristic) async throws {
        notificationListeners[characteristic]?.remove(listener)
        if notificationListeners[characteristic]?.isEmpty == true {
            print("Disabling notifications for \(characteristic.uuid) because all listeners removed")
            try await disableNotifications(forCharacteristic: characteristic)
        }
    }
    
    private func didUpdateNotificationState(for characteristic: CBCharacteristic, error: Error?) {
        guard let notifyValueContinuation = notifyValueContinuation else { return }
        let characteristicUuid = notifyValueContinuation.characteristicUuid
        let continuation = notifyValueContinuation.continuation
        
        if characteristicUuid == characteristic.uuid {
            print("Notification state for \(characteristicUuid) was updated succesfully")
            continuation.resume()
        } else {
            print("Notification state for \(characteristicUuid) failed to update")
            continuation.resume(throwing: error ?? "Unknown error in didUpdateNotificationStateFor characteristic")
        }
    }
    
    private func updateCharacteristicValueListeners(_ characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value else {
            return
        }
        let dataBytes = [UInt8](data)
        
        print("\(characteristic.uuid) characteristic updated value: \(dataBytes.toString())")
        for listener in notificationListeners[characteristic] ?? [] {
            listener.listener(dataBytes)
        }
    }

    public func readCharacteristicValue<ValueType>(
        _ characteristicUuid: CBUUID,
        inService serviceUuid: CBUUID,
        as valueType: ValueType.Type = [UInt8].self
    ) async throws -> ValueType {
        let characteristic = try await discoverCharacteric(characteristicUuid, inService: serviceUuid)
        guard characteristic.properties.contains(.read) else {
            throw "\(characteristicUuid) characteristic is not readable"
        }
        
        let valueBytes = try await withCheckedThrowingContinuation {
            readValueContinuation = (characteristicUuid, $0)
            print("Reading value of \(characteristicUuid) characteristic")
            peripheral.readValue(for: characteristic)
        }
        
        guard let rv = format(valueBytes, as: valueType) else {
            throw "Bytes \(valueBytes.toString()) could not be formatted as \(valueType)"
        }
        
        return rv
    }
    
    private func updateReadValueContinuation(_ characteristic: CBCharacteristic, error: Error?) {
        guard let readValueContinuation = readValueContinuation else { return }
        let characteristicUuid = readValueContinuation.attributeUuid
        let continuation = readValueContinuation.continuation
        
        guard characteristicUuid == characteristic.uuid else { return }
        
        if let data = characteristic.value {
            print("\(characteristicUuid) characteristic's value was successfully read")
            continuation.resume(returning: [UInt8](data))
        } else {
            print("\(characteristicUuid) characteristic's value was not successfully read")
            continuation.resume(throwing: error ?? "Unknown error in didUpdateValueFor characteristic")
        }
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

        print("BlePeripheralCommunicator.format(valueBytes: [UInt8]) can't handle type: \(valueType)")
        return nil
    }
    
    private func readDescriptorValue(
        _ descriptorUuid: CBUUID,
        forCharacteristic characteristicUuid: CBUUID,
        inService serviceUuid: CBUUID
    ) async throws -> [UInt8] {
        let descriptors = try await discoverDescriptors(forCharacteristic: characteristicUuid, inService: serviceUuid)
        guard let descriptor = (descriptors.first { $0.uuid == descriptorUuid }) else {
            throw "\(descriptorUuid) descriptor was not found in \(characteristicUuid) characteristic"
        }
        
        return try await withCheckedThrowingContinuation {
            readValueContinuation = (descriptorUuid, $0)
            peripheral.readValue(for: descriptor)
        }
    }
    
    private func didUpdateValue(for descriptor: CBDescriptor, error: Error?) {
        guard let readValueContinuation = readValueContinuation else { return }
        let descriptorUuid = readValueContinuation.attributeUuid
        let continuation = readValueContinuation.continuation
        
        let data = descriptor.value as? Data
        
        if descriptorUuid == descriptor.uuid {
            if let data = data {
                print("\(descriptorUuid) descriptor's value was successfully updated")
                continuation.resume(returning: [UInt8](data))
            } else {
                print("\(descriptorUuid) descriptor's value was not updated")
                continuation.resume(throwing: error ?? "Unknown error in didUpdateValueFor descriptor")
            }
        } else {
            let dataBytes = data == nil ? nil : [UInt8](data!)
            print("Unexpected update for \(descriptor.uuid) descriptor's value: \(dataBytes?.toString() ?? "nil")")
        }
    }
}

extension BlePeripheralCommunicator: CBPeripheralDelegate {
    
    nonisolated public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        Task {
            await didDiscoverServices(error: error)
        }
    }
 
    nonisolated public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        Task {
            await didDiscoverCharacteristics(for: service, error: error)
        }
    }
    
    nonisolated public func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        Task {
            await didDiscoverDescriptors(for: characteristic, error: error)
        }
    }
    
    nonisolated public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        Task {
            await didUpdateNotificationState(for: characteristic, error: error)
        }
    }
    
    nonisolated public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        Task {
            await updateReadValueContinuation(characteristic, error: error)
            await updateCharacteristicValueListeners(characteristic, error: error)
        }
    }
    
    nonisolated public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        Task {
            await didUpdateValue(for: descriptor, error: error)
        }
    }
}

