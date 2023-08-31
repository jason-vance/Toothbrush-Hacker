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
    
    static let uuid = CBUUID(string: "477EA600-A260-11E4-AE37-0002A5D50003")
    
    private let alice = AliceCharacteristic()
    private let bob = BobCharacteristic()
    private let carl = CarlCharacteristic()
    private let dave = DaveCharacteristic()

    init() {
        super.init(
            uuid: Self.uuid,
            bleCharacteristics: [
                alice.uuid: alice,
                bob.uuid: bob,
                carl.uuid: carl,
                dave.uuid: dave,
            ]
        )
    }
}


/*
 static let uuid = CBUUID(string: "477EA600-A260-11E4-AE37-0002A5D50001")
 didDiscoverCharacteristic: uuid: 477EA600-A260-11E4-AE37-0002A5D54010
 didDiscoverCharacteristic: uuid: 477EA600-A260-11E4-AE37-0002A5D54020
 didDiscoverCharacteristic: uuid: 477EA600-A260-11E4-AE37-0002A5D54030
 didDiscoverCharacteristic: uuid: 477EA600-A260-11E4-AE37-0002A5D54040
 didDiscoverCharacteristic: uuid: 477EA600-A260-11E4-AE37-0002A5D54050
 didDiscoverCharacteristic: uuid: 477EA600-A260-11E4-AE37-0002A5D54060
 */

/*
 static let uuid = CBUUID(string: "477EA600-A260-11E4-AE37-0002A5D50002")
 didDiscoverCharacteristic: uuid: 477EA600-A260-11E4-AE37-0002A5D54070
 didDiscoverCharacteristic: uuid: 477EA600-A260-11E4-AE37-0002A5D54080
 didDiscoverCharacteristic: uuid: 477EA600-A260-11E4-AE37-0002A5D54090
 didDiscoverCharacteristic: uuid: 477EA600-A260-11E4-AE37-0002A5D54091
 didDiscoverCharacteristic: uuid: 477EA600-A260-11E4-AE37-0002A5D540A0
 didDiscoverCharacteristic: uuid: 477EA600-A260-11E4-AE37-0002A5D540B0
 didDiscoverCharacteristic: uuid: 477EA600-A260-11E4-AE37-0002A5D540C0
 */

/*
 static let uuid = CBUUID(string: "477EA600-A260-11E4-AE37-0002A5D50003")
 didDiscoverCharacteristic: uuid: 477EA600-A260-11E4-AE37-0002A5D540D0
 didDiscoverCharacteristic: uuid: 477EA600-A260-11E4-AE37-0002A5D540E0
 didDiscoverCharacteristic: uuid: 477EA600-A260-11E4-AE37-0002A5D540F0
 didDiscoverCharacteristic: uuid: 477EA600-A260-11E4-AE37-0002A5D54100
 */
