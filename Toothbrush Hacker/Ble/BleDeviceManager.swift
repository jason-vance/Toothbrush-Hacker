//
//  BleDeviceManager.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/26/23.
//

import Foundation
import CoreBluetooth
import Combine

struct TransferService {
    static let serviceUUID = CBUUID(string: "E20A39F4-73F5-4BC4-A12F-17D1AD07A961")
    static let characteristicUUID = CBUUID(string: "08590F7E-DB05-467E-8757-72F6FAEB13D4")
}

struct DeviceInformationService {
    static let serviceUUID = CBUUID(string: "180A")
    static let characteristicUUID = CBUUID(string: "2A19")
}

enum BleScanningState {
    case idle
    case scanning
}

enum BleConnectedState {
    case disconnected
    case connected
}

//TODO: Separate the scanning/connecting, and the communicating into different classes
class BleDeviceManager: NSObject {
    
    var centralManager: CBCentralManager! = nil
    
    @Published var scanningState: BleScanningState = .idle
    @Published var discoveredPeripheral: CBPeripheral? = nil
    @Published var discoveredPeripherals: Set<CBPeripheral> = []
    
    @Published var connectedState: BleConnectedState = .disconnected
    @Published var connectedPeripheral: CBPeripheral? = nil
    
    @Published var discoveredService: CBService? = nil
    @Published var discoveredServices: Set<CBService> = []
    @Published var discoveredCharacteristic: CBCharacteristic? = nil
    @Published var discoveredCharacteristics: Set<CBCharacteristic> = []
    @Published var discoveredDescriptor: CBDescriptor? = nil
    @Published var discoveredDescriptors: Set<CBDescriptor> = []
    
    @Published var characteristicValueUpdate: CBCharacteristic? = nil
    
    var transferCharacteristic: CBCharacteristic? = nil
    var writeIterationsComplete = 0
    var connectionIterationsComplete = 0
    
    let defaultIterations = 5   // change this value based on test usecase
    
    var data = Data()
    
    var subs: Set<AnyCancellable> = []
    
    static let instance: BleDeviceManager = {
        BleDeviceManager()
    }()

    private override init() {
        super.init()
        centralManager = CBCentralManager(
            delegate: self,
            queue: nil,
            options: [CBCentralManagerOptionShowPowerAlertKey: true]
        )
        
        $discoveredPeripheral
            .sink {
                if let peripheral = $0 {
                    self.discoveredPeripherals.insert(peripheral)
                }
            }
            .store(in: &subs)
        
        $connectedPeripheral
            .sink {
                self.connectedState = $0 == nil ? .disconnected : .connected
            }
            .store(in: &subs)
    }
    
    func startScan() {
        scanningState = .scanning
        
        discoveredPeripherals = []
        
        centralManager.scanForPeripherals(
            withServices: [],
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: true]
        )
    }
    
    func stopScan() {
        centralManager.stopScan()
        scanningState = .idle
        print("Scanning stopped")
    }
    
    func connectDevice(withId id: UUID) {
        guard let peripheral = (discoveredPeripherals.first { $0.identifier == id }) else { return }
        print("Connecting to peripheral \(peripheral)")
        centralManager.connect(peripheral, options: nil)
    }
    
    func discover(services: [CBUUID], on peripheral: CBPeripheral) {
        peripheral.discoverServices(services)
    }
    
    func discover(characteristics: [CBUUID], for service: CBService, on peripheral: CBPeripheral) {
        peripheral.discoverCharacteristics(characteristics, for: service)
    }
    
    func discoverDescriptors(for characteristic: CBCharacteristic, on peripheral: CBPeripheral) {
        peripheral.discoverDescriptors(for: characteristic)
    }
    
    func readValue(for characteristic: CBCharacteristic, on peripheral: CBPeripheral) {
        peripheral.readValue(for: characteristic)
    }
    
    /*
     * We will first check if we are already connected to our counterpart
     * Otherwise, scan for peripherals - specifically for our service's 128bit CBUUID
     */
    private func retrievePeripheral() {
        let connectedPeripherals = centralManager.retrieveConnectedPeripherals(
            withServices: [TransferService.serviceUUID]
        )
        
        print("Found connected Peripherals with transfer service: \(connectedPeripherals)")
        
        if let connectedPeripheral = connectedPeripherals.last {
            print("Connecting to peripheral \(connectedPeripheral)")
            centralManager.connect(connectedPeripheral, options: nil)
        } else {
            // We were not connected to our counterpart, so start scanning
            startScan()
        }
    }
    
    /*
     *  Call this when things either go wrong, or you're done with the connection.
     *  This cancels any subscriptions if there are any, or straight disconnects if not.
     *  (didUpdateNotificationStateForCharacteristic will cancel the connection if a subscription is involved)
     */
    private func cleanup() {
        // Don't do anything if we're not connected
        guard let connectedPeripheral = connectedPeripheral else { return }
        guard connectedPeripheral.state == .connected else { return }
        
        for service in (connectedPeripheral.services ?? [] as [CBService]) {
            for characteristic in (service.characteristics ?? [] as [CBCharacteristic]) {
                if characteristic.uuid == TransferService.characteristicUUID && characteristic.isNotifying {
                    // It is notifying, so unsubscribe
                    connectedPeripheral.setNotifyValue(false, for: characteristic)
                }
            }
        }
        
        // If we've gotten this far, we're connected, but we're not subscribed, so we just disconnect
        centralManager.cancelPeripheralConnection(connectedPeripheral)
    }
    
    /*
     *  Write some test data to peripheral
     */
    private func writeData() {
        guard let connectedPeripheral = connectedPeripheral else { return }
        guard let transferCharacteristic = transferCharacteristic else { return }
            
        // check to see if number of iterations completed and peripheral can accept more data
        while writeIterationsComplete < defaultIterations && connectedPeripheral.canSendWriteWithoutResponse {
            let mtu = connectedPeripheral.maximumWriteValueLength(for: .withoutResponse)
            var rawPacket = [UInt8]()
            
            let bytesToCopy: size_t = min(mtu, data.count)
            data.copyBytes(to: &rawPacket, count: bytesToCopy)
            let packetData = Data(bytes: &rawPacket, count: bytesToCopy)
            
            let stringFromData = String(data: packetData, encoding: .utf8)
            print("Writing \(bytesToCopy) bytes: \(String(describing: stringFromData))")
            
            connectedPeripheral.writeValue(packetData, for: transferCharacteristic, type: .withoutResponse)
            
            writeIterationsComplete += 1
        }
        
        if writeIterationsComplete == defaultIterations {
            // Cancel our subscription to the characteristic
            connectedPeripheral.setNotifyValue(false, for: transferCharacteristic)
        }
    }
}

