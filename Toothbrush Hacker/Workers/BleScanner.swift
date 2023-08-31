//
//  BleScanner.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/27/23.
//

import Foundation
import CoreBluetooth

enum ScanningState {
    case idle
    case scanning
}

protocol BleScanner {
    
    var scaninngStatePublisher: Published<ScanningState>.Publisher { get }
    var discoveredPeripheralPublisher: Published<DiscoveredPeripheral?>.Publisher { get }
    
    func startScan()
    func stopScan()
}
