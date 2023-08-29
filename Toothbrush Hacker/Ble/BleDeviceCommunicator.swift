//
//  BleDeviceCommunicator.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/28/23.
//

import Foundation
import CoreBluetooth

class BleDeviceCommunicator: NSObject {
    
    private var centralManager: CBCentralManager! = nil
    
    private let connection: BleDeviceConnection
    
    init(connection: BleDeviceConnection) {
        self.connection = connection
        super.init()
        connection.peripheral.delegate = self
    }
    
    func readValue(for characteristic: CBCharacteristic) {
        connection.peripheral.readValue(for: characteristic)
    }
}

extension BleDeviceCommunicator: CBPeripheralDelegate {
    /*
     *   This callback lets us know more data has arrived via notification on the characteristic
     */
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // Deal with errors (if any)
        if let error = error {
            print("Error in didUpdateValueFor characteristics: \(error.localizedDescription)")
            return
        }
        
        guard let characteristicData = characteristic.value else { return }
        let byteArray = [UInt8](characteristicData)
        guard let stringFromData = String(data: characteristicData, encoding: .utf8) else { return }
        
        print("Received \(characteristicData.count) bytes: \(stringFromData)")
    }
}
