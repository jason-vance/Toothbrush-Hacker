//
//  BleScanner.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/27/23.
//

import Foundation
import CoreBluetooth

protocol BleScanner {
    
    var scaninngStatePublisher: Published<BleScanningState>.Publisher { get }
    var discoveredPeripheralPublisher: Published<CBPeripheral?>.Publisher { get }
    var discoveredPeripheralsPublisher: Published<Set<CBPeripheral>>.Publisher  { get }
    
    func startScan()
    func stopScan()
}
