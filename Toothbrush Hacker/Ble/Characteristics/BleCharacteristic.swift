//
//  BleCharacteristic.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/29/23.
//

import Foundation
import CoreBluetooth

protocol BleCharacteristicProtocol {
    var uuid: CBUUID { get }
    var descriptors: [CBUUID:BleDescriptor] { get }
    var characteristic: CBCharacteristic? { get }
    
    func communicator(_ communicator: BleDeviceCommunicator, discovered cbCharacteristic: CBCharacteristic)
    func communicator(_ communicator: BleDeviceCommunicator, discovered cbDescriptor: CBDescriptor, for cbCharacteristic: CBCharacteristic)
    func communicator(_ communicator: BleDeviceCommunicator, receivedValueUpdateFor cbCharacteristic: CBCharacteristic)
}

class BleCharacteristic<ValueType>: BleCharacteristicProtocol {
    
    let uuid: CBUUID
    private(set) var descriptors: [CBUUID:BleDescriptor] = [:]
    private(set) var characteristic: CBCharacteristic? = nil
    let readValueOnDiscover: Bool
    let setToNotify: Bool
    
    @Published var value: ValueType? = nil
    
    init(uuid: CBUUID, readValueOnDiscover: Bool = false, setToNotify: Bool = false) {
        self.uuid = uuid
        self.readValueOnDiscover = readValueOnDiscover
        self.setToNotify = setToNotify
    }
    
    final func communicator(_ communicator: BleDeviceCommunicator, discovered cbCharacteristic: CBCharacteristic) {
        guard self.characteristic == nil else {
            return
        }
        self.characteristic = cbCharacteristic
        communicator.discoverDescriptors(for: self)
        if readValueOnDiscover {
            communicator.readValue(for: self)
        }
        if setToNotify {
            communicator.startNotifications(for: self)
        }
    }
    
    final func communicator(_ communicator: BleDeviceCommunicator, discovered cbDescriptor: CBDescriptor, for cbCharacteristic: CBCharacteristic) {
        guard let descriptor = BleDescriptor.create(with: cbDescriptor) else { return }
        
        descriptors[descriptor.uuid] = descriptor
        communicator.readValue(for: descriptor)
    }
    
    final func communicator(_ communicator: BleDeviceCommunicator, receivedValueUpdateFor cbCharacteristic: CBCharacteristic) {
        guard let data = cbCharacteristic.value else { return }
        if let value = format(valueBytes: [UInt8](data)) {
            self.value = value
        } else {
            print("Could not format CBCharacteristic.value as \(String(describing: ValueType.self))")
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
            //TODO: Extend this to handle utf16 strings
            if let value = String(bytes: valueBytes, encoding: .utf8) {
                return value as? ValueType
            }
        }

        print("Override `format(valueBytes: [UInt8])` to handle type: \(String(describing: ValueType.self))")
        return nil
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


