//
//  BleCentralManager.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/28/23.
//

import Foundation
import CoreBluetooth
import Combine

class BleCentralManager: NSObject {
    
    static let instance: BleCentralManager = BleCentralManager()
    
    @Published private(set) var scanningState: ScanningState = .idle
    @Published private(set) var discoveredPeripheral: DiscoveredPeripheral? = nil
    @Published private(set) var connectionEvent: ConnectionEvent? = nil
    
    private let centralManager: CBCentralManager
    @Published private var managerState: CBManagerState? = nil
    
    private var subs: Set<AnyCancellable> = []

    private override init() {
        centralManager = CBCentralManager(
            delegate: nil,
            queue: nil,
            options: [CBCentralManagerOptionShowPowerAlertKey: true]
        )
        super.init()
        centralManager.delegate = self

        makeScanningStateIdleIfCentralIsNoLongerPoweredOn()
    }
    
    private func makeScanningStateIdleIfCentralIsNoLongerPoweredOn() {
        $managerState
            .sink(receiveValue: {
                guard $0 != .poweredOn else { return }
                self.scanningState = .idle
            })
            .store(in: &subs)
    }
    
    func connect(peripheral: CBPeripheral) {
        guard peripheral.state == .disconnected else { return }
        centralManager.connect(peripheral, options: nil)
    }
    
    func cancelPeripheralConnection(_ peripheral: CBPeripheral) {
        guard peripheral.state == .connected else { return }
        centralManager.cancelPeripheralConnection(peripheral)
    }
}

extension BleCentralManager: BleScanner {
    
    var scaninngStatePublisher: Published<ScanningState>.Publisher { $scanningState }
    var discoveredPeripheralPublisher: Published<DiscoveredPeripheral?>.Publisher { $discoveredPeripheral }
    
    func startScan() throws {
        try startScan(configuration: ScanConfiguration(services: [], allowDuplicates: true))
    }
    
    func startScan(configuration: ScanConfiguration) throws {
        guard managerState == .poweredOn else {
            throw "Bluetooth does not appear to be on/authorized"
        }
        
        scanningState = .scanning
        centralManager.scanForPeripherals(
            withServices: configuration.services,
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: configuration.allowDuplicates]
        )
    }
    
    func stopScan() {
        centralManager.stopScan()
        scanningState = .idle
    }
}

extension BleCentralManager: CBCentralManagerDelegate {
    // implementations of the CBCentralManagerDelegate methods

    /*
     *  centralManagerDidUpdateState is a required protocol method.
     *  Usually, you'd check for other states to make sure the current device supports LE, is powered on, etc.
     *  In this instance, we're just using it to wait for CBCentralManagerStatePoweredOn, which indicates
     *  the Central is ready to be used.
     */
    internal func centralManagerDidUpdateState(_ central: CBCentralManager) {
        managerState = central.state
        switch central.state {
        case .poweredOn:
            // ... so start working with the peripheral
            print("CBManager is powered on")
        case .poweredOff:
            print("CBManager is not powered on")
            // In a real app, you'd deal with all the states accordingly
            return
        case .resetting:
            print("CBManager is resetting")
            // In a real app, you'd deal with all the states accordingly
            return
        case .unauthorized:
            // In a real app, you'd deal with all the states accordingly
            guard #available(iOS 13.0, *) else {
                // Fallback on earlier versions
                return
            }

            let authorization: CBManagerAuthorization = {
                if #available(iOS 13.1, *) {
                    return CBCentralManager.authorization
                } else {
                    return central.authorization
                }
            }()
            switch authorization {
            case .denied:
                print("You are not authorized to use Bluetooth")
            case .restricted:
                print("Bluetooth is restricted")
            default:
                print("Unexpected authorization")
            }
            return
        case .unknown:
            print("CBManager state is unknown")
            // In a real app, you'd deal with all the states accordingly
            return
        case .unsupported:
            print("Bluetooth is not supported on this device")
            // In a real app, you'd deal with all the states accordingly
            return
        @unknown default:
            print("A previously unknown central manager state occurred")
            // In a real app, you'd deal with yet unknown cases that might occur in the future
            return
        }
    }

    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber)
    {
        guard RSSI.intValue >= -50 else { return }

        discoveredPeripheral = DiscoveredPeripheral(
            peripheral: peripheral,
            advertisementData: advertisementData,
            rssi: RSSI
        )
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to \(peripheral). \(String(describing: error))")
        connectionEvent = .didFailToConnect(peripheral, error)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Peripheral Connected")
        connectionEvent = .didConnect(peripheral)
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Perhiperal Disconnected")
        connectionEvent = .didDisconnect(peripheral, error)
    }
}
