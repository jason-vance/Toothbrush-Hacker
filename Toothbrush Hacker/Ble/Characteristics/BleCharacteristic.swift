//
//  BleCharacteristic.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/29/23.
//

import Foundation
import CoreBluetooth

protocol BleCharacteristicProtocol : AnyObject {
    var uuid: CBUUID { get }
    var bleService: BleService? { get }
    var bleDescriptors: [CBUUID:BleDescriptor] { get }
    var cbCharacteristic: CBCharacteristic? { get }
    
    var properties: CBCharacteristicProperties? { get }
    var valueBytes: [UInt8]? { get }
    
    var canRead: Bool { get }
    var canNotify: Bool { get }

    func communicator(_ communicator: BlePeripheralCommunicator, discovered cbCharacteristic: CBCharacteristic, for bleService: BleService)
    func communicator(_ communicator: BlePeripheralCommunicator, discovered cbDescriptor: CBDescriptor, for cbCharacteristic: CBCharacteristic)
    func communicator(_ communicator: BlePeripheralCommunicator, receivedValueUpdateFor cbCharacteristic: CBCharacteristic)
    
    func createDescriptor(with cbDescriptor: CBDescriptor) -> BleDescriptor?
}

class BleCharacteristic<ValueType>: BleCharacteristicProtocol {
    
    let uuid: CBUUID
    unowned private(set) var bleService: BleService? = nil
    private(set) var bleDescriptors: [CBUUID:BleDescriptor] = [:]
    private(set) var cbCharacteristic: CBCharacteristic? = nil
    let readValueOnDiscover: Bool
    let setToNotify: Bool
    
    private(set) var properties: CBCharacteristicProperties? = nil
    @Published private(set) var valueBytes: [UInt8]? = nil
    @Published private(set) var value: ValueType? = nil

    init(uuid: CBUUID, readValueOnDiscover: Bool = false, setToNotify: Bool = false) {
        self.uuid = uuid
        self.readValueOnDiscover = readValueOnDiscover
        self.setToNotify = setToNotify
    }
    
    final func communicator(_ communicator: BlePeripheralCommunicator, discovered cbCharacteristic: CBCharacteristic, for bleService: BleService) {
        guard self.cbCharacteristic == nil else {
            return
        }
        self.bleService = bleService
        self.cbCharacteristic = cbCharacteristic
        self.properties = cbCharacteristic.properties
        printPropString()
        
        communicator.discoverDescriptors(for: self)
        if readValueOnDiscover {
            communicator.readValue(for: self)
        }
        if setToNotify {
            communicator.startNotifications(for: self)
        }
    }
    
    final func communicator(_ communicator: BlePeripheralCommunicator, discovered cbDescriptor: CBDescriptor, for cbCharacteristic: CBCharacteristic) {
        guard let bleDescriptor = BleDescriptor.create(with: cbDescriptor, bleCharacteristic: self) else { return }
        
        bleDescriptors[bleDescriptor.uuid] = bleDescriptor
        communicator.readValue(for: bleDescriptor)
    }
    
    final func communicator(_ communicator: BlePeripheralCommunicator, receivedValueUpdateFor cbCharacteristic: CBCharacteristic) {
        guard let data = cbCharacteristic.value else { return }
        let valueBytes = [UInt8](data)
        
        self.valueBytes = valueBytes
        printValueBytes()
        if let value = format(valueBytes: valueBytes) {
            self.value = value
            printValue()
        } else {
            print("Could not format characteristic(\(cbCharacteristic.uuid)) value as \(String(describing: ValueType.self))")
        }
    }
    
    //TODO: Format this value using the format descriptor (maybe just the exponent)
    open func format(valueBytes: [UInt8]) -> ValueType? {
        if ValueType.self == Bool.self {
            if let value = valueBytes.getValue(UInt8.self, at: 0) {
                return (value != 0) as? ValueType
            }
        }
        
        if ValueType.self == Int.self {
            if let value = valueBytes.getValue(Int.self, at: 0) {
                return value as? ValueType
            }
        }
        
        if ValueType.self == String.self {
            //TODO: Extend this to properly handle utf16 strings (prob should look at the format descriptor)
            if let value = String(bytes: valueBytes, encoding: .utf8) {
                return value as? ValueType
            }
            if let value = String(bytes: valueBytes, encoding: .utf16) {
                return value as? ValueType
            }
        }

        print("Override `format(valueBytes: [UInt8])` to handle type: \(String(describing: ValueType.self))")
        return nil
    }
    
