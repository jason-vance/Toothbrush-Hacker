//
//  UnknownToothbrushService.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/30/23.
//

import Foundation
import CoreBluetooth

class AliceCharacteristic: BleCharacteristic<Int> {
    /*
     Clues:
     * Read
     * valueBytes: 0xCD01
     * value as Int: 461
     * Descriptor uuid "477EA600-A260-11E4-AE37-0002A5D5A0D0"
     *  BleDescriptor(477EA600-A260-11E4-AE37-0002A5D5A0D0).valueBytes: 0x20
     */
    
    class A0D0_Descriptor: BleDescriptor {
        static let uuid = CBUUID(string: "477EA600-A260-11E4-AE37-0002A5D5A0D0")
        
        override init?(cbDescriptor: CBDescriptor, bleCharacteristic: BleCharacteristicProtocol) {
            guard cbDescriptor.uuid == Self.uuid else { return nil }
            super.init(cbDescriptor: cbDescriptor, bleCharacteristic: bleCharacteristic)
        }
    }
    
    static let uuid = CBUUID(string: "477EA600-A260-11E4-AE37-0002A5D540D0")
    init() { super.init(uuid: Self.uuid, readValueOnDiscover: true) }
    
    override func createDescriptor(with cbDescriptor: CBDescriptor) -> BleDescriptor? {
        A0D0_Descriptor(cbDescriptor: cbDescriptor, bleCharacteristic: self) ?? nil
    }
}

class BobCharacteristic: BleCharacteristic<Int> {
    /*
     Clues:
     * Write
     *
     */
    
    static let uuid = CBUUID(string: "477EA600-A260-11E4-AE37-0002A5D540E0")
    init() { super.init(uuid: Self.uuid) }
}

class CarlCharacteristic: BleCharacteristic<Int> {
    /*
     Clues:
     * Read, Notify
     * valueBytes: 0xCA01
     * value as Int: 458
     */
    
    static let uuid = CBUUID(string: "477EA600-A260-11E4-AE37-0002A5D540F0")
    init() { super.init(uuid: Self.uuid, readValueOnDiscover: true, setToNotify: true) }
}

class DaveCharacteristic: BleCharacteristic<Int> {
    /*
     Clues:
     * Read
     * valueBytes: 0x847EEF64CA0107007800000100000000
     * value as Int: 1972293625413252
     * Descriptor uuid "477EA600-A260-11E4-AE37-0002A5D5A100"
     *  BleDescriptor(477EA600-A260-11E4-AE37-0002A5D5A100).valueBytes: 0x00
     */
    
    class A100_Descriptor: BleDescriptor {
        static let uuid = CBUUID(string: "477EA600-A260-11E4-AE37-0002A5D5A100")
        
        override init?(cbDescriptor: CBDescriptor, bleCharacteristic: BleCharacteristicProtocol) {
            guard cbDescriptor.uuid == Self.uuid else { return nil }
            super.init(cbDescriptor: cbDescriptor, bleCharacteristic: bleCharacteristic)
        }
    }
    
    static let uuid = CBUUID(string: "477EA600-A260-11E4-AE37-0002A5D54100")
    init() { super.init(uuid: Self.uuid, readValueOnDiscover: true) }
    
    override func createDescriptor(with cbDescriptor: CBDescriptor) -> BleDescriptor? {
        A100_Descriptor(cbDescriptor: cbDescriptor, bleCharacteristic: self) ?? nil
    }
}

class UnknownToothbrushService: BleService {
    
    static let uuid0001 = CBUUID(string: "477EA600-A260-11E4-AE37-0002A5D50001")
    static let charUuids0001: [CBUUID] = [
        CBUUID(string: "477EA600-A260-11E4-AE37-0002A5D54010"), // Power charging/on/off == 0x03/0x02/0x01
        CBUUID(string: "477EA600-A260-11E4-AE37-0002A5D54020"),
        CBUUID(string: "477EA600-A260-11E4-AE37-0002A5D54030"),
        CBUUID(string: "477EA600-A260-11E4-AE37-0002A5D54040"),
        CBUUID(string: "477EA600-A260-11E4-AE37-0002A5D54050"),
        CBUUID(string: "477EA600-A260-11E4-AE37-0002A5D54060")
    ]
    static let uuid0002 = CBUUID(string: "477EA600-A260-11E4-AE37-0002A5D50002")
    static let charUuids0002: [CBUUID] = [
        CBUUID(string: "477EA600-A260-11E4-AE37-0002A5D54070"),
        CBUUID(string: "477EA600-A260-11E4-AE37-0002A5D54080"), // Power mode? high/low == 0x00/0x02
        CBUUID(string: "477EA600-A260-11E4-AE37-0002A5D54090"), // The brushing time elapsed
        CBUUID(string: "477EA600-A260-11E4-AE37-0002A5D54091"), // The max toothbrush timer time
        CBUUID(string: "477EA600-A260-11E4-AE37-0002A5D540A0"),
        CBUUID(string: "477EA600-A260-11E4-AE37-0002A5D540B0"), // Power mode? high/low == 0x01/0x00
        CBUUID(string: "477EA600-A260-11E4-AE37-0002A5D540C0")
    ]
    static let uuid0003 = CBUUID(string: "477EA600-A260-11E4-AE37-0002A5D50003")
    static let charUuids0003: [CBUUID] = [
        CBUUID(string: "477EA600-A260-11E4-AE37-0002A5D540D0"),
        CBUUID(string: "477EA600-A260-11E4-AE37-0002A5D540E0"),
        CBUUID(string: "477EA600-A260-11E4-AE37-0002A5D540F0"),
        CBUUID(string: "477EA600-A260-11E4-AE37-0002A5D54100")
    ]

    private let alice = AliceCharacteristic()
    private let bob = BobCharacteristic()
    private let carl = CarlCharacteristic()
    private let dave = DaveCharacteristic()

    init(uuid: CBUUID) {
        let bleCharacteristicUuids =
            uuid == Self.uuid0001 ? Self.charUuids0001 :
            uuid == Self.uuid0002 ? Self.charUuids0002 :
            uuid == Self.uuid0003 ? Self.charUuids0003 :
            []
        
        
        super.init(
            uuid: uuid,
            bleCharacteristicUuids: bleCharacteristicUuids.map({ BleCharacteristic<Int>(uuid: $0) })
        )
    }
}