extension BleDeviceManager: BleScanner {
    
    var scaninngStatePublisher: Published<BleScanningState>.Publisher {
        $scanningState
    }
    
    var discoveredPeripheralPublisher: Published<CBPeripheral?>.Publisher {
        $discoveredPeripheral
    }
    
    var discoveredPeripheralsPublisher: Published<Set<CBPeripheral>>.Publisher {
        $discoveredPeripherals
    }
}

extension BleDeviceManager: BleConnector {
    
    var connectedStatePublisher: Published<BleConnectedState>.Publisher {
        $connectedState
    }
    
    var connectedPeripheralPublisher: Published<CBPeripheral?>.Publisher {
        $connectedPeripheral
    }
    
    func cancelConnection() {
        cleanup()
    }
}

extension BleDeviceManager: CBCentralManagerDelegate {
    // implementations of the CBCentralManagerDelegate methods

    /*
     *  centralManagerDidUpdateState is a required protocol method.
     *  Usually, you'd check for other states to make sure the current device supports LE, is powered on, etc.
     *  In this instance, we're just using it to wait for CBCentralManagerStatePoweredOn, which indicates
     *  the Central is ready to be used.
     */
    internal func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            // ... so start working with the peripheral
            print("CBManager is powered on")
            retrievePeripheral()
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

    /*
     *  This callback comes whenever a peripheral that is advertising the transfer serviceUUID is discovered.
     *  We check the RSSI, to make sure it's close enough that we're interested in it, and if it is,
     *  we start the connection process
     */
    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber)
    {
        // Reject if the signal strength is too low to attempt data transfer.
        // Change the minimum RSSI value depending on your app’s use case.
        guard RSSI.intValue >= -50 else {
//            print("Discovered perhiperal not in expected range, at \(RSSI.intValue)")
            return
        }
        
        print("Discovered \(String(describing: peripheral.name)) at \(RSSI.intValue)")
        discoveredPeripheral = peripheral
//
//        // Device is in range - have we already seen it?
//        if discoveredPeripheral != peripheral {
//            // Save a local copy of the peripheral, so CoreBluetooth doesn't get rid of it.
//            discoveredPeripheral = peripheral
//
//            // And finally, connect to the peripheral.
//            print("Connecting to perhiperal \(peripheral)")
//            centralManager.connect(peripheral, options: nil)
//        }
    }

    /*
     *  If the connection fails for whatever reason, we need to deal with it.
     */
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to \(peripheral). \(String(describing: error))")
        cleanup()
    }
    
    /*
     *  We've connected to the peripheral, now we need to discover the services and characteristics to find the 'transfer' characteristic.
     */
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Peripheral Connected")
        
        // Stop scanning
        stopScan()
        
        connectedPeripheral = peripheral
        
        // set iteration info
        connectionIterationsComplete += 1
        writeIterationsComplete = 0
        
        // Clear the data that we may already have
        data.removeAll(keepingCapacity: false)
        
        // Make sure we get the discovery callbacks
        peripheral.delegate = self
        
        // Search only for services that match our UUID
        //TODO: use the CBUUIDs of the services I'm actually interested in
