//
//  BleConnector.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/27/23.
//

import Foundation
import CoreBluetooth

protocol BleConnector {
    
    var connectedStatePublisher: Published<BleConnectedState>.Publisher { get }
    var connectedPeripheralPublisher: Published<CBPeripheral?>.Publisher { get }

    func connectDevice(withId id: UUID)
    func cancelConnection()
}
