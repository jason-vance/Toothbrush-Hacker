//
//  DeviceInformationService.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/29/23.
//

import Foundation
import CoreBluetooth

class DeviceInformationService: BleService {
    
    static let uuid = CBUUID(string: "180A")

    init() {
        super.init(
            uuid: Self.uuid,
            characteristics: [:]
        )
    }
}

/*
 didDiscoverCharacteristic: <CBCharacteristic: 0x281035680, UUID = Manufacturer Name String, properties = 0x2, value = (null), notifying = NO> uuid: 2A29
 didDiscoverCharacteristic: <CBCharacteristic: 0x281030c00, UUID = Model Number String, properties = 0x2, value = (null), notifying = NO> uuid: 2A24
 didDiscoverCharacteristic: <CBCharacteristic: 0x2810308a0, UUID = Serial Number String, properties = 0x2, value = (null), notifying = NO> uuid: 2A25
 didDiscoverCharacteristic: <CBCharacteristic: 0x281030a80, UUID = Hardware Revision String, properties = 0x2, value = (null), notifying = NO> uuid: 2A27
 didDiscoverCharacteristic: <CBCharacteristic: 0x2810309c0, UUID = Firmware Revision String, properties = 0x2, value = (null), notifying = NO> uuid: 2A26
 didDiscoverCharacteristic: <CBCharacteristic: 0x281030ae0, UUID = Software Revision String, properties = 0x2, value = (null), notifying = NO> uuid: 2A28
 didDiscoverCharacteristic: <CBCharacteristic: 0x281030300, UUID = System ID, properties = 0x2, value = (null), notifying = NO> uuid: 2A23
 didDiscoverCharacteristic: <CBCharacteristic: 0x281035080, UUID = IEEE Regulatory Certification, properties = 0x2, value = (null), notifying = NO> uuid: 2A2A
 didDiscoverCharacteristic: <CBCharacteristic: 0x281036400, UUID = PnP ID, properties = 0x2, value = (null), notifying = NO> uuid: 2A50

 */