    open func createDescriptor(with: CBDescriptor) -> BleDescriptor? { nil }
    
    var canBroadcast: Bool {
        guard let properties = properties else { return false }
        let mask = UInt(CBCharacteristicProperties.broadcast.rawValue)
        return (UInt(properties.rawValue) & mask) != 0
    }
    
    var canRead: Bool {
        guard let properties = properties else { return false }
        let mask = UInt(CBCharacteristicProperties.read.rawValue)
        return (UInt(properties.rawValue) & mask) != 0
    }
    
    var canWriteWithoutResponse: Bool {
        guard let properties = properties else { return false }
        let mask = UInt(CBCharacteristicProperties.writeWithoutResponse.rawValue)
        return (UInt(properties.rawValue) & mask) != 0
    }
    
    var canWrite: Bool {
        guard let properties = properties else { return false }
        let mask = UInt(CBCharacteristicProperties.write.rawValue)
        return (UInt(properties.rawValue) & mask) != 0
    }
    
    var canNotify: Bool {
        guard let properties = properties else { return false }
        let mask = UInt(CBCharacteristicProperties.notify.rawValue)
        return (UInt(properties.rawValue) & mask) != 0
    }
    
    var canIndicate: Bool {
        guard let properties = properties else { return false }
        let mask = UInt(CBCharacteristicProperties.indicate.rawValue)
        return (UInt(properties.rawValue) & mask) != 0
    }
    
    var canSignedWrite: Bool {
        guard let properties = properties else { return false }
        let mask = UInt(CBCharacteristicProperties.authenticatedSignedWrites.rawValue)
        return (UInt(properties.rawValue) & mask) != 0
    }
    
    var hasExtendedProperties: Bool {
        guard let properties = properties else { return false }
        let mask = UInt(CBCharacteristicProperties.extendedProperties.rawValue)
        return (UInt(properties.rawValue) & mask) != 0
    }
    
    var requiresEncryptionToNotify: Bool {
        guard let properties = properties else { return false }
        let mask = UInt(CBCharacteristicProperties.notifyEncryptionRequired.rawValue)
        return (UInt(properties.rawValue) & mask) != 0
    }
    
    var requiresEncryptionToIndicate: Bool {
        guard let properties = properties else { return false }
        let mask = UInt(CBCharacteristicProperties.indicateEncryptionRequired.rawValue)
        return (UInt(properties.rawValue) & mask) != 0
    }
}

extension BleCharacteristic: Equatable {
    static func == (lhs: BleCharacteristic, rhs: BleCharacteristic) -> Bool {
        lhs.uuid == rhs.uuid
    }
}

extension BleCharacteristic: Hashable {
    var hashValue: Int { uuid.hashValue }
    
    func hash(into hasher: inout Hasher) {
        uuid.hash(into: &hasher)
    }
}

//MARK: Debug helpers
fileprivate extension BleCharacteristic {
    func printPropString() {
        let propString: String = {
            var s = ""
            if canBroadcast { s += "broadcast, " }
            if canRead { s += "read, " }
            if canWriteWithoutResponse { s += "writeWithoutResponse, " }
            if canWrite { s += "write, " }
            if canNotify { s += "notify, " }
            if canIndicate { s += "indicate, " }
            if canSignedWrite { s += "authenticatedSignedWrites, " }
            if hasExtendedProperties { s += "extendedProperties, " }
            if requiresEncryptionToNotify { s += "notifyEncryptionRequired, " }
            if requiresEncryptionToIndicate { s += "indicateEncryptionRequired, " }
            if s.isEmpty {
                return ""
            }
            return String(s.dropLast(2))
        }()
        print("\(uuid): \(propString)")
    }
    
    func printValueBytes() {
        guard let valueBytes = valueBytes else { return }
        print("\(uuid).valueBytes: \(valueBytes.toString())")
    }
    
    func printValue() {
        guard let value = value else { return }
        print("\(uuid).value: \(value)")
    }
}
