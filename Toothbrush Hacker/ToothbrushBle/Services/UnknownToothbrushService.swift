//
//  UnknownToothbrushService.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/30/23.
//

import Foundation
import CoreBluetooth

class UnknownToothbrushService: BleService {
    
    static let uuid = CBUUID(string: "477EA600-A260-11E4-AE37-0002A5D50003")

    init() {
        super.init(
            uuid: Self.uuid,
            characteristics: [:]
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
