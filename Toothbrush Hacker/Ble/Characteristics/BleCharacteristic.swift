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
    
    func communicator(_ communicator: BlePeripheralCommunicator, discovered cbCharacteristic: CBCharacteristic, for bleService: BleService)
    func communicator(_ communicator: BlePeripheralCommunicator, discovered cbDescriptor: CBDescriptor, for cbCharacteristic: CBCharacteristic)
    func communicator(_ communicator: BlePeripheralCommunicator, receivedValueUpdateFor cbCharacteristic: CBCharacteristic)
}

//TODO: Check a characteristics properties (readable, writable, etc)
class BleCharacteristic<ValueType>: BleCharacteristicProtocol {
    
    let uuid: CBUUID
    unowned private(set) var bleService: BleService? = nil
    private(set) var bleDescriptors: [CBUUID:BleDescriptor] = [:]
    private(set) var cbCharacteristic: CBCharacteristic? = nil
    let readValueOnDiscover: Bool
    let setToNotify: Bool
    
    @Published var valueBytes: [UInt8]? = nil
    @Published var value: ValueType? = nil

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
        if let value = format(valueBytes: valueBytes) {
            self.value = value
        } else {
            print("Could not format CBCharacteristic.value as \(String(describing: ValueType.self))")
        }
    }
    
    //TODO: Format this value using the format descriptor (maybe just the exponent)
    open func format(valueBytes: [UInt8]) -> ValueType? {
        print("Attempting to format \(valueBytes.toString()) for \(cbCharacteristic!)")
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
            //TODO: Extend this to handle utf16 strings (look at the format descriptor's format)
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


