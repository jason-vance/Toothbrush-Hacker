//
//  ConnectedViewModel.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/27/23.
//

import Foundation
import Combine

@MainActor
class ConnectedViewModel: ObservableObject {
    
    @Published var currentBatteryLevel: Double? = nil
    @Published var manufacturerName: String? = nil

    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    let toothbrushConnection: BleDeviceConnection
    let batteryMonitor: DeviceBatteryMonitor
    let deviceInfoReader: DeviceInformationReader

    var subs: Set<AnyCancellable> = []

    init(
        toothbrushConnection: BleDeviceConnection,
        batteryMonitor: DeviceBatteryMonitor,
        deviceInfoReader: DeviceInformationReader
    ) {
        self.toothbrushConnection = toothbrushConnection
        self.batteryMonitor = batteryMonitor
        self.deviceInfoReader = deviceInfoReader

        setupSubscribers()
    }
    
    private func setupSubscribers() {
        monitorBatteryLevel()
        subscribeToDeviceInfo()
    }
    
    private func monitorBatteryLevel() {
        batteryMonitor.batteryLevelPublisher
            .receive(on: RunLoop.main)
            .sink { self.currentBatteryLevel = $0 }
            .store(in: &subs)
    }
    
    private func subscribeToDeviceInfo() {
        deviceInfoReader.manufacturerNamePublisher
            .receive(on: RunLoop.main)
            .sink { self.manufacturerName = $0 }
            .store(in: &subs)
    }
    
    func disconnect() {
        Task {
            do {
                try await toothbrushConnection.cancelConnection()
            } catch {
                show(alertMessage: "Error while disconnecting")
            }
        }
    }
    
    func show(alertMessage: String) {
        showAlert = true
        self.alertMessage = alertMessage
    }
}