//        peripheral.discoverServices([])
    }
    
    /*
     *  Once the disconnection happens, we need to clean up our local copy of the peripheral
     */
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Perhiperal Disconnected")
        
        connectedPeripheral = nil
        
        // We're disconnected, so start scanning again
        if connectionIterationsComplete < defaultIterations {
            retrievePeripheral()
        } else {
            print("Connection iterations completed")
        }
    }
}

extension BleDeviceManager: CBPeripheralDelegate {
    // implementations of the CBPeripheralDelegate methods

    /*
     *  The peripheral letting us know when services have been invalidated.
     */
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        for service in invalidatedServices where service.uuid == TransferService.serviceUUID {
            print("Transfer service is invalidated - rediscover services")
            peripheral.discoverServices([TransferService.serviceUUID])
        }
    }

    /*
     *  The Transfer Service was discovered
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            cleanup()
            return
        }
        
        // Discover the characteristic we want...
        
        // Loop through the newly filled peripheral.services array, just in case there's more than one.
        guard let peripheralServices = peripheral.services else { return }
        for service in peripheralServices {
            print("Did discover service: \(service.uuid.uuidString)")
            discoveredService = service
//            peripheral.discoverCharacteristics([], for: service)
        }
    }
    
    /*
     *  The Transfer characteristic was discovered.
     *  Once this has been found, we want to subscribe to it, which lets the peripheral know we want the data it contains
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        // Deal with errors (if any).
        if let error = error {
            print("Error discovering characteristics: \(error.localizedDescription)")
            cleanup()
            return
        }
        
        // Again, we loop through the array, just in case and check if it's the right one
        guard let serviceCharacteristics = service.characteristics else { return }
        for characteristic in serviceCharacteristics {
            print("Did discover characteristic: \(characteristic.uuid.uuidString) in service: \(service.uuid.uuidString)")
            discoveredCharacteristic = characteristic
//            peripheral.discoverDescriptors(for: characteristic)
//            if characteristic.uuid == CBUUID(string: "2A19") {
//                peripheral.readValue(for: characteristic)
//            }
            // If it is, subscribe to it
//            transferCharacteristic = characteristic
//            peripheral.setNotifyValue(true, for: characteristic)
        }
        
        // Once this is complete, we just need to wait for the data to come in.
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        // Deal with errors (if any).
        if let error = error {
            print("Error discovering descriptors: \(error.localizedDescription)")
            cleanup()
            return
        }
        
        // Again, we loop through the array, just in case and check if it's the right one
        guard let characteristicDescriptors = characteristic.descriptors else { return }
        for descriptor in characteristicDescriptors {
            print("Did discover descriptor: \(descriptor.uuid.uuidString) in characteristic: \(characteristic.uuid.uuidString)")
            discoveredDescriptor = descriptor
//            if descriptor.uuid == CBUUID(string: "2904") {
//                peripheral.readValue(for: descriptor)
//            }
        }
    }
        
    /*
     *   This callback lets us know more data has arrived via notification on the characteristic
     */
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // Deal with errors (if any)
        if let error = error {
            print("Error discovering characteristics: \(error.localizedDescription)")
            cleanup()
            return
        }
        
        characteristicValueUpdate = characteristic
        guard let characteristicData = characteristic.value else { return }
        let byteArray = [UInt8](characteristicData)
        guard let stringFromData = String(data: characteristicData, encoding: .utf8) else { return }
        
        print("Received \(characteristicData.count) bytes: \(stringFromData)")
        
        // Have we received the end-of-message token?
        if stringFromData == "EOM" {
            // End-of-message case: show the data.
            // Dispatch the text view update to the main queue for updating the UI, because
            // we don't know which thread this method will be called back on.
            DispatchQueue.main.async() {
                let message = String(data: self.data, encoding: .utf8)
                print("Message received: \(String(describing: message))")
            }
            
            // Write test data
            writeData()
        } else {
            // Otherwise, just append the data to what we have previously received.
            data.append(characteristicData)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        // Deal with errors (if any)
        if let error = error {
            print("Error reading descriptor value: \(error.localizedDescription)")
            cleanup()
            return
        }
        
        guard let descriptorData = descriptor.value as? Data else { return }
        let byteArray = [UInt8](descriptorData)
        let byteStrArray = byteArray.map { String(format:"%02X", $0) }
        print("Received descriptor.value: \(String(describing: descriptorData))")
    }

    /*
     *  The peripheral letting us know whether our subscribe/unsubscribe happened or not
     */
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        // Deal with errors (if any)
        if let error = error {
            print("Error changing notification state: \(error.localizedDescription)")
            return
        }
        
        // Exit if it's not the transfer characteristic
        guard characteristic.uuid == TransferService.characteristicUUID else { return }
        
        if characteristic.isNotifying {
            // Notification has started
            print("Notification began on %@", characteristic)
        } else {
            // Notification has stopped, so disconnect from the peripheral
            print("Notification stopped on %@. Disconnecting", characteristic)
            cleanup()
        }
        
    }
    
    /*
     *  This is called when peripheral is ready to accept more data when using write without response
     */
    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        print("Peripheral is ready, send data")
        writeData()
    }
    
}

